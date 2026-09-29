import crypto from 'node:crypto';
import { loadCursorSigningKey } from '../config/env.js';
import { InsightsQuerySchema } from '../contracts/api.js';
import type { CanonicalRecord } from '../contracts/entities.js';
import { daysBetween } from '../domain/time.js';
import { ApiError, zodIssuesToFields } from '../http/errors.js';
import { route } from '../http/route.js';
import { RATE_RULES, reserveRate } from '../limits/rate-limit.js';
import { UserScope } from '../store/scope.js';

/**
 * GET /api/v1/agent/insights (docs/05): read-only, no model call, allowed with
 * AI off. Opaque cursor binds UID, range and position and is HMAC-signed.
 */

interface CursorBody {
  u: string;
  f: string;
  t: string;
  d: string;
  i: string;
}

function sign(body: CursorBody, key: string): string {
  const payload = Buffer.from(JSON.stringify(body)).toString('base64url');
  const mac = crypto.createHmac('sha256', key).update(payload).digest('base64url');
  return `${payload}.${mac}`;
}

function verify(cursor: string, key: string): CursorBody | null {
  const [payload, mac] = cursor.split('.');
  if (!payload || !mac) return null;
  const expected = crypto.createHmac('sha256', key).update(payload).digest();
  const given = Buffer.from(mac, 'base64url');
  if (given.length !== expected.length || !crypto.timingSafeEqual(given, expected)) return null;
  try {
    return JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as CursorBody;
  } catch {
    return null;
  }
}

export const insightsRoute = route({
  name: 'agent.insights',
  method: 'GET',
  auth: 'user',
  unavailableCode: 'SYNC_UNAVAILABLE',
  async handle({ deps, auth, query }) {
    const parsed = InsightsQuerySchema.safeParse(query);
    if (!parsed.success) throw new ApiError('VALIDATION_ERROR', zodIssuesToFields(parsed.error.issues));
    const { from, to } = parsed.data;
    const limit = parsed.data.limit ?? 20;
    const span = daysBetween(from, to);
    if (span <= 0 || span > 366) throw new ApiError('VALIDATION_ERROR', [{ path: 'to', code: 'RANGE_INVALID' }]);

    const key = loadCursorSigningKey(deps.env);
    const scope = new UserScope(auth!, deps.store);
    let startAfter: unknown[] | undefined;
    if (parsed.data.cursor) {
      const c = verify(parsed.data.cursor, key);
      if (!c || c.u !== scope.uid || c.f !== from || c.t !== to) throw new ApiError('INVALID_CURSOR');
      startAfter = [c.d, c.i];
    }
    await reserveRate(scope, RATE_RULES.insights, deps.clock());

    const state = await deps.store.get(scope.syncStateDoc());
    const lastLedgerSeq = typeof state?.lastLedgerSeq === 'number' ? state.lastLedgerSeq : 0;
    const rows = (await deps.store.query({
      collectionPath: scope.collection('ai_insights'),
      where: [
        ['businessDate', '>=', from],
        ['businessDate', '<', to],
      ],
      orderBy: [
        ['businessDate', 'desc'],
        ['id', 'desc'],
      ],
      startAfter,
      limit: limit + 1,
    })) as CanonicalRecord[];
    const page = rows.slice(0, limit);
    const last = page[page.length - 1];
    const nextCursor = rows.length > limit && last ? sign({ u: scope.uid, f: from, t: to, d: String(last.businessDate), i: last.id }, key) : null;
    // Tombstones are included so a client merge can apply them; stale is computed, never stored.
    const items = page.map((r) => ({ ...r, stale: lastLedgerSeq > Number(r.sourceWatermark ?? 0) }));
    return { data: { items, nextCursor, sourceWatermark: lastLedgerSeq } };
  },
});
