import { routeStructured, type Attempt, type EnabledAiConfig } from '../ai/router.js';
import { buildAliases, ModelParseSchema, parsePrompt, redact, type ModelParse } from '../ai/prompts.js';
import type { ModelFactory } from '../ai/providers.js';
import type { ParseCandidate, ParseRequest, ParseResponse, ProposalSource } from '../contracts/api.js';
import { canonicalHash, deterministicId } from '../contracts/canonical.js';
import { localDateOf } from '../contracts/primitives.js';
import { parseDecimalToMinor } from '../domain/money.js';
import { noonInZone } from '../domain/time.js';
import { ApiError } from '../http/errors.js';
import type { Logger } from '../observability/log.js';
import { mutation, publishChange, readSyncState } from '../sync/change-log.js';
import type { UserScope } from '../store/scope.js';
import { consentStatus, historyCategory, loadOwnerState, loadParseContext } from './context.js';
import { beginAiRequest, completeAiRequest, releaseAiRequest } from './idempotency.js';
import { activityRecord, addAttempts, agentRunRecord, emptyCounters, proposalRecord } from './records.js';
import { applyRules, isSufficient, type Field, type ParseContext, type RuleCandidate } from './rules.js';

/**
 * POST /api/v1/agent/parse-transaction (docs/05, docs/06): rules first, one
 * combined model call only when needed, strict validation of every ID, and a
 * persisted proposal/run/activity. Never creates a ledger row.
 */

const INTERACTIVE_DEADLINE_MS = 25_000;
const PROPOSAL_TTL_MS = 24 * 3_600_000;

export interface AgentDeps {
  scope: UserScope;
  ai: EnabledAiConfig | null;
  aiDisabledReason: string | null;
  models: ModelFactory;
  clock: () => Date;
  log: Logger;
  requestId: string;
}

export async function parseTransaction(d: AgentDeps, req: ParseRequest, idempotencyKey: string): Promise<ParseResponse> {
  const started = d.clock();
  if (!d.ai) throw new ApiError('AI_DISABLED');
  const owner = await loadOwnerState(d.scope);
  const consent = consentStatus(owner.settings, d.ai.privacyPolicyVersion);
  if (consent === 'disabled') throw new ApiError('AI_DISABLED');
  if (consent === 'noConsent') throw new ApiError('PRIVACY_NOT_ELIGIBLE');
  if (!owner.profile) throw new ApiError('MISSING_REFERENCE');
  if (req.currency !== owner.profile.baseCurrency) throw new ApiError('VALIDATION_ERROR', [{ path: 'currency', code: 'CURRENCY_MISMATCH' }]);

  const requestHash = canonicalHash(req);
  const begin = await beginAiRequest(d.scope, idempotencyKey, requestHash, started);
  if (begin.kind === 'cached') return begin.response as ParseResponse;

  try {
    return await run(d, d.ai, owner, req, idempotencyKey, requestHash, started);
  } catch (e) {
    await releaseAiRequest(d.scope, idempotencyKey).catch(() => undefined);
    throw e;
  }
}

async function run(
  d: AgentDeps,
  ai: EnabledAiConfig,
  owner: Awaited<ReturnType<typeof loadOwnerState>>,
  req: ParseRequest,
  key: string,
  requestHash: string,
  started: Date,
): Promise<ParseResponse> {
  const sourceWatermark = owner.lastSeq; // captured before reading context
  const exponent = Number(owner.profile!.currencyExponent);
  const ctx = await loadParseContext(d.scope, exponent);
  const referenceNow = new Date(req.referenceNow);
  const today = localDateOf(referenceNow, req.timeZone);

  const counters = emptyCounters();
  counters.attemptCount = 1;
  const rules = applyRules(req.rawInput, ctx, referenceNow, req.timeZone);
  counters.ruleMatches = rules.ruleMatches;
  let source: ProposalSource = rules.ruleMatches > 0 ? 'rule' : 'manual';
  let evidenceIds: string[] = [];

  // History suggestion for a known merchant.
  if (!rules.categoryId && rules.merchant && (rules.intent === 'expense' || rules.intent === 'income')) {
    const hist = await historyCategory(d.scope, rules.merchant, rules.intent, today);
    if (hist) {
      rules.categoryId = hist.categoryId;
      rules.fieldConfidence.categoryId = 0.9;
      evidenceIds = hist.evidenceIds;
      source = 'history';
    }
  }

  let merged = rules;
  let provider: string | null = null;
  let model: string | null = null;
  let modelConfidence: number | null = null;
  let attempts: Attempt[] = [];

  if (!isSufficient(rules)) {
    const aliases = buildAliases(ctx.accounts, ctx.categories, ctx.sources);
    const { system, prompt } = parsePrompt({
      redactedInput: redact(req.rawInput, ctx.accounts, ctx.sources),
      referenceDate: today,
      timeZone: req.timeZone,
      currency: req.currency,
      accounts: ctx.accounts,
      categories: ctx.categories,
      sources: ctx.sources,
    });
    const outcome = await routeStructured<ModelParse>({
      ai,
      models: d.models,
      scope: d.scope,
      clock: d.clock,
      log: d.log,
      fallbackAllowed: owner.settings?.fallbackEnabled === true,
      request: { system, prompt, schema: ModelParseSchema, schemaName: 'ParseCandidate' },
      validate: (o) => validateModelParse(o, aliases, ctx),
      deadlineAt: started.getTime() + INTERACTIVE_DEADLINE_MS,
    });
    attempts = outcome.attempts;
    addAttempts(counters, attempts);
    if (outcome.ok) {
      merged = mergeModel(rules, outcome.output, aliases, ctx, exponent);
      provider = outcome.provider;
      model = outcome.model;
      modelConfidence = outcome.output.confidence;
      source = outcome.provider === 'openrouter' ? 'openrouter' : 'gemini';
    } else {
      const code = outcome.reason === 'budget' ? 'AI_BUDGET_EXHAUSTED' : 'AI_UNAVAILABLE';
      await persistFailure(d, key, counters, attempts, started, code);
      if (outcome.reason === 'budget') throw new ApiError('AI_BUDGET_EXHAUSTED', [], 3600);
      // No fabricated partial success when a model was required and all eligible providers failed.
      throw new ApiError('AI_UNAVAILABLE');
    }
  }

  const candidate = toCandidate(merged, req, exponent);
  const confidence = overallConfidence(merged, modelConfidence);
  const hasSignal = candidate.intent !== 'unknown' || candidate.amountMinor !== null;
  const runId = deterministicId('run', 'parse', d.scope.uid, key);
  const proposalId = hasSignal ? deterministicId('proposal', runId) : null;
  if (!hasSignal) source = 'manual';
  const now = d.clock();
  const expiresAt = proposalId ? new Date(now.getTime() + PROPOSAL_TTL_MS).toISOString() : null;
  const fieldConfidence = Object.fromEntries(Object.entries(merged.fieldConfidence).map(([k, v]) => [k, round2(v!)]));

  const response: ParseResponse = {
    proposalId,
    candidate,
    confidence,
    fieldConfidence,
    questions: merged.questions.slice(0, 5),
    requiresConfirmation: true,
    source,
    agentRunId: runId,
    sourceWatermark,
    expiresAt,
  };

  // Proposal, AgentRun, AIActivity and the cached response persist atomically before success.
  const nowIso = now.toISOString();
  await d.scope.store.runTransaction(async (tx) => {
    const state = await readSyncState(tx, d.scope);
    const prevRun = await tx.get(d.scope.replicatedDoc('agentRun', runId));
    const activityId = deterministicId('activity', runId);
    const prevActivity = await tx.get(d.scope.replicatedDoc('aiActivity', activityId));
    const mutations = [];
    if (proposalId) {
      mutations.push(
        mutation(
          'aiProposal',
          proposalRecord(
            proposalId,
            {
              kind: 'transaction',
              candidateJson: candidate as unknown as Record<string, unknown>,
              targetId: null,
              targetRevision: null,
              confidence,
              fieldConfidence,
              questions: response.questions,
              evidenceIds,
              expiresAt: expiresAt!,
              agentRunId: runId,
            },
            nowIso,
          ),
        ),
      );
    }
    counters.manualReviewCount = response.questions.length > 0 ? 1 : 0;
    mutations.push(
      mutation(
        'agentRun',
        agentRunRecord(
          runId,
          { agentType: 'transactionParsing', businessDate: null, status: 'succeeded', startedAt: started.toISOString(), endedAt: nowIso, latencyMs: now.getTime() - started.getTime(), counters },
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
            agentType: 'transactionParsing',
            action: 'parseTransaction',
            outcome: proposalId ? (response.questions.length > 0 ? 'needsReview' : 'proposed') : 'skipped',
            summary: activitySummary(source, response.questions.length),
            entityIds: [],
            proposalId,
            provider,
            model,
            correlationId: d.requestId,
          },
          nowIso,
          prevActivity as never,
        ),
      ),
    );
    publishChange(tx, d.scope, state, mutations, { ledgerChanged: false, now: nowIso });
    completeAiRequest(tx, d.scope, key, requestHash, response, now);
  });
  return response;
}

function activitySummary(source: ProposalSource, questions: number): string {
  const base =
    source === 'rule'
      ? 'Merchant rule supplied a suggestion; no AI call needed.'
      : source === 'history'
        ? 'Past confirmed transactions supplied a suggestion; no AI call needed.'
        : source === 'manual'
          ? 'Input could not be interpreted; enter details manually.'
          : 'Transaction details suggested; review required.';
  return questions > 0 ? `${base} ${questions} question(s) need an answer.` : base;
}

async function persistFailure(d: AgentDeps, key: string, counters: ReturnType<typeof emptyCounters>, attempts: Attempt[], started: Date, code: string) {
  const runId = deterministicId('run', 'parse', d.scope.uid, key);
  const now = d.clock();
  const nowIso = now.toISOString();
  counters.errors.push({ code, retryable: true, attemptId: null });
  await d.scope.store.runTransaction(async (tx) => {
    const state = await readSyncState(tx, d.scope);
    const prevRun = await tx.get(d.scope.replicatedDoc('agentRun', runId));
    const activityId = deterministicId('activity', runId);
    const prevActivity = await tx.get(d.scope.replicatedDoc('aiActivity', activityId));
    publishChange(
      tx,
      d.scope,
      state,
      [
        mutation(
          'agentRun',
          agentRunRecord(
            runId,
            { agentType: 'transactionParsing', businessDate: null, status: 'failed', startedAt: started.toISOString(), endedAt: nowIso, latencyMs: now.getTime() - started.getTime(), counters },
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
              agentType: 'transactionParsing',
              action: 'parseTransaction',
              outcome: 'failed',
              summary: code === 'AI_BUDGET_EXHAUSTED' ? 'Daily AI budget reached; enter details manually.' : 'AI unavailable; enter details manually.',
              entityIds: [],
              proposalId: null,
              provider: attempts.at(-1)?.provider ?? null,
              model: attempts.at(-1)?.model ?? null,
              correlationId: d.requestId,
            },
            nowIso,
            prevActivity as never,
          ),
        ),
      ],
      { ledgerChanged: false, now: nowIso },
    );
  });
}

/** Every alias must be known and type-compatible; otherwise the output is invalid. */
function validateModelParse(o: ModelParse, aliases: ReturnType<typeof buildAliases>, ctx: ParseContext): boolean {
  void ctx;
  if (o.account !== null && !aliases.accounts.has(o.account)) return false;
  if (o.destinationAccount !== null && !aliases.accounts.has(o.destinationAccount)) return false;
  if (o.incomeSource !== null && !aliases.sources.has(o.incomeSource)) return false;
  if (o.category !== null) {
    const c = aliases.categories.get(o.category);
    if (!c) return false;
    if ((o.intent === 'income' || o.intent === 'expense') && c.type !== o.intent) return false;
  }
  if (o.date !== null && Number.isNaN(Date.parse(`${o.date}T00:00:00Z`))) return false;
  return true;
}

const THRESHOLD_SELECT = 0.6;

function mergeModel(rules: RuleCandidate, o: ModelParse, aliases: ReturnType<typeof buildAliases>, ctx: ParseContext, exponent: number): RuleCandidate {
  void ctx;
  const out: RuleCandidate = { ...rules, fieldConfidence: { ...rules.fieldConfidence }, questions: [] };
  const questions = new Set<string>();
  const take = (field: Field, conf: number, value: () => void) => {
    if (rules.explicit.has(field)) return;
    if (conf >= THRESHOLD_SELECT) {
      value();
      out.fieldConfidence[field] = conf;
    }
  };

  take('intent', o.fieldConfidence.intent, () => void (out.intent = o.intent));
  if (!rules.explicit.has('amountMinor') && !rules.amountAmbiguous && o.amount !== null && o.fieldConfidence.amount >= THRESHOLD_SELECT) {
    const p = parseDecimalToMinor(o.amount, exponent);
    if (p.ok && p.minor > 0) {
      out.amountMinor = p.minor;
      out.fieldConfidence.amountMinor = o.fieldConfidence.amount;
    }
  }
  if (out.intent === 'unknown') {
    out.accountId = null;
    out.destinationAccountId = null;
    out.categoryId = null;
    out.incomeSourceId = null;
  } else {
    if (!out.accountId && o.account) take('accountId', o.fieldConfidence.account, () => void (out.accountId = aliases.accounts.get(o.account!)!));
    if (out.intent === 'transfer') {
      if (!out.destinationAccountId && o.destinationAccount) {
        take('destinationAccountId', o.fieldConfidence.destinationAccount, () => void (out.destinationAccountId = aliases.accounts.get(o.destinationAccount!)!));
      }
      out.categoryId = null;
      out.incomeSourceId = null;
    } else {
      out.destinationAccountId = null;
      const cat = o.category ? aliases.categories.get(o.category) : undefined;
      if (!out.categoryId && cat && cat.type === out.intent) take('categoryId', o.fieldConfidence.category, () => void (out.categoryId = cat.id));
      if (out.categoryId && ctx.categories.find((c) => c.id === out.categoryId)?.type !== out.intent) out.categoryId = null;
      if (out.intent === 'income') {
        if (!out.incomeSourceId && o.incomeSource) take('incomeSourceId', o.fieldConfidence.incomeSource, () => void (out.incomeSourceId = aliases.sources.get(o.incomeSource!)!));
      } else out.incomeSourceId = null;
    }
  }
  if (out.accountId && out.accountId === out.destinationAccountId) out.destinationAccountId = null;
  if (!rules.explicit.has('effectiveDate') && o.date && o.fieldConfidence.date >= THRESHOLD_SELECT) {
    out.effectiveDate = o.date;
    out.fieldConfidence.effectiveDate = o.fieldConfidence.date;
  }
  if (!out.merchant && o.merchant) out.merchant = o.merchant.normalize('NFC').trim().slice(0, 120) || null;
  if (!out.description && o.description) out.description = o.description.normalize('NFC').trim().slice(0, 500);

  // Questions for anything still missing, plus model questions (bounded).
  if (out.intent === 'unknown') questions.add('Is this an expense, income or a transfer?');
  if (out.amountMinor === null) questions.add('What was the amount?');
  if (out.intent !== 'unknown' && !out.accountId) questions.add(out.intent === 'income' ? 'Which account received this income?' : out.intent === 'transfer' ? 'Which account did the money leave?' : 'Which account paid for this?');
  if (out.intent === 'transfer' && !out.destinationAccountId) questions.add('Which account received the money?');
  if (out.intent === 'income' && !out.incomeSourceId) questions.add('Which income source did this come from?');
  if (out.intent === 'income' && !out.categoryId) questions.add('Which income category fits?');
  for (const q of o.questions) if (questions.size < 5) questions.add(q.normalize('NFC').trim().slice(0, 200));
  out.questions = [...questions].slice(0, 5);
  return out;
}

function toCandidate(c: RuleCandidate, req: ParseRequest, exponent: number): ParseCandidate {
  void exponent;
  const today = localDateOf(new Date(req.referenceNow), req.timeZone);
  let occurredAt: string | null = null;
  if (c.effectiveDate) occurredAt = c.effectiveDate === today ? req.referenceNow : noonInZone(c.effectiveDate, req.timeZone).toISOString();
  return {
    intent: c.intent,
    amountMinor: c.amountMinor,
    currency: req.currency,
    merchant: c.merchant,
    description: c.description,
    accountId: c.accountId,
    destinationAccountId: c.intent === 'transfer' ? c.destinationAccountId : null,
    categoryId: c.intent === 'transfer' ? null : c.categoryId,
    incomeSourceId: c.intent === 'income' ? c.incomeSourceId : null,
    occurredAt,
    effectiveDate: c.effectiveDate,
    entryTimeZone: req.timeZone,
  };
}

function overallConfidence(c: RuleCandidate, modelConfidence: number | null): number {
  const values = Object.values(c.fieldConfidence).filter((v): v is number => typeof v === 'number');
  const fieldMin = values.length > 0 ? Math.min(...values) : 0;
  const base = modelConfidence === null ? fieldMin : Math.min(fieldMin, modelConfidence);
  return round2(c.questions.length > 0 ? Math.min(base, 0.59) : base);
}

function round2(v: number): number {
  return Math.round(v * 100) / 100;
}
