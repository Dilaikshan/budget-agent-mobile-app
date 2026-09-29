import crypto from 'node:crypto';
import type { AiConfig, ProviderConfig } from '../config/env.js';
import type { Logger } from '../observability/log.js';
import type { UserScope } from '../store/scope.js';
import { BudgetExhaustedError, estimateTokens, reconcile, reserveAttempt } from './budget.js';
import { classifyProviderError, type ModelFactory, type ProviderErrorKind, type StructuredRequest } from './providers.js';

/**
 * One primary attempt plus at most one eligible fallback (docs/06). Timeout,
 * 429, 5xx, auth misconfiguration and invalid output may fall back; refusal
 * and privacy ineligibility never do. No nested retries.
 */

export type EnabledAiConfig = Extract<AiConfig, { enabled: true }>;

export interface Attempt {
  attemptId: string;
  provider: string;
  model: string;
  status: 'success' | 'failed' | 'timeout' | 'invalidOutput';
  latencyMs: number;
  inputTokens: number | null;
  outputTokens: number | null;
  errorCode: string | null;
  estimatedCostMicros: number | null;
}

export type RouterOutcome<T> =
  | { ok: true; output: T; provider: ProviderConfig['provider']; model: string; attempts: Attempt[] }
  | { ok: false; reason: 'refused' | 'failed' | 'budget'; attempts: Attempt[] };

export const ATTEMPT_TIMEOUT_MS = 10_000;
export const MAX_OUTPUT_TOKENS = 1500;
const FALLBACK_ELIGIBLE: ReadonlySet<ProviderErrorKind> = new Set(['timeout', 'rateLimited', 'unavailable', 'invalidOutput', 'authError']);

export interface RouteOptions<T> {
  ai: EnabledAiConfig;
  models: ModelFactory;
  scope: UserScope;
  clock: () => Date;
  log: Logger;
  /** User setting; the operator config must also provide an eligible fallback. */
  fallbackAllowed: boolean;
  request: Omit<StructuredRequest<T>, 'timeoutMs' | 'maxOutputTokens'>;
  /** Domain validation of model output (allowed IDs, types); false = invalidOutput. */
  validate(output: T): boolean;
  deadlineAt: number;
  /** Optional cap on attempts for this invocation (daily job). */
  attemptsLeft?: () => number;
}

export async function routeStructured<T>(o: RouteOptions<T>): Promise<RouterOutcome<T>> {
  const chain: ProviderConfig[] = [o.ai.primary];
  if (o.fallbackAllowed && o.ai.fallback) chain.push(o.ai.fallback);
  const attempts: Attempt[] = [];
  const limits = {
    attempts: o.ai.dailyAttemptLimit,
    inputTokens: o.ai.dailyInputTokenLimit,
    outputTokens: o.ai.dailyOutputTokenLimit,
  };

  for (const cfg of chain) {
    const remaining = o.deadlineAt - o.clock().getTime();
    if (remaining < 3_000) break;
    if (o.attemptsLeft && o.attemptsLeft() <= 0) break;
    const timeoutMs = Math.min(ATTEMPT_TIMEOUT_MS, remaining - 2_000);
    const inputEstimate = estimateTokens(o.request.system + o.request.prompt);

    let reservation;
    try {
      reservation = await reserveAttempt(o.scope, limits, o.clock(), inputEstimate, MAX_OUTPUT_TOKENS);
    } catch (e) {
      if (e instanceof BudgetExhaustedError) {
        o.log.info('quota_reservation_failed', { provider: cfg.provider });
        return { ok: false, reason: 'budget', attempts };
      }
      throw e;
    }

    const provider = o.models(cfg);
    const attemptId = crypto.randomUUID();
    const started = Date.now();
    try {
      const res = await provider.generateStructured({ ...o.request, timeoutMs, maxOutputTokens: MAX_OUTPUT_TOKENS });
      await reconcile(o.scope, reservation, res.usage);
      const valid = o.validate(res.output);
      attempts.push(attempt(attemptId, cfg, valid ? 'success' : 'invalidOutput', started, res.usage, valid ? null : 'INVALID_OUTPUT'));
      o.log.info('provider_attempt_completed', { attemptId, provider: cfg.provider, model: cfg.model, latencyMs: Date.now() - started, errorCode: valid ? null : 'INVALID_OUTPUT' });
      if (valid) return { ok: true, output: res.output, provider: cfg.provider, model: cfg.model, attempts };
      continue; // invalid output is fallback-eligible
    } catch (e) {
      const pe = classifyProviderError(e);
      await reconcile(o.scope, reservation, pe.usage);
      const status = pe.kind === 'timeout' ? 'timeout' : pe.kind === 'invalidOutput' ? 'invalidOutput' : 'failed';
      attempts.push(attempt(attemptId, cfg, status, started, pe.usage, `PROVIDER_${pe.kind.toUpperCase()}`));
      o.log.info('provider_attempt_completed', { attemptId, provider: cfg.provider, model: cfg.model, latencyMs: Date.now() - started, errorCode: pe.kind });
      if (pe.kind === 'refused') return { ok: false, reason: 'refused', attempts };
      if (!FALLBACK_ELIGIBLE.has(pe.kind)) break;
    }
  }
  return { ok: false, reason: 'failed', attempts };
}

function attempt(
  attemptId: string,
  cfg: ProviderConfig,
  status: Attempt['status'],
  started: number,
  usage: { inputTokens: number | null; outputTokens: number | null },
  errorCode: string | null,
): Attempt {
  return {
    attemptId,
    provider: cfg.provider,
    model: cfg.model,
    status,
    latencyMs: Date.now() - started,
    inputTokens: usage.inputTokens,
    outputTokens: usage.outputTokens,
    errorCode,
    estimatedCostMicros: null,
  };
}
