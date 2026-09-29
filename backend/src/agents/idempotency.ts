import { ApiError } from '../http/errors.js';
import type { UserScope } from '../store/scope.js';
import type { StoreTransaction } from '../store/types.js';

/**
 * AIRequest replay cache (docs/04 "AIRequest"): UID + Idempotency-Key, request
 * hash, lease and 24-hour cached response. Duplicate keys return cached output
 * without another provider call.
 */

const LEASE_MS = 30_000;
const TTL_MS = 24 * 3_600_000;

export type Begin = { kind: 'cached'; response: unknown } | { kind: 'leased' };

export async function beginAiRequest(scope: UserScope, key: string, requestHash: string, now: Date): Promise<Begin> {
  const path = scope.doc('ai_requests', key);
  return scope.store.runTransaction(async (tx) => {
    const d = await tx.get(path);
    if (d && String(d.expiresAt) > now.toISOString()) {
      if (d.requestHash !== requestHash) throw new ApiError('IDEMPOTENCY_KEY_REUSED');
      if (d.state === 'completed' && typeof d.responseJson === 'string') {
        return { kind: 'cached', response: JSON.parse(d.responseJson) } as Begin;
      }
      if (d.state === 'inProgress' && String(d.leaseUntil) > now.toISOString()) {
        throw new ApiError('REQUEST_IN_PROGRESS', [], 5);
      }
    }
    tx.set(path, {
      id: key,
      requestHash,
      state: 'inProgress',
      responseJson: null,
      leaseUntil: new Date(now.getTime() + LEASE_MS).toISOString(),
      expiresAt: new Date(now.getTime() + TTL_MS).toISOString(),
    });
    return { kind: 'leased' } as Begin;
  });
}

/** Called inside the same transaction that persists the proposal/run/activity. */
export function completeAiRequest(tx: StoreTransaction, scope: UserScope, key: string, requestHash: string, response: unknown, now: Date): void {
  tx.set(scope.doc('ai_requests', key), {
    id: key,
    requestHash,
    state: 'completed',
    responseJson: JSON.stringify(response),
    leaseUntil: now.toISOString(),
    expiresAt: new Date(now.getTime() + TTL_MS).toISOString(),
  });
}

/** A failed request may be retried with the same key; no response is cached. */
export async function releaseAiRequest(scope: UserScope, key: string): Promise<void> {
  await scope.store.runTransaction(async (tx) => {
    const path = scope.doc('ai_requests', key);
    const d = await tx.get(path);
    if (d && d.state === 'inProgress') tx.set(path, { ...d, state: 'failed', leaseUntil: new Date(0).toISOString() });
  });
}
