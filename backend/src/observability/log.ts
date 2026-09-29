import crypto from 'node:crypto';

/**
 * Allowlisted structured logger (docs/11-OBSERVABILITY.md). Only known safe
 * fields are emitted; raw input, prompts, amounts, names and tokens never are.
 */

const SAFE_FIELDS = new Set([
  'requestId',
  'clientRequestId',
  'route',
  'status',
  'code',
  'durationMs',
  'opCount',
  'accepted',
  'conflicts',
  'rejected',
  'replayed',
  'provider',
  'model',
  'promptVersion',
  'schemaVersion',
  'attemptId',
  'agentRunId',
  'latencyMs',
  'inputTokens',
  'outputTokens',
  'errorCode',
  'processed',
  'remaining',
  'businessDate',
  'uidHash',
  'fence',
  'reason',
]);

export type LogEvent =
  | 'request_completed'
  | 'authorization_denied'
  | 'sync_push_completed'
  | 'provider_attempt_completed'
  | 'daily_checkpoint'
  | 'lease_takeover'
  | 'quota_reservation_failed'
  | 'config_invalid'
  | 'unexpected_error';

export interface Logger {
  info(event: LogEvent, fields?: Record<string, unknown>): void;
  error(event: LogEvent, fields?: Record<string, unknown>): void;
}

function sanitize(fields: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(fields)) {
    if (!SAFE_FIELDS.has(k)) continue;
    if (typeof v === 'number' || typeof v === 'boolean' || v === null) out[k] = v;
    else if (typeof v === 'string') out[k] = v.slice(0, 120);
  }
  return out;
}

export const consoleLogger: Logger = {
  info: (event, fields = {}) => console.log(JSON.stringify({ level: 'info', event, ...sanitize(fields) })),
  error: (event, fields = {}) => console.error(JSON.stringify({ level: 'error', event, ...sanitize(fields) })),
};

export const silentLogger: Logger = { info: () => undefined, error: () => undefined };

/** Keyed hash of a UID for infrastructure logs; never log the raw Firebase UID. */
export function uidHash(uid: string, salt: string): string {
  return crypto.createHmac('sha256', salt).update(uid).digest('hex').slice(0, 16);
}
