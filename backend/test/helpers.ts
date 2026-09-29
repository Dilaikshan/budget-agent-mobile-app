import crypto from 'node:crypto';
import type { Operation } from '../src/contracts/api.js';
import { canonicalHash } from '../src/contracts/canonical.js';
import { MemoryStore } from '../src/store/memory.js';
import { UserScope } from '../src/store/scope.js';
import { SyncService, type OperationResult } from '../src/sync/service.js';
import { confirmationHashInput, validateBatch } from '../src/sync/validate.js';

export const OWNER = 'ownerUid123';
export const OTHER = 'otherUid456';
export const T0 = new Date('2026-09-09T08:00:00.000Z');

export function uuid(): string {
  return crypto.randomUUID();
}

export function setup(uid = OWNER, store = new MemoryStore()) {
  let now = T0.getTime();
  const clock = () => new Date(now);
  const scope = new UserScope({ uid, source: 'idToken' }, store);
  const sync = new SyncService(scope, clock);
  return {
    store,
    scope,
    sync,
    clock,
    advance: (ms: number) => void (now += ms),
    async push(...ops: Operation[]): Promise<OperationResult[]> {
      const v = validateBatch(ops);
      if ('errors' in v) throw new Error(`validation: ${JSON.stringify(v.errors)}`);
      return sync.push(v.ok);
    },
  };
}

/** Build an operation with a correct confirmation hash (as the mobile client does). */
export function op(partial: Omit<Operation, 'opId' | 'confirmation' | 'dependsOnOpId'> & { opId?: string; dependsOnOpId?: string | null; confirm?: boolean }): Operation {
  const base: Operation = {
    opId: partial.opId ?? uuid(),
    entityType: partial.entityType,
    entityId: partial.entityId,
    action: partial.action,
    baseRevision: partial.baseRevision,
    dependsOnOpId: partial.dependsOnOpId ?? null,
    payload: partial.payload,
    confirmation: null,
  };
  if (partial.confirm === false) return base;
  return {
    ...base,
    confirmation: {
      confirmedAt: '2026-09-09T07:59:00.000Z',
      payloadHash: canonicalHash(confirmationHashInput(base)),
      expectedLocalVersion: 1,
      predecessorOpId: base.dependsOnOpId,
    },
  };
}

export const profilePayload = {
  displayName: 'Me',
  baseCurrency: 'LKR',
  currencyExponent: 2,
  timeZone: 'Asia/Colombo',
  onboardingComplete: false,
};

export const settingsPayload = {
  theme: 'system',
  aiEnabled: true,
  dailyReviewEnabled: true,
  learningEnabled: true,
  fallbackEnabled: true,
  privacyPolicyVersion: 'pp-2026-09',
  providerConsentAt: '2026-09-01T00:00:00.000Z',
  defaultExpenseAccountId: null,
};

export function account(name: string, type: 'bank' | 'cash' | 'wallet' | 'savings', signedOpeningMinor: number, id = uuid()) {
  return op({
    entityType: 'account',
    entityId: id,
    action: 'createAccountWithOpening',
    baseRevision: 0,
    payload: {
      account: { name, type, currency: 'LKR', archived: false, sortOrder: 0 },
      opening: { signedOpeningMinor, occurredAt: '2026-09-01T06:30:00.000Z', effectiveDate: '2026-09-01', entryTimeZone: 'Asia/Colombo' },
    },
  });
}

export function category(name: string, type: 'income' | 'expense', parentId: string | null = null, id = uuid()) {
  return op({
    entityType: 'category',
    entityId: id,
    action: 'create',
    baseRevision: 0,
    payload: { name, type, parentId, icon: null, sortOrder: 0, isSystem: false, archived: false },
  });
}

export function source(name: string, type: 'employer' | 'freelance', id = uuid()) {
  return op({ entityType: 'incomeSource', entityId: id, action: 'create', baseRevision: 0, payload: { name, type, defaultAccountId: null, archived: false } });
}

export function txPayload(p: Partial<Record<string, unknown>> & { type: string; amountMinor: number; accountId: string }) {
  return {
    currency: 'LKR',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: null,
    merchant: null,
    description: '',
    occurredAt: '2026-09-09T06:30:00.000Z',
    effectiveDate: '2026-09-09',
    entryTimeZone: 'Asia/Colombo',
    origin: 'manual',
    categorizationSource: null,
    proposalId: null,
    openingDirection: null,
    ...p,
  };
}

export function createTx(payload: Record<string, unknown>, id = uuid()) {
  return op({ entityType: 'transaction', entityId: id, action: 'create', baseRevision: 0, payload });
}

/** Seed profile + settings + Cash/Bank accounts with openings; returns IDs. */
export async function seedLedger(env: ReturnType<typeof setup>) {
  const cash = uuid();
  const bank = uuid();
  const food = uuid();
  const restaurant = uuid();
  const salary = uuid();
  const employer = uuid();
  const results = await env.push(
    op({ entityType: 'profile', entityId: 'profile', action: 'create', baseRevision: 0, payload: profilePayload }),
    op({ entityType: 'appSettings', entityId: 'settings', action: 'create', baseRevision: 0, payload: settingsPayload }),
    account('Cash Wallet', 'cash', 500000, cash),
    account('Commercial Bank', 'bank', 10000000, bank),
    category('Food', 'expense', null, food),
    category('Salary', 'income', null, salary),
    source('Acme Employer', 'employer', employer),
  );
  const r2 = await env.push(category('Restaurant', 'expense', food, restaurant));
  for (const r of [...results, ...r2]) if (r.status !== 'accepted') throw new Error(`seed failed: ${JSON.stringify(r)}`);
  return { cash, bank, food, restaurant, salary, employer };
}
