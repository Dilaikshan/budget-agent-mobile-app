/** Error codes and HTTP statuses from docs/05-API-CONTRACTS.md. */
export const ERROR_STATUS = {
  INVALID_JSON: 400,
  UNKNOWN_FIELD: 400,
  INVALID_CURSOR: 400,
  UNAUTHENTICATED: 401,
  FORBIDDEN: 403,
  EMAIL_UNVERIFIED: 403,
  APP_CHECK_FAILED: 403,
  AI_DISABLED: 403,
  PRIVACY_NOT_ELIGIBLE: 403,
  NOT_FOUND: 404,
  METHOD_NOT_ALLOWED: 405,
  REVISION_CONFLICT: 409,
  IDEMPOTENCY_KEY_REUSED: 409,
  REQUEST_IN_PROGRESS: 409,
  PAYLOAD_TOO_LARGE: 413,
  VALIDATION_ERROR: 422,
  MISSING_REFERENCE: 422,
  ARCHIVED_REFERENCE: 422,
  STALE_PROPOSAL: 422,
  AMBIGUOUS_INPUT: 422,
  RATE_LIMITED: 429,
  AI_BUDGET_EXHAUSTED: 429,
  INTERNAL: 500,
  SYNC_UNAVAILABLE: 503,
  AI_UNAVAILABLE: 503,
  JOB_UNAVAILABLE: 503,
} as const;

export type ErrorCode = keyof typeof ERROR_STATUS;

export interface FieldError {
  path: string;
  code: string;
}

const SAFE_MESSAGES: Record<ErrorCode, string> = {
  INVALID_JSON: 'Request body is not valid JSON.',
  UNKNOWN_FIELD: 'Request contains unsupported fields.',
  INVALID_CURSOR: 'Cursor or sequence parameters are invalid.',
  UNAUTHENTICATED: 'Sign-in required.',
  FORBIDDEN: 'Not authorized for this instance.',
  EMAIL_UNVERIFIED: 'Verify your email address first.',
  APP_CHECK_FAILED: 'App attestation failed.',
  AI_DISABLED: 'AI assistance is disabled.',
  PRIVACY_NOT_ELIGIBLE: 'AI provider privacy review or consent is missing.',
  NOT_FOUND: 'Not found.',
  METHOD_NOT_ALLOWED: 'Method not allowed.',
  REVISION_CONFLICT: 'The record changed on another device.',
  IDEMPOTENCY_KEY_REUSED: 'Idempotency key was already used for a different request.',
  REQUEST_IN_PROGRESS: 'An identical request is still in progress.',
  PAYLOAD_TOO_LARGE: 'Request is too large.',
  VALIDATION_ERROR: 'Request failed validation.',
  MISSING_REFERENCE: 'A referenced record does not exist.',
  ARCHIVED_REFERENCE: 'A referenced record is archived.',
  STALE_PROPOSAL: 'The suggestion is out of date.',
  AMBIGUOUS_INPUT: 'Input is ambiguous.',
  RATE_LIMITED: 'Too many requests.',
  AI_BUDGET_EXHAUSTED: 'Daily AI budget is exhausted.',
  INTERNAL: 'Unexpected server error.',
  SYNC_UNAVAILABLE: 'Sync is temporarily unavailable.',
  AI_UNAVAILABLE: 'AI is unavailable; enter details manually.',
  JOB_UNAVAILABLE: 'Job is temporarily unavailable.',
};

const RETRYABLE: ReadonlySet<ErrorCode> = new Set([
  'REQUEST_IN_PROGRESS',
  'RATE_LIMITED',
  'AI_BUDGET_EXHAUSTED',
  'INTERNAL',
  'SYNC_UNAVAILABLE',
  'AI_UNAVAILABLE',
  'JOB_UNAVAILABLE',
]);

/** Typed API failure; message is always a fixed safe summary, never input-derived. */
export class ApiError extends Error {
  readonly status: number;
  readonly retryable: boolean;

  constructor(
    readonly code: ErrorCode,
    readonly fields: FieldError[] = [],
    readonly retryAfterSeconds: number | null = null,
  ) {
    super(SAFE_MESSAGES[code]);
    this.status = ERROR_STATUS[code];
    this.retryable = RETRYABLE.has(code);
  }
}

export function zodIssuesToFields(issues: ReadonlyArray<{ path: PropertyKey[]; code: string }>): FieldError[] {
  return issues.slice(0, 20).map((i) => ({
    path: i.path.map(String).join('.').slice(0, 200),
    code: i.code === 'unrecognized_keys' ? 'UNKNOWN_FIELD' : i.code.toUpperCase().slice(0, 80),
  }));
}
