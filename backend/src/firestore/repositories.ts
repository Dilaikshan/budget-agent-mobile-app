import crypto from 'node:crypto';
import admin from 'firebase-admin';
import { getFirebaseAdmin, AuthContext } from '../auth/guards.js';
import { Operation, EntityType } from '../contracts/schemas.js';

export interface CanonicalRecord {
  id: string;
  schemaVersion: 1;
  revision: number;
  createdAt: string;
  serverUpdatedAt: string;
  deletedAt: string | null;
  [key: string]: unknown;
}

export interface CanonicalMutation {
  entityType: EntityType;
  id: string;
  revision: number;
  record: CanonicalRecord;
}

export interface OperationReceipt {
  opId: string;
  requestHash: string;
  acceptedChanges: Array<{
    entityType: EntityType;
    id: string;
    revision: number;
    seq: number;
  }>;
  acceptedAt: string;
}

export class ScopedFirestoreRepository {
  private uid: string;
  private db: admin.firestore.Firestore;

  constructor(auth: AuthContext) {
    this.uid = auth.uid;
    this.db = getFirebaseAdmin().firestore();
  }

  private userDoc() {
    return this.db.collection('users').doc(this.uid);
  }

  private getCollectionName(entityType: EntityType): string {
    switch (entityType) {
      case 'profile':
        return 'profiles';
      case 'account':
        return 'accounts';
      case 'incomeSource':
        return 'income_sources';
      case 'category':
        return 'categories';
      case 'transaction':
        return 'transactions';
      case 'categorizationRule':
        return 'categorization_rules';
      case 'budget':
        return 'budgets';
      case 'appSettings':
        return 'app_settings';
      case 'aiInsight':
        return 'ai_insights';
      case 'aiProposal':
        return 'ai_proposals';
    }
  }

  // Check if operation was previously accepted and can be replayed idempotently
  async getReceipt(opId: string): Promise<OperationReceipt | null> {
    const snap = await this.userDoc().collection('operation_receipts').doc(opId).get();
    if (!snap.exists) return null;
    return snap.data() as OperationReceipt;
  }

  // Get current entity record and its revision
  async getEntity(entityType: EntityType, entityId: string): Promise<CanonicalRecord | null> {
    const colName = this.getCollectionName(entityType);
    const snap = await this.userDoc().collection(colName).doc(entityId).get();
    if (!snap.exists) return null;
    return snap.data() as CanonicalRecord;
  }

  // Process atomic operation in Firestore transaction
  async executeOperation(
    op: Operation,
    requestHash: string
  ): Promise<
    | { status: 'accepted'; changes: CanonicalMutation[]; seq: number; replayed: boolean }
    | { status: 'conflict'; code: string; current: CanonicalRecord | null }
    | { status: 'rejected'; code: string; retryable: boolean }
  > {
    // 1. Receipt check first
    const existingReceipt = await this.getReceipt(op.opId);
    if (existingReceipt) {
      // Operation already processed, return idempotent replay
      const primary = existingReceipt.acceptedChanges[0];
      return {
        status: 'accepted',
        changes: [],
        seq: primary?.seq || 0,
        replayed: true,
      };
    }

    const now = new Date().toISOString();

    return await this.db.runTransaction(async (t) => {
      const syncStateRef = this.userDoc().collection('sync_meta').doc('state');
      const syncStateSnap = await t.get(syncStateRef);
      let lastSeq = 0;
      let lastLedgerSeq = 0;
      if (syncStateSnap.exists) {
        const d = syncStateSnap.data()!;
        lastSeq = d.lastSeq || 0;
        lastLedgerSeq = d.lastLedgerSeq || 0;
      }

      // Handle Compound createAccountWithOpening
      if (op.action === 'createAccountWithOpening') {
        const payload = op.payload as any;
        const accountPayload = payload?.account;
        const openingPayload = payload?.opening;

        if (!accountPayload || !openingPayload) {
          return { status: 'rejected', code: 'VALIDATION_ERROR', retryable: false };
        }

        const accountRef = this.userDoc().collection('accounts').doc(op.entityId);
        const accountSnap = await t.get(accountRef);
        if (accountSnap.exists) {
          return {
            status: 'conflict',
            code: 'REVISION_CONFLICT',
            current: accountSnap.data() as CanonicalRecord,
          };
        }

        const newSeq = lastSeq + 1;
        const accountRecord: CanonicalRecord = {
          id: op.entityId,
          schemaVersion: 1,
          revision: 1,
          createdAt: now,
          serverUpdatedAt: now,
          deletedAt: null,
          ...accountPayload,
        };

        // Derived deterministic opening transaction ID
        const openingId = crypto
          .createHash('sha256')
          .update('opening:' + op.entityId)
          .digest('hex')
          .substring(0, 32);

        const signedAmount = openingPayload.signedOpeningMinor || 0;
        const openingDirection = signedAmount < 0 ? 'debit' : 'credit';
        const absAmount = Math.abs(signedAmount);

        const openingRecord: CanonicalRecord = {
          id: openingId,
          schemaVersion: 1,
          revision: 1,
          createdAt: now,
          serverUpdatedAt: now,
          deletedAt: null,
          type: 'opening',
          amountMinor: absAmount,
          currency: accountPayload.currency,
          accountId: op.entityId,
          destinationAccountId: null,
          incomeSourceId: null,
          categoryId: null,
          merchant: null,
          description: `Opening balance for ${accountPayload.name}`,
          occurredAt: openingPayload.occurredAt || now,
          effectiveDate: openingPayload.effectiveDate || now.slice(0, 10),
          entryTimeZone: openingPayload.entryTimeZone || 'Asia/Colombo',
          origin: 'opening',
          categorizationSource: null,
          proposalId: null,
          openingDirection,
        };

        const openingRef = this.userDoc().collection('transactions').doc(openingId);

        // Commit both entities
        t.set(accountRef, accountRecord);
        t.set(openingRef, openingRecord);

        // Commit immutable Change
        const changeRef = this.userDoc().collection('changes').doc(String(newSeq));
        const mutations: CanonicalMutation[] = [
          { entityType: 'account', id: op.entityId, revision: 1, record: accountRecord },
          { entityType: 'transaction', id: openingId, revision: 1, record: openingRecord },
        ];
        t.set(changeRef, {
          seq: newSeq,
          ledgerChanged: true,
          mutations,
          committedAt: now,
        });

        // Update sync state
        t.set(syncStateRef, { lastSeq: newSeq, lastLedgerSeq: newSeq });

        // Save receipt
        const receiptRef = this.userDoc().collection('operation_receipts').doc(op.opId);
        t.set(receiptRef, {
          opId: op.opId,
          requestHash,
          acceptedChanges: [
            { entityType: 'account', id: op.entityId, revision: 1, seq: newSeq },
            { entityType: 'transaction', id: openingId, revision: 1, seq: newSeq },
          ],
          acceptedAt: now,
        });

        return {
          status: 'accepted',
          changes: mutations,
          seq: newSeq,
          replayed: false,
        };
      }

      // Standard create / update / delete / dismiss / reject
      const colName = this.getCollectionName(op.entityType);
      const entityRef = this.userDoc().collection(colName).doc(op.entityId);
      const currentSnap = await t.get(entityRef);
      const currentData = currentSnap.exists ? (currentSnap.data() as CanonicalRecord) : null;

      // CAS check: compare expected revision
      const currentRev = currentData ? currentData.revision : 0;
      if (op.baseRevision !== null && op.baseRevision !== currentRev) {
        return {
          status: 'conflict',
          code: 'REVISION_CONFLICT',
          current: currentData,
        };
      }

      const nextRev = currentRev + 1;
      const newSeq = lastSeq + 1;
      let nextRecord: CanonicalRecord;

      if (op.action === 'delete') {
        if (!currentData) {
          return { status: 'rejected', code: 'NOT_FOUND', retryable: false };
        }
        nextRecord = {
          ...currentData,
          revision: nextRev,
          serverUpdatedAt: now,
          deletedAt: now,
        };
        t.set(entityRef, nextRecord);
      } else if (op.action === 'dismissInsight') {
        nextRecord = {
          ...(currentData || { id: op.entityId, schemaVersion: 1, createdAt: now }),
          status: 'dismissed',
          revision: nextRev,
          serverUpdatedAt: now,
          deletedAt: null,
        };
        t.set(entityRef, nextRecord);
      } else if (op.action === 'rejectProposal') {
        nextRecord = {
          ...(currentData || { id: op.entityId, schemaVersion: 1, createdAt: now }),
          status: 'rejected',
          revision: nextRev,
          serverUpdatedAt: now,
          deletedAt: null,
        };
        t.set(entityRef, nextRecord);
      } else {
        // create or update
        nextRecord = {
          id: op.entityId,
          schemaVersion: 1,
          revision: nextRev,
          createdAt: currentData ? currentData.createdAt : now,
          serverUpdatedAt: now,
          deletedAt: null,
          ...(op.payload || {}),
        };
        t.set(entityRef, nextRecord);
      }

      const isLedgerChange =
        op.entityType === 'transaction' || op.entityType === 'account';

      const mutation: CanonicalMutation = {
        entityType: op.entityType,
        id: op.entityId,
        revision: nextRev,
        record: nextRecord,
      };

      // Immutable change entry
      const changeRef = this.userDoc().collection('changes').doc(String(newSeq));
      t.set(changeRef, {
        seq: newSeq,
        ledgerChanged: isLedgerChange,
        mutations: [mutation],
        committedAt: now,
      });

      // Update sync state
      t.set(syncStateRef, {
        lastSeq: newSeq,
        lastLedgerSeq: isLedgerChange ? newSeq : lastLedgerSeq,
      });

      // Write receipt
      const receiptRef = this.userDoc().collection('operation_receipts').doc(op.opId);
      t.set(receiptRef, {
        opId: op.opId,
        requestHash,
        acceptedChanges: [
          { entityType: op.entityType, id: op.entityId, revision: nextRev, seq: newSeq },
        ],
        acceptedAt: now,
      });

      return {
        status: 'accepted',
        changes: [mutation],
        seq: newSeq,
        replayed: false,
      };
    });
  }

  // Get sequence of changes for sync pull
  async getChanges(afterSeq: number, limit: number = 100) {
    const snap = await this.userDoc()
      .collection('changes')
      .where('seq', '>', afterSeq)
      .orderBy('seq', 'asc')
      .limit(limit)
      .get();

    const changes = snap.docs.map((d) => d.data());
    const syncStateSnap = await this.userDoc().collection('sync_meta').doc('state').get();
    const watermark = syncStateSnap.exists ? syncStateSnap.data()?.lastSeq || 0 : 0;
    const nextAfterSeq =
      changes.length > 0 ? (changes[changes.length - 1] as any).seq : afterSeq;

    return {
      changes,
      nextAfterSeq,
      watermark,
      hasMore: nextAfterSeq < watermark,
    };
  }
}
