import { afterEach, describe, expect, it } from 'vitest';
import health from '../api/health.js';
import { authenticateCron, authenticateUser } from '../src/auth/guards.js';
import type { TokenVerifier } from '../src/auth/verifier.js';
import type { CoreConfig } from '../src/config/env.js';
import { loadAiConfig, loadCoreConfig } from '../src/config/env.js';
import { setDepsForTesting, type Deps } from '../src/http/deps.js';
import { ApiError } from '../src/http/errors.js';
import { silentLogger } from '../src/observability/log.js';
import { changesRoute, pushRoute } from '../src/routes/sync.js';
import { dailyAgentRoute } from '../src/routes/jobs.js';
import { MemoryStore } from '../src/store/memory.js';
import { OWNER, T0 } from './helpers.js';

const core: CoreConfig = {
  appEnv: 'development',
  firebaseProjectId: 'budget-agent-dev',
  firebaseClientEmail: null,
  firebasePrivateKey: null,
  ownerUid: OWNER,
  allowedAppIds: ['1:123:android:abc'],
  usesEmulators: true,
};

function verifier(over: Partial<{ uid: string; emailVerified: boolean; appId: string; badToken: boolean; badAppCheck: boolean }> = {}): TokenVerifier & { calls: string[] } {
  const calls: string[] = [];
  return {
    calls,
    async verifyIdToken() {
      calls.push('id');
      if (over.badToken) throw new Error('expired');
      return { uid: over.uid ?? OWNER, emailVerified: over.emailVerified ?? true };
    },
    async verifyAppCheck() {
      calls.push('appcheck');
      if (over.badAppCheck) throw new Error('bad');
      return { appId: over.appId ?? '1:123:android:abc' };
    },
  };
}

const headers = { authorization: `Bearer ${'x'.repeat(40)}`, 'x-firebase-appcheck': 'appcheck-token' };

async function code(p: Promise<unknown>) {
  try {
    await p;
    return 'OK';
  } catch (e) {
    return e instanceof ApiError ? e.code : 'OTHER';
  }
}

describe('user guard order and failures', () => {
  it('accepts the verified owner with email verification and allowed App Check app', async () => {
    const v = verifier();
    await expect(authenticateUser(headers, core, v)).resolves.toMatchObject({ uid: OWNER });
    expect(v.calls).toEqual(['id', 'appcheck']);
  });
  it('missing/invalid token → UNAUTHENTICATED before App Check', async () => {
    const v = verifier({ badToken: true });
    expect(await code(authenticateUser({}, core, v))).toBe('UNAUTHENTICATED');
    expect(await code(authenticateUser(headers, core, v))).toBe('UNAUTHENTICATED');
    expect(v.calls).toEqual(['id']);
  });
  it('non-owner → FORBIDDEN; unverified email → EMAIL_UNVERIFIED', async () => {
    expect(await code(authenticateUser(headers, core, verifier({ uid: 'intruder' })))).toBe('FORBIDDEN');
    expect(await code(authenticateUser(headers, core, verifier({ emailVerified: false })))).toBe('EMAIL_UNVERIFIED');
  });
  it('App Check missing, invalid or from a non-allowlisted app fails', async () => {
    expect(await code(authenticateUser({ authorization: headers.authorization }, core, verifier()))).toBe('APP_CHECK_FAILED');
    expect(await code(authenticateUser(headers, core, verifier({ badAppCheck: true })))).toBe('APP_CHECK_FAILED');
    expect(await code(authenticateUser(headers, core, verifier({ appId: 'other-app' })))).toBe('APP_CHECK_FAILED');
  });
  it('cron secret compares safely and rejects wrong/missing secrets', () => {
    expect(() => authenticateCron({ authorization: 'Bearer s3cret' }, 's3cret')).not.toThrow();
    expect(() => authenticateCron({ authorization: 'Bearer wrong' }, 's3cret')).toThrow(ApiError);
    expect(() => authenticateCron({}, 's3cret')).toThrow(ApiError);
  });
});

describe('configuration', () => {
  it('fails closed without owner, project or credentials', () => {
    expect(() => loadCoreConfig({ APP_ENV: 'production' })).toThrow();
    expect(() => loadCoreConfig({ APP_ENV: 'production', FIREBASE_PROJECT_ID: 'p', OWNER_UID: 'u', ALLOWED_APP_IDS: 'a' })).toThrow();
    expect(() => loadCoreConfig({ APP_ENV: 'maybe', FIREBASE_PROJECT_ID: 'p', OWNER_UID: 'u', ALLOWED_APP_IDS: 'a', FIRESTORE_EMULATOR_HOST: 'x' })).toThrow();
  });
  it('emulator hosts are forbidden outside development', () => {
    expect(() => loadCoreConfig({ APP_ENV: 'production', FIREBASE_PROJECT_ID: 'p', OWNER_UID: 'u', ALLOWED_APP_IDS: 'a', FIRESTORE_EMULATOR_HOST: 'localhost:8080' })).toThrow();
  });
  it('normalizes escaped private-key newlines', () => {
    const c = loadCoreConfig({ APP_ENV: 'production', FIREBASE_PROJECT_ID: 'p', OWNER_UID: 'u', ALLOWED_APP_IDS: 'a,b', FIREBASE_CLIENT_EMAIL: 'sa@p.iam.gserviceaccount.com', FIREBASE_PRIVATE_KEY: 'line1\\nline2' });
    expect(c.firebasePrivateKey).toBe('line1\nline2');
    expect(c.allowedAppIds).toEqual(['a', 'b']);
  });
  it('AI stays disabled until kill switch, privacy review and model config are set', () => {
    expect(loadAiConfig('production', {})).toMatchObject({ enabled: false, reason: 'AI_KILL_SWITCH' });
    expect(loadAiConfig('production', { AI_ENABLED: 'true' })).toMatchObject({ enabled: false, reason: 'PRIVACY_NOT_REVIEWED' });
    const base = { AI_ENABLED: 'true', AI_PRIVACY_ELIGIBLE: 'true', AI_PRIVACY_POLICY_VERSION: 'pp-1' };
    expect(loadAiConfig('production', base)).toMatchObject({ enabled: false, reason: 'GEMINI_NOT_CONFIGURED' });
    expect(loadAiConfig('production', { ...base, GEMINI_API_KEY: 'k', GEMINI_MODEL: 'gemini-flash-latest' })).toMatchObject({ enabled: false, reason: 'MODEL_ALIAS_NOT_ALLOWED' });
    expect(loadAiConfig('production', { ...base, AI_FAKE_PROVIDER: 'true' })).toMatchObject({ enabled: false });
    const ok = loadAiConfig('production', { ...base, GEMINI_API_KEY: 'k', GEMINI_MODEL: 'gemini-3.5-flash-lite', FALLBACK_ENABLED: 'true', OPENROUTER_API_KEY: 'o', OPENROUTER_MODEL: 'm' });
    // Fallback without an upstream allowlist is never enabled.
    expect(ok).toMatchObject({ enabled: true, fallback: null });
  });
});

class Res {
  statusCode = 0;
  body: any = null;
  headers: Record<string, string> = {};
  status(c: number) {
    this.statusCode = c;
    return this;
  }
  setHeader(n: string, v: string) {
    this.headers[n.toLowerCase()] = v;
  }
  json(b: unknown) {
    this.body = b;
  }
}

function deps(v = verifier()): Deps {
  return { core, ai: { enabled: false, reason: 'AI_KILL_SWITCH' }, store: new MemoryStore(), verifier: v, models: () => { throw new Error('no'); }, clock: () => T0, log: silentLogger, env: { CRON_SECRET: 's'.repeat(64) } };
}

describe('route wrapper', () => {
  afterEach(() => setDepsForTesting(null));

  it('health is static, cache-disabled and reveals nothing else', () => {
    const res = new Res();
    health({} as never, res as never);
    expect(res.body).toEqual({ status: 'ok', version: '1' });
    expect(res.headers['cache-control']).toBe('no-store');
  });

  it('returns the error envelope with requestId and no-store', async () => {
    setDepsForTesting(deps());
    const res = new Res();
    await pushRoute({ method: 'GET', headers: {} }, res);
    expect(res.statusCode).toBe(405);
    expect(res.body).toMatchObject({ error: { code: 'METHOD_NOT_ALLOWED', retryable: false, fields: [] }, requestId: expect.any(String) });
    expect(res.headers['cache-control']).toBe('no-store');
  });

  it('rejects non-JSON and oversized bodies before authentication', async () => {
    const v = verifier();
    setDepsForTesting(deps(v));
    const res1 = new Res();
    await pushRoute({ method: 'POST', headers: { 'content-type': 'text/plain' } }, res1);
    expect(res1.body.error.code).toBe('INVALID_JSON');
    const res2 = new Res();
    await pushRoute({ method: 'POST', headers: { 'content-type': 'application/json', 'content-length': String(300 * 1024) } }, res2);
    expect(res2.statusCode).toBe(413);
    expect(v.calls).toEqual([]);
  });

  it('never accepts a UID in the body and validates strictly', async () => {
    setDepsForTesting(deps());
    const res = new Res();
    await pushRoute({ method: 'POST', headers: { ...headers, 'content-type': 'application/json' }, body: { operations: [], userId: OWNER } }, res);
    expect(res.statusCode).toBe(422);
    expect(res.body.error.fields.some((f: { code: string }) => f.code === 'UNKNOWN_FIELD')).toBe(true);
  });

  it('pull validates query parameters as a cursor error', async () => {
    setDepsForTesting(deps());
    const res = new Res();
    await changesRoute({ method: 'GET', headers, query: { afterSeq: '-1' } }, res);
    expect(res.statusCode).toBe(400);
    expect(res.body.error.code).toBe('INVALID_CURSOR');
    const ok = new Res();
    await changesRoute({ method: 'GET', headers, query: { afterSeq: '0' } }, ok);
    expect(ok.statusCode).toBe(200);
    expect(ok.body.data).toEqual({ changes: [], nextAfterSeq: 0, watermark: 0, hasMore: false });
  });

  it('daily job: wrong secret 401, query secrets refused', async () => {
    setDepsForTesting(deps());
    const res = new Res();
    await dailyAgentRoute({ method: 'GET', headers: { authorization: 'Bearer nope' } }, res);
    expect(res.statusCode).toBe(401);
    const res2 = new Res();
    await dailyAgentRoute({ method: 'GET', headers: { authorization: `Bearer ${'s'.repeat(64)}` }, query: { secret: 'x' } }, res2);
    expect(res2.statusCode).toBe(422);
  });

  it('missing configuration returns 503 for data routes', async () => {
    const res = new Res();
    const saved = { ...process.env };
    delete process.env.FIREBASE_PROJECT_ID;
    delete process.env.OWNER_UID;
    try {
      await changesRoute({ method: 'GET', headers, query: { afterSeq: '0' } }, res);
    } finally {
      process.env = saved;
    }
    expect(res.statusCode).toBe(503);
    expect(res.body.error).toMatchObject({ code: 'SYNC_UNAVAILABLE', retryable: true });
  });
});
