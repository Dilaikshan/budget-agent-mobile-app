import { deterministicId } from '../contracts/canonical.js';
import type { CanonicalRecord } from '../contracts/entities.js';
import { periodTotals, type LedgerTransaction } from '../domain/ledger.js';
import { addDays, addMonths, daysBetween, monthStart } from '../domain/time.js';
import { mutation, newRecord, publishChange, readSyncState } from '../sync/change-log.js';
import type { UserScope } from '../store/scope.js';
import { normalizeMerchant } from './rules.js';

/**
 * Deterministic insight facts (docs/06 "Daily agent algorithm", docs/09).
 * Numbers come from the ledger, never from a model. Trends need complete,
 * comparable periods; recurring patterns are suggestions, never schedules.
 */

export const AGENT_POLICY_VERSION = 'daily-v1';
const PAGE = 500;
const MAX_TRANSACTIONS = 10_000;

export interface InsightFacts {
  periodStart: string;
  periodEndExclusive: string;
  currency: string;
  expenseMinor: number;
  incomeMinor: number;
  comparisonExpenseMinor: number | null;
  occurrenceCount: number | null;
  medianIntervalDays: number | null;
}

export interface InsightDraft {
  id: string;
  kind: 'dailySummary' | 'spendingTrend' | 'recurringPattern' | 'consistency';
  businessDate: string;
  title: string;
  summary: string;
  evidenceTransactionIds: string[];
  facts: InsightFacts;
}

export async function loadLedgerWindow(
  scope: UserScope,
  from: string,
  deadlineAt: number,
  clock: () => Date,
): Promise<{ txs: LedgerTransaction[]; complete: boolean }> {
  const txs: LedgerTransaction[] = [];
  let after: unknown[] | undefined;
  while (txs.length < MAX_TRANSACTIONS) {
    if (clock().getTime() > deadlineAt) return { txs, complete: false };
    const rows = (await scope.store.query({
      collectionPath: scope.collection('transactions'),
      where: [['effectiveDate', '>=', from]],
      orderBy: [
        ['effectiveDate', 'asc'],
        ['id', 'asc'],
      ],
      startAfter: after,
      limit: PAGE,
    })) as CanonicalRecord[];
    for (const r of rows) {
      if (r.deletedAt === null) txs.push(r as unknown as LedgerTransaction);
    }
    if (rows.length < PAGE) return { txs, complete: true };
    const last = rows[rows.length - 1]!;
    after = [last.effectiveDate, last.id];
  }
  return { txs, complete: false };
}

export async function hasDataOnOrBefore(scope: UserScope, date: string): Promise<boolean> {
  const rows = await scope.store.query({
    collectionPath: scope.collection('transactions'),
    where: [['effectiveDate', '<=', date]],
    orderBy: [['effectiveDate', 'asc']],
    limit: 1,
  });
  return rows.length > 0;
}

export function formatMinor(minor: number, exponent: number, currency: string): string {
  const neg = minor < 0;
  const abs = String(Math.abs(minor)).padStart(exponent + 1, '0');
  const whole = abs.slice(0, abs.length - exponent).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const frac = exponent > 0 ? `.${abs.slice(-exponent)}` : '';
  return `${neg ? '-' : ''}${currency} ${whole}${frac}`;
}

function median(values: number[]): number {
  const s = [...values].sort((a, b) => a - b);
  const mid = Math.floor(s.length / 2);
  return s.length % 2 === 1 ? s[mid]! : Math.round((s[mid - 1]! + s[mid]!) / 2);
}

export function buildInsights(input: {
  txs: LedgerTransaction[];
  businessDate: string;
  currency: string;
  exponent: number;
  trendCoverage: boolean;
  scopeId: string;
}): InsightDraft[] {
  const { txs, businessDate, currency, exponent } = input;
  const money = (m: number) => formatMinor(m, exponent, currency);
  const drafts: InsightDraft[] = [];

  // Month-to-date summary through yesterday (complete days only).
  const mtdStart = monthStart(addDays(businessDate, -1));
  const mtd = periodTotals(txs, mtdStart, businessDate);
  const mtdEvidence = txs.filter((t) => (t.type === 'income' || t.type === 'expense') && t.effectiveDate >= mtdStart && t.effectiveDate < businessDate);
  drafts.push({
    id: deterministicId('dailySummary', businessDate, input.scopeId, AGENT_POLICY_VERSION),
    kind: 'dailySummary',
    businessDate,
    title: 'Month so far',
    summary: `From ${mtdStart} to ${addDays(businessDate, -1)}: spent ${money(mtd.expenseMinor)}, received ${money(mtd.incomeMinor)}. Transfers and opening balances are excluded.`,
    evidenceTransactionIds: mtdEvidence.slice(-20).map((t) => t.id),
    facts: { periodStart: mtdStart, periodEndExclusive: businessDate, currency, expenseMinor: mtd.expenseMinor, incomeMinor: mtd.incomeMinor, comparisonExpenseMinor: null, occurrenceCount: mtdEvidence.length, medianIntervalDays: null },
  });

  // Complete-month spending trend, once per month.
  const thisMonth = monthStart(businessDate);
  const prev = addMonths(thisMonth, -1);
  const prevPrev = addMonths(thisMonth, -2);
  if (input.trendCoverage) {
    const a = periodTotals(txs, prev, thisMonth);
    const b = periodTotals(txs, prevPrev, prev);
    const diff = a.expenseMinor - b.expenseMinor;
    drafts.push({
      id: deterministicId('spendingTrend', thisMonth, input.scopeId, AGENT_POLICY_VERSION),
      kind: 'spendingTrend',
      businessDate: thisMonth,
      title: 'Last month compared with the month before',
      summary: `Spending ${prev.slice(0, 7)}: ${money(a.expenseMinor)}; ${prevPrev.slice(0, 7)}: ${money(b.expenseMinor)} (${diff >= 0 ? 'up' : 'down'} ${money(Math.abs(diff))}).`,
      evidenceTransactionIds: txs.filter((t) => t.type === 'expense' && t.effectiveDate >= prevPrev && t.effectiveDate < thisMonth).slice(-20).map((t) => t.id),
      facts: { periodStart: prev, periodEndExclusive: thisMonth, currency, expenseMinor: a.expenseMinor, incomeMinor: a.incomeMinor, comparisonExpenseMinor: b.expenseMinor, occurrenceCount: null, medianIntervalDays: null },
    });
  }

  // Recurring patterns: same merchant/type, ≥3 in 90 days, weekly or monthly cadence, amounts ±10%.
  const since = addDays(businessDate, -90);
  const groups = new Map<string, LedgerTransaction[]>();
  for (const t of txs) {
    if (t.type !== 'expense' || !t.merchant || t.effectiveDate < since || t.effectiveDate >= businessDate) continue;
    const k = normalizeMerchant(t.merchant);
    groups.set(k, [...(groups.get(k) ?? []), t]);
  }
  for (const [merchantKey, list] of [...groups.entries()].sort((x, y) => x[0].localeCompare(y[0]))) {
    if (list.length < 3) continue;
    const sorted = [...list].sort((x, y) => x.effectiveDate.localeCompare(y.effectiveDate) || x.id.localeCompare(y.id));
    const intervals = sorted.slice(1).map((t, i) => daysBetween(sorted[i]!.effectiveDate, t.effectiveDate));
    const interval = median(intervals);
    const weekly = interval >= 5 && interval <= 9;
    const monthly = interval >= 25 && interval <= 35;
    if (!weekly && !monthly) continue;
    const amounts = sorted.map((t) => t.amountMinor);
    const med = median(amounts);
    if (!amounts.every((a) => Math.abs(a - med) * 10 <= med)) continue;
    drafts.push({
      id: deterministicId('recurringPattern', thisMonth, merchantKey, AGENT_POLICY_VERSION),
      kind: 'recurringPattern',
      businessDate: thisMonth,
      title: `Possible recurring expense: ${sorted[0]!.merchant!.slice(0, 50)}`,
      summary: `${sorted.length} payments about every ${interval} days, typically ${money(med)}. This is a suggestion only; nothing is scheduled.`,
      evidenceTransactionIds: sorted.slice(-20).map((t) => t.id),
      facts: { periodStart: since, periodEndExclusive: businessDate, currency, expenseMinor: med, incomeMinor: 0, comparisonExpenseMinor: null, occurrenceCount: sorted.length, medianIntervalDays: interval },
    });
  }
  return drafts;
}

/** Publishes drafts only if no ledger change happened after the captured watermark. */
export async function publishInsights(
  scope: UserScope,
  drafts: InsightDraft[],
  sourceWatermark: number,
  agentRunId: string,
  now: string,
): Promise<'published' | 'stale' | 'unchanged'> {
  if (drafts.length === 0) return 'unchanged';
  return scope.store.runTransaction(async (tx) => {
    const state = await readSyncState(tx, scope);
    if (state.lastLedgerSeq > sourceWatermark) return 'stale';
    const existing = await Promise.all(drafts.map((d) => tx.get(scope.entityDoc('aiInsight', d.id)))) as Array<CanonicalRecord | null>;
    const mutations = drafts.flatMap((d, i) => {
      const prev = existing[i] ?? null;
      if (prev && JSON.stringify(prev.facts) === JSON.stringify(d.facts) && JSON.stringify(prev.evidenceTransactionIds) === JSON.stringify(d.evidenceTransactionIds)) {
        return [];
      }
      // Regenerating a stable-ID insight preserves an existing dismissal.
      const status = prev?.status === 'dismissed' ? 'dismissed' : 'active';
      const { id, ...fields } = d;
      return [mutation('aiInsight', newRecord(id, { ...fields, sourceWatermark, status, agentRunId }, now, prev))];
    });
    if (mutations.length === 0) return 'unchanged';
    // Bounded per Change (byte limit); any remaining drafts publish on the next run.
    publishChange(tx, scope, state, mutations.slice(0, 20), { ledgerChanged: false, now });
    return 'published';
  });
}
