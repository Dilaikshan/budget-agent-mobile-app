import type { Attempt } from '../ai/router.js';
import type { CanonicalRecord } from '../contracts/entities.js';
import { newRecord } from '../sync/change-log.js';

/** AgentRun / AIActivity / AIProposal record builders (docs/04, docs/11). */

export type AgentType =
  | 'transactionParsing'
  | 'categorization'
  | 'accountSuggestion'
  | 'dailyReview'
  | 'patternLearning'
  | 'insight'
  | 'recurringDetection'
  | 'consistencyCheck';

export interface SafeError {
  code: string;
  retryable: boolean;
  attemptId: string | null;
}

export interface RunCounters {
  attemptCount: number;
  transactionCount: number;
  ruleMatches: number;
  llmCalls: number;
  fallbackCount: number;
  manualReviewCount: number;
  inputTokens: number | null;
  outputTokens: number | null;
  errors: SafeError[];
  providerAttempts: Attempt[];
}

export function emptyCounters(): RunCounters {
  return {
    attemptCount: 0,
    transactionCount: 0,
    ruleMatches: 0,
    llmCalls: 0,
    fallbackCount: 0,
    manualReviewCount: 0,
    inputTokens: 0,
    outputTokens: 0,
    errors: [],
    providerAttempts: [],
  };
}

/** Adds attempts; any unknown usage makes the aggregate unknown (null), never zero. */
export function addAttempts(c: RunCounters, attempts: Attempt[]): void {
  for (const a of attempts) {
    c.llmCalls++;
    if (a.provider === 'openrouter') c.fallbackCount++;
    c.inputTokens = c.inputTokens === null || a.inputTokens === null ? null : c.inputTokens + a.inputTokens;
    c.outputTokens = c.outputTokens === null || a.outputTokens === null ? null : c.outputTokens + a.outputTokens;
    if (a.errorCode) c.errors.push({ code: a.errorCode.slice(0, 80), retryable: true, attemptId: a.attemptId });
  }
  c.providerAttempts = [...c.providerAttempts, ...attempts].slice(-20);
  c.errors = c.errors.slice(-20);
}

export function mergeCounters(previous: CanonicalRecord | null, c: RunCounters): RunCounters {
  if (!previous) return c;
  const n = (k: keyof RunCounters) => (typeof previous[k] === 'number' ? (previous[k] as number) : 0);
  const tok = (k: 'inputTokens' | 'outputTokens') => (previous[k] === null || c[k] === null ? null : n(k) + (c[k] as number));
  return {
    attemptCount: n('attemptCount') + c.attemptCount,
    transactionCount: n('transactionCount') + c.transactionCount,
    ruleMatches: n('ruleMatches') + c.ruleMatches,
    llmCalls: n('llmCalls') + c.llmCalls,
    fallbackCount: n('fallbackCount') + c.fallbackCount,
    manualReviewCount: n('manualReviewCount') + c.manualReviewCount,
    inputTokens: tok('inputTokens'),
    outputTokens: tok('outputTokens'),
    errors: [...((previous.errors as SafeError[]) ?? []), ...c.errors].slice(-20),
    providerAttempts: [...((previous.providerAttempts as Attempt[]) ?? []), ...c.providerAttempts].slice(-20),
  };
}

export function agentRunRecord(
  id: string,
  fields: {
    agentType: AgentType;
    businessDate: string | null;
    status: 'running' | 'partial' | 'succeeded' | 'failed' | 'skipped';
    startedAt: string;
    endedAt: string | null;
    latencyMs: number;
    counters: RunCounters;
  },
  now: string,
  previous: CanonicalRecord | null,
): CanonicalRecord {
  const { counters, ...rest } = fields;
  return newRecord(id, { ...rest, ...counters }, now, previous);
}

export function activityRecord(
  id: string,
  fields: {
    agentRunId: string | null;
    agentType: AgentType;
    action: string;
    outcome: 'proposed' | 'applied' | 'skipped' | 'failed' | 'needsReview';
    summary: string;
    entityIds: string[];
    proposalId: string | null;
    provider: string | null;
    model: string | null;
    correlationId: string;
  },
  now: string,
  previous: CanonicalRecord | null,
): CanonicalRecord {
  return newRecord(id, { ...fields, summary: fields.summary.slice(0, 500), entityIds: fields.entityIds.slice(0, 20) }, now, previous);
}

export function proposalRecord(
  id: string,
  fields: {
    kind: 'transaction' | 'categoryChange' | 'rule';
    candidateJson: Record<string, unknown>;
    targetId: string | null;
    targetRevision: number | null;
    confidence: number;
    fieldConfidence: Record<string, number>;
    questions: string[];
    evidenceIds: string[];
    expiresAt: string;
    agentRunId: string;
  },
  now: string,
): CanonicalRecord {
  return newRecord(
    id,
    { ...fields, status: 'pending', questions: fields.questions.slice(0, 5), evidenceIds: fields.evidenceIds.slice(0, 5) },
    now,
    null,
  );
}
