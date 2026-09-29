import { buildAliases, classifyPrompt, ModelClassifySchema, redact, type ModelClassify } from '../ai/prompts.js';
import type { ModelFactory } from '../ai/providers.js';
import { routeStructured, type Attempt, type EnabledAiConfig } from '../ai/router.js';
import type { ClassifyRequest, ClassifyResponse, ProposalSource } from '../contracts/api.js';
import { canonicalHash, deterministicId } from '../contracts/canonical.js';
import type { CanonicalRecord } from '../contracts/entities.js';
import { localDateOf } from '../contracts/primitives.js';
import { ApiError } from '../http/errors.js';
import type { Logger } from '../observability/log.js';
import { mutation, newRecord, publishChange, readSyncState } from '../sync/change-log.js';
import type { UserScope } from '../store/scope.js';
import { consentStatus, historyCategory, loadOwnerState, loadParseContext } from './context.js';
import { beginAiRequest, completeAiRequest, releaseAiRequest } from './idempotency.js';
import { activityRecord, addAttempts, agentRunRecord, emptyCounters, proposalRecord, type RunCounters } from './records.js';
import { applyRules, normalizeMerchant, type ParseContext } from './rules.js';

/**
 * Category suggestion for a saved income/expense (docs/05 classify-transaction).
 * Never reparses or edits amount/account; the result is a revision-bound proposal.
 */

const INTERACTIVE_DEADLINE_MS = 25_000;
const PROPOSAL_TTL_MS = 7 * 24 * 3_600_000;

export interface ClassifyDeps {
  scope: UserScope;
  ai: EnabledAiConfig | null;
  models: ModelFactory;
  clock: () => Date;
  log: Logger;
  requestId: string;
}

export interface CategorySuggestion {
  categoryId: string | null;
  confidence: number;
  question: string | null;
  source: ProposalSource;
  evidenceIds: string[];
  attempts: Attempt[];
  provider: string | null;
  model: string | null;
  failed: 'budget' | 'unavailable' | null;
}

/** Shared by the interactive route and the daily agent. */
export async function suggestCategory(
  o: {
    scope: UserScope;
    ai: EnabledAiConfig | null;
    aiAllowed: boolean;
    fallbackAllowed: boolean;
    models: ModelFactory;
    clock: () => Date;
    log: Logger;
    deadlineAt: number;
    attemptsLeft?: () => number;
  },
  tx: CanonicalRecord,
  ctx: ParseContext,
  timeZone: string,
): Promise<CategorySuggestion> {
  const type = tx.type as 'income' | 'expense';
  const merchant = typeof tx.merchant === 'string' ? tx.merchant : null;
  const description = typeof tx.description === 'string' ? tx.description : '';
  const base: CategorySuggestion = { categoryId: null, confidence: 0, question: null, source: 'manual', evidenceIds: [], attempts: [], provider: null, model: null, failed: null };

  // Rules: exact merchant rules, keywords and curated mappings, restricted to this type.
  const text = [merchant, description].filter(Boolean).join(' ');
  const ruled = applyRules(`${type === 'income' ? 'income' : 'paid'} ${text}`, ctx, o.clock(), timeZone);
  const exactRule = merchant
    ? ctx.rules.filter((r) => r.transactionType === type && r.matchKind === 'merchantExact' && r.normalizedPattern === normalizeMerchant(merchant)).sort((a, b) => b.priority - a.priority)
    : [];
  if (exactRule.length > 0 && new Set(exactRule.filter((r) => r.priority === exactRule[0]!.priority).map((r) => r.categoryId)).size === 1) {
    return { ...base, categoryId: exactRule[0]!.categoryId, confidence: 0.95, source: 'rule' };
  }
  if (ruled.categoryId && ctx.categories.find((c) => c.id === ruled.categoryId)?.type === type) {
    return { ...base, categoryId: ruled.categoryId, confidence: ruled.fieldConfidence.categoryId ?? 0.8, source: 'rule' };
  }
  if (merchant) {
    const hist = await historyCategory(o.scope, merchant, type, localDateOf(o.clock(), timeZone), tx.id);
    if (hist) return { ...base, categoryId: hist.categoryId, confidence: 0.9, source: 'history', evidenceIds: hist.evidenceIds };
  }
  if (!o.ai || !o.aiAllowed) return { ...base, question: 'Choose a category for this transaction.' };

  const aliases = buildAliases(ctx.accounts, ctx.categories, ctx.sources);
  const { system, prompt } = classifyPrompt({
    type,
    merchantToken: merchant ? redact(merchant, ctx.accounts, ctx.sources).slice(0, 60) : null,
    redactedDescription: redact(description, ctx.accounts, ctx.sources).slice(0, 200),
    categories: ctx.categories,
  });
  const outcome = await routeStructured<ModelClassify>({
    ai: o.ai,
    models: o.models,
    scope: o.scope,
    clock: o.clock,
    log: o.log,
    fallbackAllowed: o.fallbackAllowed,
    request: { system, prompt, schema: ModelClassifySchema, schemaName: 'CategoryChange' },
    validate: (m) => m.category === null || aliases.categories.get(m.category)?.type === type,
    deadlineAt: o.deadlineAt,
    attemptsLeft: o.attemptsLeft,
  });
  if (!outcome.ok) {
    return { ...base, attempts: outcome.attempts, failed: outcome.reason === 'budget' ? 'budget' : 'unavailable', question: 'Choose a category for this transaction.' };
  }
  const m = outcome.output;
  const categoryId = m.category && m.confidence >= 0.6 ? aliases.categories.get(m.category)!.id : null;
  return {
    ...base,
    categoryId,
    confidence: Math.round(m.confidence * 100) / 100,
    question: categoryId ? (m.confidence < 0.9 ? (m.question?.slice(0, 200) ?? null) : null) : (m.question?.slice(0, 200) ?? 'Choose a category for this transaction.'),
    source: outcome.provider === 'openrouter' ? 'openrouter' : 'gemini',
    attempts: outcome.attempts,
    provider: outcome.provider,
    model: outcome.model,
  };
}

export async function classifyTransaction(d: ClassifyDeps, req: ClassifyRequest, idempotencyKey: string): Promise<ClassifyResponse> {
  const started = d.clock();
  if (!d.ai) throw new ApiError('AI_DISABLED');
  const owner = await loadOwnerState(d.scope);
  const consent = consentStatus(owner.settings, d.ai.privacyPolicyVersion);
  if (consent === 'disabled') throw new ApiError('AI_DISABLED');
  if (consent === 'noConsent') throw new ApiError('PRIVACY_NOT_ELIGIBLE');
  if (!owner.profile) throw new ApiError('MISSING_REFERENCE');

  const tx = (await d.scope.store.get(d.scope.entityDoc('transaction', req.transactionId))) as CanonicalRecord | null;
  if (!tx || tx.deletedAt !== null) throw new ApiError('NOT_FOUND');
  if (tx.revision !== req.baseRevision) throw new ApiError('REVISION_CONFLICT');
  if (tx.type !== 'income' && tx.type !== 'expense') throw new ApiError('VALIDATION_ERROR', [{ path: 'transactionId', code: 'NOT_CLASSIFIABLE' }]);

  const requestHash = canonicalHash(req);
  const begin = await beginAiRequest(d.scope, idempotencyKey, requestHash, started);
  if (begin.kind === 'cached') return begin.response as ClassifyResponse;

  try {
    const ctx = await loadParseContext(d.scope, Number(owner.profile.currencyExponent));
    const suggestion = await suggestCategory(
      { scope: d.scope, ai: d.ai, aiAllowed: true, fallbackAllowed: owner.settings?.fallbackEnabled === true, models: d.models, clock: d.clock, log: d.log, deadlineAt: started.getTime() + INTERACTIVE_DEADLINE_MS },
      tx,
      ctx,
      String(owner.profile.timeZone),
    );
    const counters = emptyCounters();
    counters.attemptCount = 1;
    counters.transactionCount = 1;
    counters.ruleMatches = suggestion.source === 'rule' ? 1 : 0;
    addAttempts(counters, suggestion.attempts);
    if (suggestion.failed) {
      if (suggestion.failed === 'budget') throw new ApiError('AI_BUDGET_EXHAUSTED', [], 3600);
      throw new ApiError('AI_UNAVAILABLE');
    }
    return await persist(d, req, tx, suggestion, counters, owner.lastSeq, idempotencyKey, requestHash, started);
  } catch (e) {
    await releaseAiRequest(d.scope, idempotencyKey).catch(() => undefined);
    throw e;
  }
}

async function persist(
  d: ClassifyDeps,
  req: ClassifyRequest,
  tx: CanonicalRecord,
  s: CategorySuggestion,
  counters: RunCounters,
  sourceWatermark: number,
  key: string,
  requestHash: string,
  started: Date,
): Promise<ClassifyResponse> {
  const runId = deterministicId('run', 'classify', d.scope.uid, key);
  const proposalId = deterministicId('proposal', runId);
  const now = d.clock();
  const nowIso = now.toISOString();
  const expiresAt = new Date(now.getTime() + PROPOSAL_TTL_MS).toISOString();
  const questions = s.question ? [s.question] : [];
  const response: ClassifyResponse = {
    proposalId,
    candidate: { transactionId: tx.id, baseRevision: req.baseRevision, categoryId: s.categoryId },
    confidence: s.confidence,
    questions,
    requiresConfirmation: true,
    source: s.source,
    agentRunId: runId,
    sourceWatermark,
    expiresAt,
  };
  counters.manualReviewCount = 1;

  await d.scope.store.runTransaction(async (t) => {
    const state = await readSyncState(t, d.scope);
    const current = (await t.get(d.scope.entityDoc('transaction', tx.id))) as CanonicalRecord | null;
    if (!current || current.deletedAt !== null) throw new ApiError('NOT_FOUND');
    if (current.revision !== req.baseRevision) throw new ApiError('REVISION_CONFLICT');
    const review = (await t.get(d.scope.replicatedDoc('reviewState', tx.id))) as CanonicalRecord | null;
    const prevRun = await t.get(d.scope.replicatedDoc('agentRun', runId));
    const activityId = deterministicId('activity', runId);
    const prevActivity = await t.get(d.scope.replicatedDoc('aiActivity', activityId));

    const mutations = [
      mutation(
        'aiProposal',
        proposalRecord(
          proposalId,
          {
            kind: 'categoryChange',
            candidateJson: response.candidate,
            targetId: tx.id,
            targetRevision: req.baseRevision,
            confidence: s.confidence,
            fieldConfidence: { categoryId: s.confidence },
            questions,
            evidenceIds: s.evidenceIds,
            expiresAt,
            agentRunId: runId,
          },
          nowIso,
        ),
      ),
      mutation(
        'agentRun',
        agentRunRecord(
          runId,
          { agentType: 'categorization', businessDate: null, status: 'succeeded', startedAt: started.toISOString(), endedAt: nowIso, latencyMs: now.getTime() - started.getTime(), counters },
          nowIso,
          prevRun as never,
        ),
      ),
      mutation(
        'aiActivity',
        activityRecord(
          activityId,
          {
            agentRunId: runId,
            agentType: 'categorization',
            action: 'suggestCategory',
            outcome: 'needsReview',
            summary: s.categoryId ? 'Category suggested; review required.' : 'No confident category; choose one manually.',
            entityIds: [tx.id],
            proposalId,
            provider: s.provider,
            model: s.model,
            correlationId: d.requestId,
          },
          nowIso,
          prevActivity as never,
        ),
      ),
    ];
    if (review && review.deletedAt === null && review.transactionRevision === req.baseRevision) {
      mutations.push(mutation('reviewState', newRecord(tx.id, { transactionRevision: req.baseRevision, state: 'needsReview', proposalId, reviewedAt: null }, nowIso, review)));
    }
    publishChange(t, d.scope, state, mutations, { ledgerChanged: false, now: nowIso });
    completeAiRequest(t, d.scope, key, requestHash, response, now);
  });
  return response;
}
