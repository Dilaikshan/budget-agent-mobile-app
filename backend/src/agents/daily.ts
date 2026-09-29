import crypto from 'node:crypto';
import type { AiConfig, CoreConfig } from '../config/env.js';
import type { ModelFactory } from '../ai/providers.js';
import { deterministicId, sha256Hex } from '../contracts/canonical.js';
import type { CanonicalRecord } from '../contracts/entities.js';
import { localDateOf } from '../contracts/primitives.js';
import { addDays, addMonths, monthStart } from '../domain/time.js';
import type { Logger } from '../observability/log.js';
import { mutation, newRecord, publishChange, readSyncState, tombstone } from '../sync/change-log.js';
import { UserScope } from '../store/scope.js';
import type { DocStore } from '../store/types.js';
import { suggestCategory } from './classify.js';
import { consentStatus, loadOwnerState, loadParseContext } from './context.js';
import { AGENT_POLICY_VERSION, buildInsights, hasDataOnOrBefore, loadLedgerWindow, publishInsights } from './insights.js';
import { activityRecord, addAttempts, agentRunRecord, emptyCounters, mergeCounters, proposalRecord, type RunCounters } from './records.js';

/**
 * Daily agent (docs/06 "Daily agent algorithm", ADR-10): configured owner only,
 * fenced 90 s lease, ≤50 queued items, ≤20 provider attempts, 45 s of work.
 * Produces proposals, review state, activity and insights; never ledger writes.
 */

export const MAX_ITEMS = 50;
export const MAX_ATTEMPTS = 20;
export const WORK_BUDGET_MS = 45_000;
const LEASE_MS = 90_000;
const PROPOSAL_TTL_MS = 7 * 24 * 3_600_000;

export interface JobResult {
  businessDate: string;
  runId: string;
  status: 'running' | 'partial' | 'succeeded' | 'failed' | 'skipped';
  processed: number;
  remaining: boolean;
  replayed: boolean;
}

export interface DailyDeps {
  core: CoreConfig;
  ai: AiConfig;
  store: DocStore;
  models: ModelFactory;
  clock: () => Date;
  log: Logger;
  requestId: string;
}

class LeaseLost extends Error {}

interface Lease {
  id: string;
  ownerAttemptId: string;
  fence: number;
  leaseUntil: string;
  cursor: string | null;
}

export async function runDaily(d: DailyDeps): Promise<JobResult> {
  const scope = new UserScope({ uid: d.core.ownerUid, source: 'cronOwner' }, d.store);
  const started = d.clock();
  const deadlineAt = started.getTime() + WORK_BUDGET_MS;
  const owner = await loadOwnerState(scope);
  const tz = typeof owner.profile?.timeZone === 'string' ? owner.profile.timeZone : 'UTC';
  const businessDate = localDateOf(started, tz);
  const runId = sha256Hex(d.core.ownerUid + businessDate + 'daily-v1');
  const base = { businessDate, runId, processed: 0, remaining: false };

  if (!owner.profile || owner.settings?.dailyReviewEnabled !== true) {
    await writeRun(scope, runId, 'skipped', businessDate, started, d.clock(), { ...emptyCounters(), attemptCount: 1 });
    return { ...base, status: 'skipped', replayed: false };
  }

  // Acquire or resume the fenced lease.
  const attemptId = crypto.randomUUID();
  const acquired = await scope.store.runTransaction(async (tx) => {
    const now = d.clock();
    const lease = (await tx.get(scope.doc('run_leases', runId))) as Lease | null;
    const run = (await tx.get(scope.replicatedDoc('agentRun', runId))) as CanonicalRecord | null;
    if (run?.status === 'succeeded') return { replay: 'succeeded' as const };
    if (lease && lease.leaseUntil > now.toISOString()) return { replay: 'running' as const };
    const fence = (lease?.fence ?? 0) + 1;
    const state = await readSyncState(tx, scope);
    tx.set(scope.doc('run_leases', runId), {
      id: runId,
      ownerAttemptId: attemptId,
      fence,
      leaseUntil: new Date(now.getTime() + LEASE_MS).toISOString(),
      cursor: lease?.cursor ?? null,
    });
    const counters = mergeCounters(run, { ...emptyCounters(), attemptCount: 1 });
    publishChange(
      tx,
      scope,
      state,
      [mutation('agentRun', agentRunRecord(runId, { agentType: 'dailyReview', businessDate, status: 'running', startedAt: (run?.startedAt as string) ?? started.toISOString(), endedAt: null, latencyMs: 0, counters }, now.toISOString(), run))],
      { ledgerChanged: false, now: now.toISOString() },
    );
    return { replay: null, fence, tookOver: lease !== null };
  });
  if (acquired.replay) return { ...base, status: acquired.replay, replayed: true };
  if (acquired.tookOver) d.log.info('lease_takeover', { businessDate, fence: acquired.fence });
  const fence = acquired.fence!;

  const counters = emptyCounters();
  let attemptsUsed = 0;
  let processed = 0;
  let leaseLost = false;
  let insightsComplete = false;

  try {
    const aiCfg = d.ai.enabled ? d.ai : null;
    const aiAllowed = aiCfg !== null && consentStatus(owner.settings, aiCfg.privacyPolicyVersion) === 'ok';
    const ctx = await loadParseContext(scope, Number(owner.profile.currencyExponent));
    const queued = (await scope.store.query({
      collectionPath: scope.collection('review_states'),
      where: [['state', '==', 'queued']],
      orderBy: [['id', 'asc']],
      limit: MAX_ITEMS,
    })) as CanonicalRecord[];

    for (const item of queued) {
      if (d.clock().getTime() > deadlineAt - 1_000) break;
      const tx = (await scope.store.get(scope.entityDoc('transaction', item.id))) as CanonicalRecord | null;
      if (!tx || tx.deletedAt !== null || tx.revision !== item.transactionRevision) continue;
      const key = deterministicId(tx.id, String(tx.revision), AGENT_POLICY_VERSION);
      const outcome = await reviewItem(d, scope, ctx, tx, String(owner.profile.timeZone), {
        aiAllowed: aiAllowed && attemptsUsed < MAX_ATTEMPTS && deadlineAt - d.clock().getTime() > 12_000,
        fallbackAllowed: owner.settings?.fallbackEnabled === true,
        deadlineAt,
        attemptsLeft: () => MAX_ATTEMPTS - attemptsUsed,
      });
      attemptsUsed += outcome.attempts;
      addAttempts(counters, outcome.attemptRecords);
      const done = await checkpoint(scope, d, runId, fence, attemptId, tx, item, key, outcome);
      if (done === 'leaseLost') {
        leaseLost = true;
        break;
      }
      if (done === 'written') {
        processed++;
        counters.transactionCount++;
        if (outcome.ruleMatch) counters.ruleMatches++;
        if (outcome.state === 'needsReview') counters.manualReviewCount++;
      }
    }

    // Deterministic insights with a ledger watermark captured before reading.
    if (!leaseLost && deadlineAt - d.clock().getTime() > 5_000) {
      const state = await scope.store.get(scope.syncStateDoc());
      const sourceWatermark = typeof state?.lastSeq === 'number' ? state.lastSeq : 0;
      const thisMonth = monthStart(businessDate);
      const from = [addDays(businessDate, -90), addMonths(thisMonth, -2), monthStart(addDays(businessDate, -1))].sort()[0]!;
      const window = await loadLedgerWindow(scope, from, deadlineAt, d.clock);
      if (window.complete) {
        const drafts = buildInsights({
          txs: window.txs,
          businessDate,
          currency: String(owner.profile.baseCurrency),
          exponent: Number(owner.profile.currencyExponent),
          trendCoverage: await hasDataOnOrBefore(scope, addMonths(thisMonth, -2)),
          scopeId: 'all',
        });
        const result = await publishInsights(scope, drafts, sourceWatermark, runId, d.clock().toISOString());
        insightsComplete = result !== 'stale';
      }
    }

    if (!leaseLost && deadlineAt - d.clock().getTime() > 3_000) await cleanup(scope, d.clock());

    const remaining =
      (
        await scope.store.query({
          collectionPath: scope.collection('review_states'),
          where: [['state', '==', 'queued']],
          limit: 1,
        })
      ).length > 0;
    const status = leaseLost ? 'partial' : !remaining && insightsComplete ? 'succeeded' : 'partial';
    if (!leaseLost) await finishRun(scope, d, runId, fence, attemptId, status, businessDate, started, counters);
    d.log.info('daily_checkpoint', { businessDate, processed, remaining, status });
    return { ...base, status, processed, remaining, replayed: false };
  } catch (e) {
    counters.errors.push({ code: 'DAILY_RUN_FAILED', retryable: true, attemptId: null });
    await finishRun(scope, d, runId, fence, attemptId, 'failed', businessDate, started, counters).catch(() => undefined);
    throw e;
  }
}

interface ItemOutcome {
  state: 'reviewed' | 'needsReview';
  proposal: { categoryId: string | null; confidence: number; question: string | null; evidenceIds: string[] } | null;
  activity: { agentType: 'categorization' | 'consistencyCheck'; outcome: 'proposed' | 'skipped' | 'failed' | 'needsReview'; summary: string; provider: string | null; model: string | null };
  attempts: number;
  attemptRecords: import('../ai/router.js').Attempt[];
  ruleMatch: boolean;
}

async function reviewItem(
  d: DailyDeps,
  scope: UserScope,
  ctx: Awaited<ReturnType<typeof loadParseContext>>,
  tx: CanonicalRecord,
  timeZone: string,
  opts: { aiAllowed: boolean; fallbackAllowed: boolean; deadlineAt: number; attemptsLeft: () => number },
): Promise<ItemOutcome> {
  const none = { attempts: 0, attemptRecords: [], ruleMatch: false, proposal: null };
  // Deterministic consistency: references exist, accounts distinct, currency consistent. Never repairs.
  const accounts = [tx.accountId, tx.type === 'transfer' ? tx.destinationAccountId : null].filter(Boolean) as string[];
  const refs = await Promise.all(accounts.map((id) => scope.store.get(scope.entityDoc('account', id))));
  const consistent =
    refs.every((r) => r && r.deletedAt === null && r.currency === tx.currency) && (tx.type !== 'transfer' || tx.accountId !== tx.destinationAccountId);
  if (!consistent) {
    return { ...none, state: 'needsReview', activity: { agentType: 'consistencyCheck', outcome: 'needsReview', summary: 'Consistency check found a reference or currency problem; please review this entry.', provider: null, model: null } };
  }
  if (tx.type === 'opening' || tx.type === 'transfer' || tx.categoryId !== null) {
    return { ...none, state: 'reviewed', activity: { agentType: 'consistencyCheck', outcome: 'skipped', summary: 'Consistency check passed; no AI call needed.', provider: null, model: null } };
  }

  const s = await suggestCategory(
    { scope, ai: d.ai.enabled ? d.ai : null, aiAllowed: opts.aiAllowed, fallbackAllowed: opts.fallbackAllowed, models: d.models, clock: d.clock, log: d.log, deadlineAt: opts.deadlineAt, attemptsLeft: opts.attemptsLeft },
    tx,
    ctx,
    timeZone,
  );
  const common = { attempts: s.attempts.length, attemptRecords: s.attempts, ruleMatch: s.source === 'rule' };
  if (s.failed) {
    return { ...common, state: 'needsReview', proposal: null, activity: { agentType: 'categorization', outcome: 'failed', summary: 'Daily review could not reach AI; choose a category manually.', provider: s.provider, model: s.model } };
  }
  if (!s.categoryId) {
    return { ...common, state: 'needsReview', proposal: null, activity: { agentType: 'categorization', outcome: 'needsReview', summary: 'No confident category found; choose one manually.', provider: s.provider, model: s.model } };
  }
  return {
    ...common,
    state: 'needsReview',
    proposal: { categoryId: s.categoryId, confidence: s.confidence, question: s.question, evidenceIds: s.evidenceIds },
    activity: {
      agentType: 'categorization',
      outcome: 'proposed',
      summary: s.source === 'rule' ? 'Merchant rule supplied a category suggestion; review required.' : 'Category suggested; review required.',
      provider: s.provider,
      model: s.model,
    },
  };
}

/** Atomic per-item checkpoint verifying fence, revision and receipt uniqueness. */
async function checkpoint(
  scope: UserScope,
  d: DailyDeps,
  runId: string,
  fence: number,
  attemptId: string,
  tx: CanonicalRecord,
  item: CanonicalRecord,
  key: string,
  o: ItemOutcome,
): Promise<'written' | 'skipped' | 'leaseLost'> {
  return scope.store.runTransaction(async (t) => {
    const now = d.clock();
    const nowIso = now.toISOString();
    const lease = (await t.get(scope.doc('run_leases', runId))) as Lease | null;
    if (!lease || lease.fence !== fence || lease.ownerAttemptId !== attemptId) return 'leaseLost' as const;
    const current = (await t.get(scope.entityDoc('transaction', tx.id))) as CanonicalRecord | null;
    const review = (await t.get(scope.replicatedDoc('reviewState', tx.id))) as CanonicalRecord | null;
    const receipt = await t.get(scope.doc('work_receipts', key));
    if (!current || current.deletedAt !== null || current.revision !== tx.revision) return 'skipped' as const;
    if (!review || review.state !== 'queued' || review.transactionRevision !== tx.revision || receipt) return 'skipped' as const;
    const state = await readSyncState(t, scope);
    const proposalId = o.proposal ? deterministicId('proposal', key) : null;
    const activityId = deterministicId('activity', key);
    const prevActivity = (await t.get(scope.replicatedDoc('aiActivity', activityId))) as CanonicalRecord | null;
    const prevProposal = proposalId ? await t.get(scope.entityDoc('aiProposal', proposalId)) : null;

    const mutations = [];
    if (o.proposal && proposalId && !prevProposal) {
      const candidate = { transactionId: tx.id, baseRevision: tx.revision, categoryId: o.proposal.categoryId };
      mutations.push(
        mutation(
          'aiProposal',
          proposalRecord(
            proposalId,
            {
              kind: 'categoryChange',
              candidateJson: candidate,
              targetId: tx.id,
              targetRevision: tx.revision,
              confidence: o.proposal.confidence,
              fieldConfidence: { categoryId: o.proposal.confidence },
              questions: o.proposal.question ? [o.proposal.question] : [],
              evidenceIds: o.proposal.evidenceIds,
              expiresAt: new Date(now.getTime() + PROPOSAL_TTL_MS).toISOString(),
              agentRunId: runId,
            },
            nowIso,
          ),
        ),
      );
    }
    mutations.push(
      mutation(
        'aiActivity',
        activityRecord(
          activityId,
          { agentRunId: runId, agentType: o.activity.agentType, action: 'dailyReview', outcome: o.activity.outcome, summary: o.activity.summary, entityIds: [tx.id], proposalId, provider: o.activity.provider, model: o.activity.model, correlationId: d.requestId },
          nowIso,
          prevActivity,
        ),
      ),
      mutation('reviewState', newRecord(tx.id, { transactionRevision: tx.revision, state: o.state, proposalId, reviewedAt: o.state === 'reviewed' ? nowIso : null }, nowIso, review)),
    );
    publishChange(t, scope, state, mutations, { ledgerChanged: false, now: nowIso });
    t.set(scope.doc('work_receipts', key), { id: key, status: o.state, proposalId, runId, createdAt: nowIso });
    t.set(scope.doc('run_leases', runId), { ...lease, cursor: tx.id, leaseUntil: new Date(now.getTime() + LEASE_MS).toISOString() });
    return 'written' as const;
  });
}

async function finishRun(
  scope: UserScope,
  d: DailyDeps,
  runId: string,
  fence: number,
  attemptId: string,
  status: 'partial' | 'succeeded' | 'failed',
  businessDate: string,
  started: Date,
  counters: RunCounters,
): Promise<void> {
  await scope.store.runTransaction(async (t) => {
    const now = d.clock();
    const lease = (await t.get(scope.doc('run_leases', runId))) as Lease | null;
    if (!lease || lease.fence !== fence || lease.ownerAttemptId !== attemptId) return; // a successor owns the run
    const run = (await t.get(scope.replicatedDoc('agentRun', runId))) as CanonicalRecord | null;
    const state = await readSyncState(t, scope);
    const merged = mergeCounters(run, counters);
    publishChange(
      t,
      scope,
      state,
      [mutation('agentRun', agentRunRecord(runId, { agentType: 'dailyReview', businessDate, status, startedAt: (run?.startedAt as string) ?? started.toISOString(), endedAt: now.toISOString(), latencyMs: now.getTime() - started.getTime(), counters: merged }, now.toISOString(), run))],
      { ledgerChanged: false, now: now.toISOString() },
    );
    t.set(scope.doc('run_leases', runId), { ...lease, leaseUntil: now.toISOString() });
  });
}

async function writeRun(scope: UserScope, runId: string, status: 'skipped', businessDate: string, started: Date, now: Date, counters: RunCounters) {
  await scope.store.runTransaction(async (t) => {
    const run = (await t.get(scope.replicatedDoc('agentRun', runId))) as CanonicalRecord | null;
    if (run?.status === 'skipped') return;
    const state = await readSyncState(t, scope);
    publishChange(
      t,
      scope,
      state,
      [mutation('agentRun', agentRunRecord(runId, { agentType: 'dailyReview', businessDate, status, startedAt: started.toISOString(), endedAt: now.toISOString(), latencyMs: now.getTime() - started.getTime(), counters: mergeCounters(run, counters) }, now.toISOString(), run))],
      { ledgerChanged: false, now: now.toISOString() },
    );
  });
}

/** Bounded retention (docs/04 "Retention and recovery"); no Firestore TTL dependency. */
async function cleanup(scope: UserScope, now: Date): Promise<void> {
  const nowIso = now.toISOString();
  for (const col of ['rate_limits', 'ai_requests'] as const) {
    const old = await scope.store.query({ collectionPath: scope.collection(col), where: [['expiresAt', '<', nowIso]], limit: 50 });
    if (old.length === 0) continue;
    await scope.store.runTransaction(async (t) => {
      for (const r of old) t.delete(scope.doc(col, String(r.id)));
    });
  }

  // Pending proposals past expiry become stale; activity/runs >90 days and terminal proposals >30 days are tombstoned.
  const expired = (await scope.store.query({ collectionPath: scope.collection('ai_proposals'), where: [['status', '==', 'pending'], ['expiresAt', '<', nowIso]], limit: 30 })) as CanonicalRecord[];
  const cutoff90 = new Date(now.getTime() - 90 * 86_400_000).toISOString();
  const cutoff30 = new Date(now.getTime() - 30 * 86_400_000).toISOString();
  const oldActivity = (await scope.store.query({ collectionPath: scope.collection('ai_activity'), where: [['createdAt', '<', cutoff90]], limit: 30 })) as CanonicalRecord[];
  const oldRuns = (await scope.store.query({ collectionPath: scope.collection('agent_runs'), where: [['createdAt', '<', cutoff90]], limit: 30 })) as CanonicalRecord[];
  const oldProposals = (
    (await scope.store.query({ collectionPath: scope.collection('ai_proposals'), where: [['serverUpdatedAt', '<', cutoff30]], limit: 30 })) as CanonicalRecord[]
  ).filter((p) => p.status !== 'pending');

  const batches: Array<[string, CanonicalRecord[], (r: CanonicalRecord) => CanonicalRecord]> = [
    ['aiProposal', expired, (r) => ({ ...r, status: 'stale', revision: r.revision + 1, serverUpdatedAt: nowIso })],
    ['aiActivity', oldActivity.filter((r) => r.deletedAt === null), (r) => tombstone(r, nowIso)],
    ['agentRun', oldRuns.filter((r) => r.deletedAt === null), (r) => tombstone(r, nowIso)],
    ['aiProposal', oldProposals.filter((r) => r.deletedAt === null), (r) => tombstone(r, nowIso)],
  ];
  for (const [type, rows, fn] of batches) {
    if (rows.length === 0) continue;
    await scope.store.runTransaction(async (t) => {
      const fresh = (await Promise.all(rows.map((r) => t.get(scope.replicatedDoc(type as never, r.id))))) as Array<CanonicalRecord | null>;
      const state = await readSyncState(t, scope);
      const muts = fresh.filter((r): r is CanonicalRecord => r !== null && r.revision === rows.find((x) => x.id === r.id)?.revision).map((r) => mutation(type, fn(r)));
      if (muts.length > 0) publishChange(t, scope, state, muts, { ledgerChanged: false, now: nowIso });
    });
  }
}
