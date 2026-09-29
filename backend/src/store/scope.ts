import { COLLECTION_BY_ENTITY, type EntityType } from '../contracts/entities.js';
import type { DocStore } from './types.js';

/**
 * Every path is built here from a verified owner UID (docs/07-SECURITY.md:
 * "Admin SDK bypasses rules: backend authorization is mandatory"). There is no
 * method that accepts an arbitrary collection path.
 */

export const REPLICATED_SERVER_COLLECTIONS = {
  reviewState: 'review_states',
  aiActivity: 'ai_activity',
  agentRun: 'agent_runs',
} as const;

export const INTERNAL_COLLECTIONS = [
  'operation_receipts',
  'changes',
  'sync_meta',
  'run_leases',
  'work_receipts',
  'rate_limits',
  'ai_requests',
] as const;

export type ReplicatedServerType = keyof typeof REPLICATED_SERVER_COLLECTIONS;
export type InternalCollection = (typeof INTERNAL_COLLECTIONS)[number];
export type ScopedCollection =
  | (typeof COLLECTION_BY_ENTITY)[EntityType]
  | (typeof REPLICATED_SERVER_COLLECTIONS)[ReplicatedServerType]
  | InternalCollection;

const DOC_ID = /^[A-Za-z0-9:_-]{1,128}$/;

/** Opaque proof that the UID came from a verified token or the configured owner. */
export interface VerifiedOwner {
  readonly uid: string;
  readonly source: 'idToken' | 'cronOwner';
}

export class UserScope {
  readonly uid: string;

  constructor(
    owner: VerifiedOwner,
    readonly store: DocStore,
  ) {
    if (!/^[A-Za-z0-9]{1,128}$/.test(owner.uid)) throw new Error('Invalid verified UID');
    this.uid = owner.uid;
  }

  collection(name: ScopedCollection): string {
    return `users/${this.uid}/${name}`;
  }

  doc(name: ScopedCollection, id: string): string {
    if (!DOC_ID.test(id) || id.startsWith('__')) throw new Error('Invalid document ID');
    return `${this.collection(name)}/${id}`;
  }

  entityDoc(entityType: EntityType, id: string): string {
    return this.doc(COLLECTION_BY_ENTITY[entityType], id);
  }

  replicatedDoc(type: ReplicatedServerType | EntityType, id: string): string {
    if (type in REPLICATED_SERVER_COLLECTIONS) {
      return this.doc(REPLICATED_SERVER_COLLECTIONS[type as ReplicatedServerType], id);
    }
    return this.entityDoc(type as EntityType, id);
  }

  syncStateDoc(): string {
    return this.doc('sync_meta', 'state');
  }

  changeDoc(seq: number): string {
    return this.doc('changes', String(seq).padStart(12, '0'));
  }
}
