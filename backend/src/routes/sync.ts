import { ChangesQuerySchema, PushRequestSchema } from '../contracts/api.js';
import { ApiError, zodIssuesToFields } from '../http/errors.js';
import { route } from '../http/route.js';
import { RATE_RULES, reserveRate } from '../limits/rate-limit.js';
import { UserScope } from '../store/scope.js';
import { InvalidCursorError, SyncService } from '../sync/service.js';
import { validateBatch } from '../sync/validate.js';

export const pushRoute = route({
  name: 'sync.push',
  method: 'POST',
  auth: 'user',
  maxBodyBytes: 256 * 1024,
  unavailableCode: 'SYNC_UNAVAILABLE',
  async handle({ deps, auth, body, requestId }) {
    const parsed = PushRequestSchema.safeParse(body);
    if (!parsed.success) throw new ApiError('VALIDATION_ERROR', zodIssuesToFields(parsed.error.issues));
    // Validate the whole batch before any operation executes.
    const batch = validateBatch(parsed.data.operations);
    if ('errors' in batch) throw new ApiError('VALIDATION_ERROR', batch.errors);

    const scope = new UserScope(auth!, deps.store);
    await reserveRate(scope, RATE_RULES.syncPush, deps.clock());
    const results = await new SyncService(scope, deps.clock).push(batch.ok);
    deps.log.info('sync_push_completed', {
      requestId,
      opCount: results.length,
      accepted: results.filter((r) => r.status === 'accepted').length,
      replayed: results.filter((r) => r.status === 'accepted' && r.replayed).length,
      conflicts: results.filter((r) => r.status === 'conflict').length,
      rejected: results.filter((r) => r.status === 'rejected').length,
    });
    return { data: { results } };
  },
});

export const changesRoute = route({
  name: 'sync.changes',
  method: 'GET',
  auth: 'user',
  unavailableCode: 'SYNC_UNAVAILABLE',
  async handle({ deps, auth, query }) {
    const parsed = ChangesQuerySchema.safeParse(query);
    if (!parsed.success) throw new ApiError('INVALID_CURSOR', zodIssuesToFields(parsed.error.issues));
    const scope = new UserScope(auth!, deps.store);
    await reserveRate(scope, RATE_RULES.syncPull, deps.clock());
    try {
      const page = await new SyncService(scope, deps.clock).changes(parsed.data.afterSeq, parsed.data.watermark, parsed.data.limit ?? 100);
      return { data: page };
    } catch (e) {
      if (e instanceof InvalidCursorError) throw new ApiError('INVALID_CURSOR');
      throw e;
    }
  },
});
