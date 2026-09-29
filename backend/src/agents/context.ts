import { PROFILE_ID, SETTINGS_ID, type CanonicalRecord } from '../contracts/entities.js';
import { addDays } from '../domain/time.js';
import type { UserScope } from '../store/scope.js';
import type { AccountRef, CategoryRef, ParseContext, RuleRef, SourceRef } from './rules.js';

/** UID-scoped canonical context for agents; clients never submit reference lists. */

export interface OwnerState {
  profile: CanonicalRecord | null;
  settings: CanonicalRecord | null;
  lastSeq: number;
  lastLedgerSeq: number;
}

export async function loadOwnerState(scope: UserScope): Promise<OwnerState> {
  const [profile, settings, state] = await Promise.all([
    scope.store.get(scope.entityDoc('profile', PROFILE_ID)),
    scope.store.get(scope.entityDoc('appSettings', SETTINGS_ID)),
    scope.store.get(scope.syncStateDoc()),
  ]);
  const live = (r: unknown) => (r && (r as CanonicalRecord).deletedAt === null ? (r as CanonicalRecord) : null);
  return {
    profile: live(profile),
    settings: live(settings),
    lastSeq: typeof state?.lastSeq === 'number' ? state.lastSeq : 0,
    lastLedgerSeq: typeof state?.lastLedgerSeq === 'number' ? state.lastLedgerSeq : 0,
  };
}

async function activeRecords(scope: UserScope, collection: 'accounts' | 'categories' | 'income_sources', limit: number) {
  const rows = (await scope.store.query({ collectionPath: scope.collection(collection), where: [['archived', '==', false]], limit })) as CanonicalRecord[];
  return rows.filter((r) => r.deletedAt === null);
}

export async function loadParseContext(scope: UserScope, currencyExponent: number): Promise<ParseContext> {
  const [accounts, categories, sources, rules] = await Promise.all([
    activeRecords(scope, 'accounts', 50),
    activeRecords(scope, 'categories', 200),
    activeRecords(scope, 'income_sources', 100),
    scope.store.query({
      collectionPath: scope.collection('categorization_rules'),
      where: [['enabled', '==', true]],
      orderBy: [['priority', 'desc']],
      limit: 200,
    }) as Promise<CanonicalRecord[]>,
  ]);
  return {
    accounts: accounts.map((a) => ({ id: a.id, name: String(a.name), type: a.type as AccountRef['type'] })),
    categories: categories.map((c) => ({ id: c.id, name: String(c.name), type: c.type as CategoryRef['type'], parentId: (c.parentId as string | null) ?? null })),
    sources: sources.map((s) => ({ id: s.id, name: String(s.name), type: s.type as SourceRef['type'], defaultAccountId: (s.defaultAccountId as string | null) ?? null })),
    rules: rules
      .filter((r) => r.deletedAt === null)
      .map((r) => ({
        id: r.id,
        matchKind: r.matchKind as RuleRef['matchKind'],
        normalizedPattern: String(r.normalizedPattern),
        transactionType: r.transactionType as RuleRef['transactionType'],
        categoryId: String(r.categoryId),
        suggestedAccountId: (r.suggestedAccountId as string | null) ?? null,
        suggestedIncomeSourceId: (r.suggestedIncomeSourceId as string | null) ?? null,
        priority: Number(r.priority),
      })),
    currencyExponent,
  };
}

/**
 * History suggestion (docs/06 rule 4): ≤20 recent same-type confirmed
 * transactions in 90 days with the same merchant; ≥3 matches and ≥90% agreement.
 */
export async function historyCategory(
  scope: UserScope,
  merchant: string,
  type: 'income' | 'expense',
  today: string,
  excludeId: string | null = null,
): Promise<{ categoryId: string; evidenceIds: string[] } | null> {
  const since = addDays(today, -90);
  const rows = (await scope.store.query({
    collectionPath: scope.collection('transactions'),
    where: [
      ['merchant', '==', merchant],
      ['deletedAt', '==', null],
    ],
    orderBy: [['effectiveDate', 'desc']],
    limit: 20,
  })) as CanonicalRecord[];
  const relevant = rows.filter((r) => r.type === type && r.id !== excludeId && String(r.effectiveDate) >= since && r.categoryId);
  if (relevant.length < 3) return null;
  const counts = new Map<string, string[]>();
  for (const r of relevant) {
    const k = String(r.categoryId);
    counts.set(k, [...(counts.get(k) ?? []), r.id]);
  }
  const [best] = [...counts.entries()].sort((a, b) => b[1].length - a[1].length);
  if (!best || best[1].length / relevant.length < 0.9) return null;
  return { categoryId: best[0], evidenceIds: best[1].slice(0, 5) };
}

/** Agent routes additionally require aiEnabled and eligible provider consent (docs/05). */
export function consentStatus(settings: CanonicalRecord | null, policyVersion: string): 'ok' | 'disabled' | 'noConsent' {
  if (!settings || settings.aiEnabled !== true) return 'disabled';
  if (!settings.providerConsentAt || settings.privacyPolicyVersion !== policyVersion) return 'noConsent';
  return 'ok';
}
