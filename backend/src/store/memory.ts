import type { DocData, DocStore, QuerySpec, StoreTransaction } from './types.js';

/**
 * In-memory DocStore for unit tests. Transactions are serialized, reads see the
 * committed state, writes are buffered and applied atomically, and a read after
 * a write throws (mirroring Firestore's reads-before-writes rule).
 */
export class MemoryStore implements DocStore {
  private readonly docs = new Map<string, DocData>();
  private queue: Promise<unknown> = Promise.resolve();
  /** When set, the next commit throws after the callback runs (fault injection). */
  failNextCommit = false;

  snapshot(): Map<string, DocData> {
    return new Map([...this.docs].map(([k, v]) => [k, clone(v)]));
  }

  seed(path: string, data: DocData): void {
    this.docs.set(path, clone(data));
  }

  async get(path: string): Promise<DocData | null> {
    const d = this.docs.get(path);
    return d ? clone(d) : null;
  }

  async query(spec: QuerySpec): Promise<DocData[]> {
    return runQuery(this.docs, spec);
  }

  runTransaction<T>(fn: (tx: StoreTransaction) => Promise<T>): Promise<T> {
    const run = async () => {
      const writes = new Map<string, DocData | null>();
      const tx: StoreTransaction = {
        get: async (path) => {
          if (writes.size > 0) throw new Error('Transaction read after write');
          return this.get(path);
        },
        query: async (spec) => {
          if (writes.size > 0) throw new Error('Transaction read after write');
          return runQuery(this.docs, spec);
        },
        set: (path, data) => void writes.set(path, clone(data)),
        delete: (path) => void writes.set(path, null),
      };
      const result = await fn(tx);
      if (this.failNextCommit) {
        this.failNextCommit = false;
        throw new Error('Injected commit failure');
      }
      for (const [path, data] of writes) {
        if (data === null) this.docs.delete(path);
        else this.docs.set(path, data);
      }
      return result;
    };
    const next = this.queue.then(run, run);
    this.queue = next.catch(() => undefined);
    return next;
  }
}

function clone<T>(v: T): T {
  return structuredClone(v);
}

function compare(a: unknown, b: unknown): number {
  if (a === b) return 0;
  if (a === null || a === undefined) return -1;
  if (b === null || b === undefined) return 1;
  if (typeof a === 'number' && typeof b === 'number') return a - b;
  return String(a) < String(b) ? -1 : 1;
}

function runQuery(docs: Map<string, DocData>, spec: QuerySpec): DocData[] {
  const prefix = `${spec.collectionPath}/`;
  let rows = [...docs.entries()]
    .filter(([p]) => p.startsWith(prefix) && !p.slice(prefix.length).includes('/'))
    .map(([, d]) => clone(d));
  for (const [field, op, value] of spec.where ?? []) {
    rows = rows.filter((r) => {
      const v = r[field] ?? null;
      const c = compare(v, value);
      switch (op) {
        case '==':
          return v === value;
        case '<':
          return v !== null && c < 0;
        case '<=':
          return v !== null && c <= 0;
        case '>':
          return v !== null && c > 0;
        case '>=':
          return v !== null && c >= 0;
      }
    });
  }
  const order = spec.orderBy ?? [];
  rows.sort((x, y) => {
    for (const [f, dir] of order) {
      const c = compare(x[f], y[f]);
      if (c !== 0) return dir === 'asc' ? c : -c;
    }
    return 0;
  });
  if (spec.startAfter) {
    const after = spec.startAfter;
    rows = rows.filter((r) => {
      for (let i = 0; i < order.length; i++) {
        const [f, dir] = order[i]!;
        const c = compare(r[f], after[i]);
        if (c !== 0) return dir === 'asc' ? c > 0 : c < 0;
      }
      return false;
    });
  }
  return rows.slice(0, spec.limit);
}
