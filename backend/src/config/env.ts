import { z } from 'zod';

/**
 * Typed backend configuration (docs/12-DEPLOYMENT.md "Configuration inventory").
 * Core (Firebase/owner) config gates every data route. AI config is validated
 * separately so an AI misconfiguration disables only agent routes.
 */

const AppEnvSchema = z.enum(['development', 'preview', 'production']);
export type AppEnv = z.infer<typeof AppEnvSchema>;

const boolFlag = z
  .enum(['true', 'false'])
  .optional()
  .transform((v) => v === 'true');

const positiveIntFromEnv = (fallback: number) =>
  z
    .string()
    .regex(/^[1-9][0-9]{0,8}$/)
    .optional()
    .transform((v) => (v === undefined ? fallback : Number(v)));

const CoreEnvSchema = z.object({
  APP_ENV: AppEnvSchema,
  FIREBASE_PROJECT_ID: z.string().min(1),
  FIREBASE_CLIENT_EMAIL: z.string().email().optional(),
  FIREBASE_PRIVATE_KEY: z.string().min(1).optional(),
  OWNER_UID: z.string().min(1).max(128),
  ALLOWED_APP_IDS: z
    .string()
    .min(1)
    .transform((v) => v.split(',').map((s) => s.trim()).filter(Boolean)),
  FIRESTORE_EMULATOR_HOST: z.string().optional(),
  FIREBASE_AUTH_EMULATOR_HOST: z.string().optional(),
});

export interface CoreConfig {
  appEnv: AppEnv;
  firebaseProjectId: string;
  firebaseClientEmail: string | null;
  firebasePrivateKey: string | null;
  ownerUid: string;
  allowedAppIds: string[];
  usesEmulators: boolean;
}

const AiEnvSchema = z.object({
  AI_ENABLED: boolFlag,
  FALLBACK_ENABLED: boolFlag,
  AI_PRIVACY_ELIGIBLE: boolFlag,
  AI_PRIVACY_POLICY_VERSION: z.string().min(1).max(40).optional(),
  GEMINI_API_KEY: z.string().min(1).optional(),
  GEMINI_MODEL: z.string().min(1).max(80).optional(),
  OPENROUTER_API_KEY: z.string().min(1).optional(),
  OPENROUTER_MODEL: z.string().min(1).max(120).optional(),
  OPENROUTER_ALLOWED_PROVIDERS: z.string().optional(),
  AI_FAKE_PROVIDER: boolFlag,
  AI_DAILY_ATTEMPT_LIMIT: positiveIntFromEnv(100),
  AI_DAILY_INPUT_TOKEN_LIMIT: positiveIntFromEnv(100_000),
  AI_DAILY_OUTPUT_TOKEN_LIMIT: positiveIntFromEnv(20_000),
});

export interface ProviderConfig {
  provider: 'gemini' | 'openrouter' | 'fake';
  model: string;
  apiKey: string | null;
  allowedUpstreams: string[];
}

export type AiConfig =
  | { enabled: false; reason: string }
  | {
      enabled: true;
      privacyPolicyVersion: string;
      primary: ProviderConfig;
      fallback: ProviderConfig | null;
      dailyAttemptLimit: number;
      dailyInputTokenLimit: number;
      dailyOutputTokenLimit: number;
    };

export class ConfigError extends Error {
  constructor(readonly keys: string[]) {
    super(`Invalid configuration: ${keys.join(', ')}`);
  }
}

type Env = Record<string, string | undefined>;

function blankToUndefined(env: Env): Env {
  const out: Env = {};
  for (const [k, v] of Object.entries(env)) out[k] = v === undefined || v.trim() === '' ? undefined : v;
  return out;
}

export function loadCoreConfig(rawEnv: Env = process.env): CoreConfig {
  const env = blankToUndefined(rawEnv);
  const parsed = CoreEnvSchema.safeParse(env);
  if (!parsed.success) {
    throw new ConfigError([...new Set(parsed.error.issues.map((i) => String(i.path[0])))]);
  }
  const c = parsed.data;
  const usesEmulators = Boolean(c.FIRESTORE_EMULATOR_HOST || c.FIREBASE_AUTH_EMULATOR_HOST);
  if (usesEmulators && c.APP_ENV !== 'development') {
    // Emulator hosts must be absent in preview/production.
    throw new ConfigError(['FIRESTORE_EMULATOR_HOST']);
  }
  if (!usesEmulators && (!c.FIREBASE_CLIENT_EMAIL || !c.FIREBASE_PRIVATE_KEY)) {
    throw new ConfigError(['FIREBASE_CLIENT_EMAIL', 'FIREBASE_PRIVATE_KEY']);
  }
  return {
    appEnv: c.APP_ENV,
    firebaseProjectId: c.FIREBASE_PROJECT_ID,
    firebaseClientEmail: c.FIREBASE_CLIENT_EMAIL ?? null,
    // Vercel stores multi-line secrets with literal "\n"; normalize without logging.
    firebasePrivateKey: c.FIREBASE_PRIVATE_KEY ? c.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : null,
    ownerUid: c.OWNER_UID,
    allowedAppIds: c.ALLOWED_APP_IDS,
    usesEmulators,
  };
}

export function loadAiConfig(appEnv: AppEnv, rawEnv: Env = process.env): AiConfig {
  const env = blankToUndefined(rawEnv);
  const parsed = AiEnvSchema.safeParse(env);
  if (!parsed.success) return { enabled: false, reason: 'AI_CONFIG_INVALID' };
  const c = parsed.data;
  if (!c.AI_ENABLED) return { enabled: false, reason: 'AI_KILL_SWITCH' };
  if (!c.AI_PRIVACY_ELIGIBLE || !c.AI_PRIVACY_POLICY_VERSION) {
    return { enabled: false, reason: 'PRIVACY_NOT_REVIEWED' };
  }

  let primary: ProviderConfig;
  if (c.AI_FAKE_PROVIDER) {
    // Fake adapters are for local/preview smoke tests only.
    if (appEnv === 'production') return { enabled: false, reason: 'FAKE_PROVIDER_IN_PRODUCTION' };
    primary = { provider: 'fake', model: 'fake-parse-v1', apiKey: null, allowedUpstreams: [] };
  } else {
    if (!c.GEMINI_API_KEY || !c.GEMINI_MODEL) return { enabled: false, reason: 'GEMINI_NOT_CONFIGURED' };
    if (/latest/i.test(c.GEMINI_MODEL)) return { enabled: false, reason: 'MODEL_ALIAS_NOT_ALLOWED' };
    primary = { provider: 'gemini', model: c.GEMINI_MODEL, apiKey: c.GEMINI_API_KEY, allowedUpstreams: [] };
  }

  let fallback: ProviderConfig | null = null;
  if (c.FALLBACK_ENABLED && !c.AI_FAKE_PROVIDER) {
    const upstreams = (c.OPENROUTER_ALLOWED_PROVIDERS ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    // Fallback must pass its own privacy gate: an explicit upstream allowlist is mandatory.
    if (c.OPENROUTER_API_KEY && c.OPENROUTER_MODEL && upstreams.length > 0) {
      fallback = {
        provider: 'openrouter',
        model: c.OPENROUTER_MODEL,
        apiKey: c.OPENROUTER_API_KEY,
        allowedUpstreams: upstreams,
      };
    }
  }

  return {
    enabled: true,
    privacyPolicyVersion: c.AI_PRIVACY_POLICY_VERSION,
    primary,
    fallback,
    dailyAttemptLimit: c.AI_DAILY_ATTEMPT_LIMIT,
    dailyInputTokenLimit: c.AI_DAILY_INPUT_TOKEN_LIMIT,
    dailyOutputTokenLimit: c.AI_DAILY_OUTPUT_TOKEN_LIMIT,
  };
}

export interface JobConfig {
  cronSecret: string;
}

export function loadJobConfig(rawEnv: Env = process.env): JobConfig {
  const secret = blankToUndefined(rawEnv).CRON_SECRET;
  // At least 32 random bytes; hex (64) or base64 (44) encodings both satisfy >= 43 chars.
  if (!secret || secret.length < 43) throw new ConfigError(['CRON_SECRET']);
  return { cronSecret: secret };
}

export function loadCursorSigningKey(rawEnv: Env = process.env): string {
  const key = blankToUndefined(rawEnv).CURSOR_SIGNING_KEY;
  if (!key || key.length < 43) throw new ConfigError(['CURSOR_SIGNING_KEY']);
  return key;
}
