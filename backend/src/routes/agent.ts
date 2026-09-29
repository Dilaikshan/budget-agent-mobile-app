import { classifyTransaction } from '../agents/classify.js';
import { parseTransaction } from '../agents/parse.js';
import { ClassifyRequestSchema, IdempotencyKeySchema, ParseRequestSchema } from '../contracts/api.js';
import { ApiError, zodIssuesToFields } from '../http/errors.js';
import { route, type RouteContext } from '../http/route.js';
import { RATE_RULES, reserveRate } from '../limits/rate-limit.js';
import { UserScope } from '../store/scope.js';

function idempotencyKey(ctx: RouteContext): string {
  const raw = ctx.headers['idempotency-key'];
  const parsed = IdempotencyKeySchema.safeParse(Array.isArray(raw) ? undefined : raw);
  if (!parsed.success) throw new ApiError('VALIDATION_ERROR', [{ path: 'Idempotency-Key', code: 'UUID_REQUIRED' }]);
  return parsed.data;
}

function agentDeps(ctx: RouteContext) {
  const scope = new UserScope(ctx.auth!, ctx.deps.store);
  return {
    scope,
    ai: ctx.deps.ai.enabled ? ctx.deps.ai : null,
    aiDisabledReason: ctx.deps.ai.enabled ? null : ctx.deps.ai.reason,
    models: ctx.deps.models,
    clock: ctx.deps.clock,
    log: ctx.deps.log,
    requestId: ctx.requestId,
  };
}

export const parseRoute = route({
  name: 'agent.parse',
  method: 'POST',
  auth: 'user',
  unavailableCode: 'AI_UNAVAILABLE',
  async handle(ctx) {
    const parsed = ParseRequestSchema.safeParse(ctx.body);
    if (!parsed.success) throw new ApiError('VALIDATION_ERROR', zodIssuesToFields(parsed.error.issues));
    const key = idempotencyKey(ctx);
    const d = agentDeps(ctx);
    if (!d.ai) throw new ApiError('AI_DISABLED');
    await reserveRate(d.scope, RATE_RULES.agent, ctx.deps.clock());
    return { data: await parseTransaction(d, parsed.data, key) };
  },
});

export const classifyRoute = route({
  name: 'agent.classify',
  method: 'POST',
  auth: 'user',
  unavailableCode: 'AI_UNAVAILABLE',
  async handle(ctx) {
    const parsed = ClassifyRequestSchema.safeParse(ctx.body);
    if (!parsed.success) throw new ApiError('VALIDATION_ERROR', zodIssuesToFields(parsed.error.issues));
    const key = idempotencyKey(ctx);
    const d = agentDeps(ctx);
    if (!d.ai) throw new ApiError('AI_DISABLED');
    await reserveRate(d.scope, RATE_RULES.agent, ctx.deps.clock());
    return { data: await classifyTransaction(d, parsed.data, key) };
  },
});
