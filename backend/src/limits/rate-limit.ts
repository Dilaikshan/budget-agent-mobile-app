import { ApiError } from '../http/errors.js';
import type { UserScope } from '../store/scope.js';

/**
 * Persisted application rate limits (docs/05 "Rate limits"): reserved atomically
 * in Firestore after auth and before any model use. No process-memory limiter.
 */

export interface RateRule {
  bucket: string;
  limit: number;
  windowSeconds: number;
}

export const RATE_RULES = {
  syncPush: [{ bucket: 'push', limit: 30, windowSeconds: 60 }],
  syncPull: [{ bucket: 'pull', limit: 60, windowSeconds: 60 }],
  agent: [
    { bucket: 'agent', limit: 10, windowSeconds: 60 },
    { bucket: 'agentDay', limit: 100, windowSeconds: 86_400 },
  ],
  insights: [{ bucket: 'insights', limit: 30, windowSeconds: 60 }],
} satisfies Record<string, RateRule[]>;

export async function reserveRate(scope: UserScope, rules: RateRule[], now: Date): Promise<void> {
  const t = now.getTime();
  await scope.store.runTransaction(async (tx) => {
    const docs = rules.map((r) => {
      const windowStart = Math.floor(t / (r.windowSeconds * 1000)) * r.windowSeconds * 1000;
      return { r, windowStart, path: scope.doc('rate_limits', `${r.bucket}-${windowStart}`) };
    });
    const current = await Promise.all(docs.map((d) => tx.get(d.path)));
    docs.forEach((d, i) => {
      const count = typeof current[i]?.count === 'number' ? (current[i]!.count as number) : 0;
      if (count >= d.r.limit) {
        const retryAfter = Math.max(1, Math.ceil((d.windowStart + d.r.windowSeconds * 1000 - t) / 1000));
        throw new ApiError('RATE_LIMITED', [], retryAfter);
      }
    });
    docs.forEach((d, i) => {
      const count = typeof current[i]?.count === 'number' ? (current[i]!.count as number) : 0;
      tx.set(d.path, {
        id: `${d.r.bucket}-${d.windowStart}`,
        count: count + 1,
        expiresAt: new Date(d.windowStart + d.r.windowSeconds * 2000).toISOString(),
      });
    });
  });
}
