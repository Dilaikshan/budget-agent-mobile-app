import { openingTransactionId } from '../contracts/canonical.js';
import {
  PROFILE_ID,
  type AccountPayload,
  type AppSettingsPayload,
  type BudgetPayload,
  type CanonicalMutation,
  type CanonicalRecord,
  type CategorizationRulePayload,
  type CategoryPayload,
  type Change,
  type CreateAccountWithOpeningPayload,
  type IncomeSourcePayload,
  type ProfilePayload,
  type TransactionPayload,
} from '../contracts/entities.js';
import { localDateOf } from '../contracts/primitives.js';
import type { UserScope } from '../store/scope.js';
import type { StoreTransaction } from '../store/types.js';
import {
  ChangeTooLargeError,
  mutation,
  newRecord,
  publishChange,
  readSyncState,
  tombstone,
  type SyncState,
} from './change-log.js';
import { operationRequestHash, type ValidatedOperation } from './validate.js';

/**
 * Server sync protocol (docs/08-OFFLINE-SYNC.md, docs/05 "POST /api/v1/sync/push").
 * Each operation is its own Firestore transaction: receipt check, then revision
 * CAS, reference validation, canonical write, immutable Change and receipt.
 */

export type RejectCode =
  | 'VALIDATION_ERROR'
  | 'MISSING_REFERENCE'
  | 'ARCHIVED_REFERENCE'
  | 'STALE_PROPOSAL'
  | 'DEPENDENCY_FAILED'
  | 'IDEMPOTENCY_KEY_REUSED'
  | 'NOT_FOUND'
  | 'PAYLOAD_TOO_LARGE';

export type OperationResult =
  | { opId: string; status: 'accepted'; changes: CanonicalMutation[]; seq: number; replayed: boolean }
  | { opId: string; status: 'conflict'; code: 'REVISION_CONFLICT'; current: CanonicalRecord | null }
  | { opId: string; status: 'rejected'; code: RejectCode; retryable: boolean };

export interface ChangePage {
  changes: Change[];
  nextAfterSeq: number;
  watermark: number;
  hasMore: boolean;
}

export class InvalidCursorError extends Error {}

class Rejection extends Error {
  constructor(readonly code: RejectCode) {
    super(code);
  }
}

class Conflict extends Error {
  constructor(readonly current: CanonicalRecord | null) {
    super('REVISION_CONFLICT');
  }
}

interface Receipt {
  opId: string;
  requestHash: string;
  seq: number;
  acceptedChanges: Array<{ entityType: string; id: string; revision: number; seq: number }>;
  acceptedAt: string;
}

type RefKind = 'account' | 'category' | 'incomeSource';

export class SyncService {
  constructor(
    private readonly scope: UserScope,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async push(ops: ValidatedOperation[]): Promise<OperationResult[]> {
    const results: OperationResult[] = [];
    for (const v of ops) results.push(await this.processOne(v));
    return results;
  }

  async changes(afterSeq: number, watermark: number | undefined, limit: number): Promise<ChangePage> {
    const state = await this.scope.store.get(this.scope.syncStateDoc());
    const lastSeq = typeof state?.lastSeq === 'number' ? state.lastSeq : 0;
    if (afterSeq > lastSeq) throw new InvalidCursorError('afterSeq beyond lastSeq');
    const w = watermark ?? lastSeq;
    if (w > lastSeq || w < afterSeq) throw new InvalidCursorError('watermark out of range');
    const rows = await this.scope.store.query({
      collectionPath: this.scope.collection('changes'),
      where: [
        ['seq', '>', afterSeq],
        ['seq', '<=', w],
      ],
      orderBy: [['seq', 'asc']],
      limit,
    });
    const changes = rows as unknown as Change[];
    const nextAfterSeq = changes.length > 0 ? changes[changes.length - 1]!.seq : w;
    return { changes, nextAfterSeq, watermark: w, hasMore: nextAfterSeq < w };
  }

  private async processOne(v: ValidatedOperation): Promise<OperationResult> {
    const { op } = v;
    const requestHash = operationRequestHash(op);
    try {
      return await this.scope.store.runTransaction((tx) => this.inTransaction(tx, v, requestHash));
    } catch (e) {
      if (e instanceof Rejection) return { opId: op.opId, status: 'rejected', code: e.code, retryable: false };
      if (e instanceof Conflict) return { opId: op.opId, status: 'conflict', code: 'REVISION_CONFLICT', current: e.current };
      if (e instanceof ChangeTooLargeError) return { opId: op.opId, status: 'rejected', code: 'PAYLOAD_TOO_LARGE', retryable: false };
      throw e;
    }
  }

  private async inTransaction(tx: StoreTransaction, v: ValidatedOperation, requestHash: string): Promise<OperationResult> {
    const { op } = v;
    const s = this.scope;

    // 1. Receipt check precedes revision validation.
    const receipt = (await tx.get(s.doc('operation_receipts', op.opId))) as Receipt | null;
    if (receipt) {
      if (receipt.requestHash !== requestHash) throw new Rejection('IDEMPOTENCY_KEY_REUSED');
      const change = (await tx.get(s.changeDoc(receipt.seq))) as unknown as Change | null;
      if (!change) throw new Error('Receipt without change');
      return { opId: op.opId, status: 'accepted', changes: change.mutations, seq: receipt.seq, replayed: true };
    }

    const state = await readSyncState(tx, s);

    // 2. Resolve expected revision (explicit or from the predecessor's receipt).
    let expected: number;
    if (op.dependsOnOpId !== null) {
      const pred = (await tx.get(s.doc('operation_receipts', op.dependsOnOpId))) as Receipt | null;
      const entry = pred?.acceptedChanges.find((c) => c.entityType === op.entityType && c.id === op.entityId);
      if (!entry) throw new Rejection('DEPENDENCY_FAILED');
      expected = entry.revision;
    } else {
      expected = op.baseRevision ?? 0;
    }

    const current = (await tx.get(s.entityDoc(op.entityType, op.entityId))) as CanonicalRecord | null;
    const now = this.clock().toISOString();
    const ctx = new ReferenceReader(tx, s);

    // 3. Revision CAS. Tombstoned IDs can never be recreated.
    if (op.action === 'create' || op.action === 'createAccountWithOpening') {
      if (current) throw new Conflict(current);
    } else {
      if (!current) throw new Rejection('NOT_FOUND');
      if (current.deletedAt !== null || current.revision !== expected) throw new Conflict(current);
    }

    let built: Built;
    switch (op.action) {
      case 'createAccountWithOpening':
        built = await this.createAccountWithOpening(ctx, op.entityId, v.payload as CreateAccountWithOpeningPayload, now);
        break;
      case 'create':
      case 'update':
        built = await this.upsert(ctx, state, op.entityType, op.entityId, v.payload as Record<string, unknown>, current, now);
        break;
      case 'delete':
        built = await this.remove(ctx, op.entityType, current!, now);
        break;
      case 'dismissInsight':
        built = { mutations: [mutation('aiInsight', { ...current!, status: 'dismissed', revision: current!.revision + 1, serverUpdatedAt: now })], ledgerChanged: false };
        break;
      case 'rejectProposal':
        if (current!.status !== 'pending') throw new Rejection('STALE_PROPOSAL');
        built = { mutations: [mutation('aiProposal', { ...current!, status: 'rejected', revision: current!.revision + 1, serverUpdatedAt: now })], ledgerChanged: false };
        break;
    }

    // 4. Writes: records, Change, SyncState, receipt (all after reads).
    const { seq } = publishChange(tx, s, state, built.mutations, {
      ledgerChanged: built.ledgerChanged,
      now,
      lockCurrency: built.lockCurrency,
    });
    const newReceipt: Receipt = {
      opId: op.opId,
      requestHash,
      seq,
      acceptedChanges: built.mutations.map((m) => ({ entityType: m.entityType, id: m.id, revision: m.revision, seq })),
      acceptedAt: now,
    };
    tx.set(s.doc('operation_receipts', op.opId), { ...newReceipt });
    return { opId: op.opId, status: 'accepted', changes: built.mutations, seq, replayed: false };
  }

  private async createAccountWithOpening(
    ctx: ReferenceReader,
    accountId: string,
    p: CreateAccountWithOpeningPayload,
    now: string,
  ): Promise<Built> {
    const profile = await ctx.profile();
    if (p.account.currency !== profile.baseCurrency || p.account.archived) throw new Rejection('VALIDATION_ERROR');
    if (localDateOf(new Date(p.opening.occurredAt), p.opening.entryTimeZone) !== p.opening.effectiveDate) {
      throw new Rejection('VALIDATION_ERROR');
    }
    const openingId = openingTransactionId(accountId);
    if (await ctx.raw('transaction', openingId)) throw new Rejection('VALIDATION_ERROR');
    const existingReview = await ctx.reviewState(openingId);

    const account = newRecord(accountId, p.account, now, null);
    const signed = p.opening.signedOpeningMinor;
    const opening = newRecord(
      openingId,
      {
        type: 'opening',
        amountMinor: Math.abs(signed),
        currency: p.account.currency,
        accountId,
        destinationAccountId: null,
        incomeSourceId: null,
        categoryId: null,
        merchant: null,
        description: 'Opening balance',
        occurredAt: p.opening.occurredAt,
        effectiveDate: p.opening.effectiveDate,
        entryTimeZone: p.opening.entryTimeZone,
        origin: 'opening',
        categorizationSource: null,
        proposalId: null,
        openingDirection: signed < 0 ? 'debit' : 'credit',
      },
      now,
      null,
    );
    return {
      mutations: [
        mutation('account', account),
        mutation('transaction', opening),
        mutation('reviewState', reviewStateRecord(openingId, 1, 'reviewed', null, now, existingReview, now)),
      ],
      ledgerChanged: true,
      lockCurrency: true,
    };
  }

  private async upsert(
    ctx: ReferenceReader,
    state: SyncState,
    entityType: string,
    id: string,
    payload: Record<string, unknown>,
    current: CanonicalRecord | null,
    now: string,
  ): Promise<Built> {
    const mutations: CanonicalMutation[] = [];
    let ledgerChanged = false;

    switch (entityType) {
      case 'profile': {
        const p = payload as ProfilePayload;
        if (current && state.currencyLocked && (p.baseCurrency !== current.baseCurrency || p.currencyExponent !== current.currencyExponent)) {
          throw new Rejection('VALIDATION_ERROR');
        }
        break;
      }
      case 'account': {
        const p = payload as AccountPayload;
        if (p.type !== current!.type || p.currency !== current!.currency) throw new Rejection('VALIDATION_ERROR');
        break;
      }
      case 'incomeSource': {
        const p = payload as IncomeSourcePayload;
        if (current && p.type !== current.type) throw new Rejection('VALIDATION_ERROR');
        if (p.defaultAccountId !== null) await ctx.ref('account', p.defaultAccountId, current?.defaultAccountId);
        break;
      }
      case 'category': {
        const p = payload as CategoryPayload;
        if (current) {
          if (p.type !== current.type || p.parentId !== current.parentId) throw new Rejection('VALIDATION_ERROR');
        } else if (p.parentId !== null) {
          if (p.parentId === id) throw new Rejection('VALIDATION_ERROR');
          const parent = await ctx.ref('category', p.parentId, null);
          if (parent.type !== p.type || parent.parentId !== null) throw new Rejection('VALIDATION_ERROR');
        }
        break;
      }
      case 'transaction': {
        const p = payload as TransactionPayload;
        const txResult = await this.validateTransaction(ctx, id, p, current, now);
        mutations.push(...txResult.extra);
        ledgerChanged = true;
        const record = newRecord(id, p, now, current);
        mutations.unshift(mutation('transaction', record));
        const existingReview = await ctx.reviewState(id);
        mutations.push(
          mutation(
            'reviewState',
            reviewStateRecord(id, record.revision, txResult.reviewed ? 'reviewed' : 'queued', txResult.acceptedProposalId, txResult.reviewed ? now : null, existingReview, now),
          ),
        );
        return { mutations, ledgerChanged };
      }
      case 'categorizationRule': {
        const p = payload as CategorizationRulePayload;
        const cat = await ctx.ref('category', p.categoryId, current?.categoryId);
        if (cat.type !== p.transactionType) throw new Rejection('VALIDATION_ERROR');
        if (p.suggestedAccountId !== null) await ctx.ref('account', p.suggestedAccountId, current?.suggestedAccountId);
        if (p.suggestedIncomeSourceId !== null) {
          if (p.transactionType !== 'income') throw new Rejection('VALIDATION_ERROR');
          await ctx.ref('incomeSource', p.suggestedIncomeSourceId, current?.suggestedIncomeSourceId);
        }
        for (const evidenceId of p.evidenceTransactionIds) {
          // Evidence may be historical or tombstoned but must belong to this user.
          if (!(await ctx.raw('transaction', evidenceId))) throw new Rejection('MISSING_REFERENCE');
        }
        break;
      }
      case 'budget': {
        const p = payload as BudgetPayload;
        const profile = await ctx.profile();
        if (p.currency !== profile.baseCurrency) throw new Rejection('VALIDATION_ERROR');
        const cat = await ctx.ref('category', p.categoryId, current?.categoryId);
        if (cat.type !== 'expense') throw new Rejection('VALIDATION_ERROR');
        await this.assertBudgetNonOverlap(ctx, id, p, cat);
        break;
      }
      case 'appSettings': {
        const p = payload as AppSettingsPayload;
        if (p.defaultExpenseAccountId !== null) await ctx.ref('account', p.defaultExpenseAccountId, current?.defaultExpenseAccountId);
        break;
      }
      default:
        throw new Rejection('VALIDATION_ERROR');
    }

    mutations.push(mutation(entityType, newRecord(id, payload, now, current)));
    return { mutations, ledgerChanged };
  }

  private async validateTransaction(
    ctx: ReferenceReader,
    id: string,
    p: TransactionPayload,
    current: CanonicalRecord | null,
    now: string,
  ): Promise<{ extra: CanonicalMutation[]; reviewed: boolean; acceptedProposalId: string | null }> {
    const profile = await ctx.profile();
    if (p.currency !== profile.baseCurrency) throw new Rejection('VALIDATION_ERROR');

    // Opening entries keep their type/account; ordinary entries can never become openings.
    const wasOpening = current?.type === 'opening';
    if (wasOpening !== (p.type === 'opening')) throw new Rejection('VALIDATION_ERROR');
    if (p.type === 'opening') {
      if (p.accountId !== current!.accountId) throw new Rejection('VALIDATION_ERROR');
      await ctx.ref('account', p.accountId, current!.accountId, p.currency);
      return { extra: [], reviewed: true, acceptedProposalId: null };
    }

    await ctx.ref('account', p.accountId, current?.accountId, p.currency);
    if (p.type === 'transfer') {
      await ctx.ref('account', p.destinationAccountId, current?.destinationAccountId, p.currency);
    }
    if (p.categoryId !== null) {
      const cat = await ctx.ref('category', p.categoryId, current?.categoryId);
      if (cat.type !== p.type) throw new Rejection('VALIDATION_ERROR');
    }
    if (p.type === 'income') await ctx.ref('incomeSource', p.incomeSourceId, current?.incomeSourceId);

    // Proposal binding only when a new proposal is being accepted.
    const extra: CanonicalMutation[] = [];
    let acceptedProposalId: string | null = null;
    if (p.proposalId !== null && p.proposalId !== (current?.proposalId ?? null)) {
      const proposal = await ctx.raw('aiProposal', p.proposalId);
      const valid =
        proposal !== null &&
        proposal.deletedAt === null &&
        proposal.status === 'pending' &&
        typeof proposal.expiresAt === 'string' &&
        proposal.expiresAt > now &&
        (current === null
          ? proposal.kind === 'transaction'
          : proposal.kind === 'categoryChange' && proposal.targetId === id && proposal.targetRevision === current.revision);
      if (!valid) throw new Rejection('STALE_PROPOSAL');
      extra.push(mutation('aiProposal', { ...proposal, status: 'accepted', revision: proposal.revision + 1, serverUpdatedAt: now }));
      acceptedProposalId = p.proposalId;
    }
    // A user-confirmed accepted proposal with a category needs no re-review; everything else is queued.
    const reviewed = acceptedProposalId !== null && p.type !== 'transfer' && p.categoryId !== null;
    return { extra, reviewed, acceptedProposalId };
  }

  private async assertBudgetNonOverlap(ctx: ReferenceReader, id: string, p: BudgetPayload, cat: CanonicalRecord) {
    const others = (
      await ctx.tx.query({
        collectionPath: ctx.scope.collection('budgets'),
        where: [['month', '==', p.month]],
        limit: 200,
      })
    ).filter((b) => b.id !== id && b.deletedAt === null) as CanonicalRecord[];
    for (const other of others) {
      if (other.categoryId === p.categoryId || other.categoryId === cat.parentId) throw new Rejection('VALIDATION_ERROR');
      const otherCat = await ctx.raw('category', String(other.categoryId));
      if (otherCat?.parentId === p.categoryId) throw new Rejection('VALIDATION_ERROR');
    }
  }

  private async remove(ctx: ReferenceReader, entityType: string, current: CanonicalRecord, now: string): Promise<Built> {
    if (entityType === 'transaction') {
      if (current.type === 'opening') throw new Rejection('VALIDATION_ERROR');
      const review = await ctx.reviewState(current.id);
      const mutations = [mutation('transaction', tombstone(current, now))];
      if (review && review.deletedAt === null) mutations.push(mutation('reviewState', tombstone(review, now)));
      return { mutations, ledgerChanged: true };
    }
    return { mutations: [mutation(entityType, tombstone(current, now))], ledgerChanged: false };
  }
}

interface Built {
  mutations: CanonicalMutation[];
  ledgerChanged: boolean;
  lockCurrency?: boolean;
}

function reviewStateRecord(
  transactionId: string,
  transactionRevision: number,
  state: 'queued' | 'reviewed' | 'needsReview',
  proposalId: string | null,
  reviewedAt: string | null,
  previous: CanonicalRecord | null,
  now: string,
): CanonicalRecord {
  return newRecord(transactionId, { transactionRevision, state, proposalId, reviewedAt }, now, previous);
}

/** Reads (and caches) referenced records inside the transaction, before any write. */
class ReferenceReader {
  private readonly cache = new Map<string, CanonicalRecord | null>();

  constructor(
    readonly tx: StoreTransaction,
    readonly scope: UserScope,
  ) {}

  async raw(entityType: 'account' | 'category' | 'incomeSource' | 'transaction' | 'aiProposal' | 'profile', id: string) {
    const key = `${entityType}/${id}`;
    if (!this.cache.has(key)) {
      this.cache.set(key, (await this.tx.get(this.scope.entityDoc(entityType, id))) as CanonicalRecord | null);
    }
    return this.cache.get(key)!;
  }

  async reviewState(transactionId: string): Promise<CanonicalRecord | null> {
    return (await this.tx.get(this.scope.replicatedDoc('reviewState', transactionId))) as CanonicalRecord | null;
  }

  async profile(): Promise<CanonicalRecord> {
    const p = await this.raw('profile', PROFILE_ID);
    if (!p || p.deletedAt !== null) throw new Rejection('MISSING_REFERENCE');
    return p;
  }

  /**
   * Existing, non-deleted reference. A newly selected archived reference is
   * rejected; an edit retaining the same archived reference is allowed.
   */
  async ref(kind: RefKind, id: string, previousId: unknown, currency?: string): Promise<CanonicalRecord> {
    const r = await this.raw(kind, id);
    if (!r || r.deletedAt !== null) throw new Rejection('MISSING_REFERENCE');
    if (r.archived === true && id !== previousId) throw new Rejection('ARCHIVED_REFERENCE');
    if (currency !== undefined && r.currency !== currency) throw new Rejection('VALIDATION_ERROR');
    return r;
  }
}
