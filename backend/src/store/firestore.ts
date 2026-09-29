import type { Firestore, Query } from 'firebase-admin/firestore';
import type { DocData, DocStore, QuerySpec, StoreTransaction } from './types.js';

/** Firestore adapter. Admin SDK bypasses rules, so only UserScope may call it. */
export class FirestoreStore implements DocStore {
  constructor(private readonly db: Firestore) {}

  async get(path: string): Promise<DocData | null> {
    const snap = await this.db.doc(path).get();
    return snap.exists ? (snap.data() as DocData) : null;
  }

  async query(spec: QuerySpec): Promise<DocData[]> {
    const snap = await this.build(spec).get();
    return snap.docs.map((d) => d.data() as DocData);
  }

  runTransaction<T>(fn: (tx: StoreTransaction) => Promise<T>): Promise<T> {
    return this.db.runTransaction(
      async (t) =>
        fn({
          get: async (path) => {
            const snap = await t.get(this.db.doc(path));
            return snap.exists ? (snap.data() as DocData) : null;
          },
          query: async (spec) => {
            const snap = await t.get(this.build(spec));
            return snap.docs.map((d) => d.data() as DocData);
          },
          set: (path, data) => void t.set(this.db.doc(path), data),
          delete: (path) => void t.delete(this.db.doc(path)),
        }),
      { maxAttempts: 5 },
    );
  }

  private build(spec: QuerySpec): Query {
    let q: Query = this.db.collection(spec.collectionPath);
    for (const [field, op, value] of spec.where ?? []) q = q.where(field, op, value);
    for (const [field, dir] of spec.orderBy ?? []) q = q.orderBy(field, dir);
    if (spec.startAfter) q = q.startAfter(...spec.startAfter);
    return q.limit(spec.limit);
  }
}
