/**
 * Minimal document-store port used by the scoped repositories. Firestore is the
 * production adapter; an in-memory adapter backs unit tests. Services never see
 * raw paths: only UserScope (src/store/scope.ts) builds them from a verified UID.
 */

export type DocData = Record<string, unknown>;

export type WhereOp = '==' | '<' | '<=' | '>' | '>=';

export interface QuerySpec {
  collectionPath: string;
  where?: Array<[field: string, op: WhereOp, value: unknown]>;
  orderBy?: Array<[field: string, direction: 'asc' | 'desc']>;
  /** Values for the orderBy fields to start strictly after (cursor pagination). */
  startAfter?: unknown[];
  limit: number;
}

export interface StoreTransaction {
  get(path: string): Promise<DocData | null>;
  query(spec: QuerySpec): Promise<DocData[]>;
  set(path: string, data: DocData): void;
  delete(path: string): void;
}

export interface DocStore {
  get(path: string): Promise<DocData | null>;
  query(spec: QuerySpec): Promise<DocData[]>;
  /** Serializable read-then-write transaction; the callback may be retried. */
  runTransaction<T>(fn: (tx: StoreTransaction) => Promise<T>): Promise<T>;
}
