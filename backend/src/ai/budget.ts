import type { UserScope } from '../store/scope.js';
import type { TokenUsage } from './providers.js';

/**
 * Shared per-UID daily AI budget (docs/06 "Request budget"): attempts and
 * worst-case tokens are reserved before a provider call and reconciled after.
 * Unknown usage keeps the conservative reservation.
 */

export interface BudgetLimits {
  attempts: number;
  inputTokens: number;
  outputTokens: number;
}

export interface Reservation {
  path: string;
  inputTokens: number;
  outputTokens: number;
}

export class BudgetExhaustedError extends Error {}

function dayKey(now: Date): string {
  return now.toISOString().slice(0, 10).replace(/-/g, '');
}

/** Conservative token estimate: ~3 characters per token, never below 1. */
export function estimateTokens(text: string): number {
  return Math.max(1, Math.ceil(text.length / 3));
}

export async function reserveAttempt(
  scope: UserScope,
  limits: BudgetLimits,
  now: Date,
  inputTokens: number,
  outputTokens: number,
): Promise<Reservation> {
  const id = `ai-budget-${dayKey(now)}`;
  const path = scope.doc('rate_limits', id);
  await scope.store.runTransaction(async (tx) => {
    const d = await tx.get(path);
    const used = {
      attempts: typeof d?.attempts === 'number' ? d.attempts : 0,
      inputTokens: typeof d?.inputTokens === 'number' ? d.inputTokens : 0,
      outputTokens: typeof d?.outputTokens === 'number' ? d.outputTokens : 0,
    };
    if (
      used.attempts + 1 > limits.attempts ||
      used.inputTokens + inputTokens > limits.inputTokens ||
      used.outputTokens + outputTokens > limits.outputTokens
    ) {
      throw new BudgetExhaustedError();
    }
    tx.set(path, {
      id,
      attempts: used.attempts + 1,
      inputTokens: used.inputTokens + inputTokens,
      outputTokens: used.outputTokens + outputTokens,
      expiresAt: new Date(now.getTime() + 2 * 86_400_000).toISOString(),
    });
  });
  return { path, inputTokens, outputTokens };
}

/** Release the unused part of a reservation when the provider reported actual usage. */
export async function reconcile(scope: UserScope, r: Reservation, usage: TokenUsage): Promise<void> {
  const refundIn = usage.inputTokens === null ? 0 : Math.max(0, r.inputTokens - usage.inputTokens);
  const refundOut = usage.outputTokens === null ? 0 : Math.max(0, r.outputTokens - usage.outputTokens);
  if (refundIn === 0 && refundOut === 0) return;
  await scope.store.runTransaction(async (tx) => {
    const d = await tx.get(r.path);
    if (!d) return;
    tx.set(r.path, {
      ...d,
      inputTokens: Math.max(0, Number(d.inputTokens ?? 0) - refundIn),
      outputTokens: Math.max(0, Number(d.outputTokens ?? 0) - refundOut),
    });
  });
}
