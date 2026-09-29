import type { CanonicalMutation, CanonicalRecord, Change } from '../contracts/entities.js';
import type { UserScope } from '../store/scope.js';
import type { StoreTransaction } from '../store/types.js';

/**
 * Atomic change publishing (docs/08-OFFLINE-SYNC.md): one immutable Change per
 * atomic group, SyncState incremented in the same transaction. All visible
 * server writes, including agent outputs, go through this writer.
 */

export const MAX_RECORD_BYTES = 16 * 1024;
export const MAX_CHANGE_BYTES = 64 * 1024;

export interface SyncState {
  lastSeq: number;
  lastLedgerSeq: number;
  /** Set when the first opening transaction commits; profile currency is then immutable. */
  currencyLocked: boolean;
}

export class ChangeTooLargeError extends Error {}

export async function readSyncState(tx: StoreTransaction, scope: UserScope): Promise<SyncState> {
  const d = await tx.get(scope.syncStateDoc());
  return {
    lastSeq: typeof d?.lastSeq === 'number' ? d.lastSeq : 0,
    lastLedgerSeq: typeof d?.lastLedgerSeq === 'number' ? d.lastLedgerSeq : 0,
    currencyLocked: d?.currencyLocked === true,
  };
}

export function byteLength(value: unknown): number {
  return Buffer.byteLength(JSON.stringify(value), 'utf8');
}

/** Writes records, the Change and the new SyncState. Call once per transaction, after all reads. */
export function publishChange(
  tx: StoreTransaction,
  scope: UserScope,
  state: SyncState,
  mutations: CanonicalMutation[],
  opts: { ledgerChanged: boolean; now: string; lockCurrency?: boolean },
): { seq: number; change: Change; state: SyncState } {
  for (const m of mutations) {
    if (byteLength(m.record) > MAX_RECORD_BYTES) throw new ChangeTooLargeError('record');
  }
  const seq = state.lastSeq + 1;
  const change: Change = { seq, ledgerChanged: opts.ledgerChanged, mutations, committedAt: opts.now };
  if (byteLength(change) > MAX_CHANGE_BYTES) throw new ChangeTooLargeError('change');

  for (const m of mutations) tx.set(scope.replicatedDoc(m.entityType as never, m.id), m.record);
  tx.set(scope.changeDoc(seq), change as unknown as Record<string, unknown>);
  const next: SyncState = {
    lastSeq: seq,
    lastLedgerSeq: opts.ledgerChanged ? seq : state.lastLedgerSeq,
    currencyLocked: state.currencyLocked || opts.lockCurrency === true,
  };
  tx.set(scope.syncStateDoc(), { ...next });
  return { seq, change, state: next };
}

export function newRecord(
  id: string,
  payload: Record<string, unknown>,
  now: string,
  previous: CanonicalRecord | null,
): CanonicalRecord {
  return {
    ...payload,
    id,
    schemaVersion: 1,
    revision: (previous?.revision ?? 0) + 1,
    createdAt: previous?.createdAt ?? now,
    serverUpdatedAt: now,
    deletedAt: null,
  };
}

export function tombstone(previous: CanonicalRecord, now: string): CanonicalRecord {
  return { ...previous, revision: previous.revision + 1, serverUpdatedAt: now, deletedAt: now };
}

export function mutation(entityType: string, record: CanonicalRecord): CanonicalMutation {
  return { entityType, id: record.id, revision: record.revision, record };
}
