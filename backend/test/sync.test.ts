import { describe, expect, it } from 'vitest';
import { openingTransactionId } from '../src/contracts/canonical.js';
import type { CanonicalRecord, Change } from '../src/contracts/entities.js';
import { balance, type LedgerTransaction } from '../src/domain/ledger.js';
import { validateBatch } from '../src/sync/validate.js';
import { account, category, createTx, OTHER, op, seedLedger, setup, txPayload, uuid } from './helpers.js';

async function replayBalances(env: ReturnType<typeof setup>, accountIds: string[]) {
  // Rebuild balances only from the pulled change stream, as a new device would.
  const records = new Map<string, CanonicalRecord>();
  let after = 0;
  for (;;) {
    const page = await env.sync.changes(after, undefined, 3);
    for (const c of page.changes as Change[]) for (const m of c.mutations) if (m.entityType === 'transaction') records.set(m.id, m.record);
    after = page.nextAfterSeq;
    if (!page.hasMore) break;
  }
  const txs = [...records.values()] as unknown as LedgerTransaction[];
  return Object.fromEntries(accountIds.map((a) => [a, balance(txs, a)]));
}

describe('sync push: account + opening compound', () => {
  it('creates account and derived opening atomically in one change', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const openingId = openingTransactionId(ids.cash);
    const opening = await env.store.get(`users/ownerUid123/transactions/${openingId}`);
    expect(opening).toMatchObject({ type: 'opening', amountMinor: 500000, openingDirection: 'credit', accountId: ids.cash, revision: 1 });
    const page = await env.sync.changes(0, undefined, 100);
    const accountChange = page.changes.find((c) => c.mutations.some((m) => m.id === ids.cash))!;
    expect(accountChange.mutations.map((m) => m.entityType).sort()).toEqual(['account', 'reviewState', 'transaction']);
    expect(accountChange.ledgerChanged).toBe(true);
  });

  it('supports negative and zero openings', async () => {
    const env = setup();
    await seedLedger(env);
    const neg = uuid();
    const zero = uuid();
    const r = await env.push(account('Overdrawn', 'bank', -2500, neg), account('Empty', 'savings', 0, zero));
    expect(r.map((x) => x.status)).toEqual(['accepted', 'accepted']);
    const b = await replayBalances(env, [neg, zero]);
    expect(b).toEqual({ [neg]: -2500, [zero]: 0 });
  });

  it('rejects account currency that differs from the profile', async () => {
    const env = setup();
    await seedLedger(env);
    const bad = account('USD', 'bank', 0);
    (bad.payload as { account: { currency: string } }).account.currency = 'USD';
    const fixed = op({ entityType: 'account', entityId: bad.entityId, action: 'createAccountWithOpening', baseRevision: 0, payload: bad.payload });
    expect((await env.push(fixed))[0]).toMatchObject({ status: 'rejected', code: 'VALIDATION_ERROR' });
  });
});

describe('sync push: ledger invariants and CAS', () => {
  it('salary → bank, bank → cash, cash → lunch balances match by hand', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const r = await env.push(
      createTx(txPayload({ type: 'income', amountMinor: 25000000, accountId: ids.bank, incomeSourceId: ids.employer, categoryId: ids.salary })),
      createTx(txPayload({ type: 'transfer', amountMinor: 2000000, accountId: ids.bank, destinationAccountId: ids.cash })),
      createTx(txPayload({ type: 'expense', amountMinor: 250000, accountId: ids.cash, categoryId: ids.restaurant, merchant: 'KFC' })),
    );
    expect(r.every((x) => x.status === 'accepted')).toBe(true);
    const b = await replayBalances(env, [ids.cash, ids.bank]);
    expect(b[ids.bank]).toBe(10000000 + 25000000 - 2000000);
    expect(b[ids.cash]).toBe(500000 + 2000000 - 250000);
  });

  it('income without category or source is rejected before execution', () => {
    const bad = createTx(txPayload({ type: 'income', amountMinor: 100, accountId: uuid(), incomeSourceId: null, categoryId: null }));
    const v = validateBatch([bad]);
    expect('errors' in v).toBe(true);
  });

  it('transfer with equal accounts is rejected', () => {
    const a = uuid();
    const v = validateBatch([createTx(txPayload({ type: 'transfer', amountMinor: 100, accountId: a, destinationAccountId: a }))]);
    expect('errors' in v && v.errors.some((e) => e.code === 'SAME_ACCOUNT')).toBe(true);
  });

  it('client cannot create an opening transaction directly', () => {
    const v = validateBatch([createTx(txPayload({ type: 'opening', amountMinor: 1, accountId: uuid(), origin: 'opening', openingDirection: 'credit' }))]);
    expect('errors' in v).toBe(true);
  });

  it('two devices updating revision 1: first wins, second conflicts with current record; no merge', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const txId = uuid();
    await env.push(createTx(txPayload({ type: 'expense', amountMinor: 1000, accountId: ids.cash }), txId));
    const a = op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 1, payload: txPayload({ type: 'expense', amountMinor: 2000, accountId: ids.cash }) });
    const b = op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 1, payload: txPayload({ type: 'expense', amountMinor: 3000, accountId: ids.bank }) });
    const [ra] = await env.push(a);
    const [rb] = await env.push(b);
    expect(ra!.status).toBe('accepted');
    expect(rb).toMatchObject({ status: 'conflict', code: 'REVISION_CONFLICT', current: { amountMinor: 2000, revision: 2 } });
  });

  it('edit replaces and delete removes the effect exactly once; tombstones cannot be resurrected', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const txId = uuid();
    await env.push(createTx(txPayload({ type: 'expense', amountMinor: 1000, accountId: ids.cash }), txId));
    await env.push(op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 1, payload: txPayload({ type: 'expense', amountMinor: 4000, accountId: ids.cash }) }));
    expect((await replayBalances(env, [ids.cash]))[ids.cash]).toBe(500000 - 4000);
    await env.push(op({ entityType: 'transaction', entityId: txId, action: 'delete', baseRevision: 2, payload: null }));
    expect((await replayBalances(env, [ids.cash]))[ids.cash]).toBe(500000);
    const [recreate] = await env.push(createTx(txPayload({ type: 'expense', amountMinor: 1, accountId: ids.cash }), txId));
    expect(recreate!.status).toBe('conflict');
    const [staleEdit] = await env.push(op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 2, payload: txPayload({ type: 'expense', amountMinor: 5, accountId: ids.cash }) }));
    expect(staleEdit!.status).toBe('conflict');
  });

  it('opening transactions cannot be deleted but can be corrected with CAS', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const openingId = openingTransactionId(ids.cash);
    const [del] = await env.push(op({ entityType: 'transaction', entityId: openingId, action: 'delete', baseRevision: 1, payload: null }));
    expect(del).toMatchObject({ status: 'rejected', code: 'VALIDATION_ERROR' });
    const corrected = txPayload({ type: 'opening', amountMinor: 700000, accountId: ids.cash, origin: 'opening', openingDirection: 'credit', description: 'Opening balance', occurredAt: '2026-09-01T06:30:00.000Z', effectiveDate: '2026-09-01' });
    const [upd] = await env.push(op({ entityType: 'transaction', entityId: openingId, action: 'update', baseRevision: 1, payload: corrected }));
    expect(upd!.status).toBe('accepted');
    expect((await replayBalances(env, [ids.cash]))[ids.cash]).toBe(700000);
  });

  it('rejects archived references for new selections but allows retained ones', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const txId = uuid();
    await env.push(createTx(txPayload({ type: 'expense', amountMinor: 100, accountId: ids.cash }), txId));
    await env.push(op({ entityType: 'account', entityId: ids.cash, action: 'update', baseRevision: 1, payload: { name: 'Cash Wallet', type: 'cash', currency: 'LKR', archived: true, sortOrder: 0 } }));
    const [newRef] = await env.push(createTx(txPayload({ type: 'expense', amountMinor: 100, accountId: ids.cash })));
    expect(newRef).toMatchObject({ status: 'rejected', code: 'ARCHIVED_REFERENCE' });
    const [retained] = await env.push(op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 1, payload: txPayload({ type: 'expense', amountMinor: 200, accountId: ids.cash }) }));
    expect(retained!.status).toBe('accepted');
  });

  it('missing references and wrong category type fail closed', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const [missing] = await env.push(createTx(txPayload({ type: 'expense', amountMinor: 100, accountId: uuid() })));
    expect(missing).toMatchObject({ status: 'rejected', code: 'MISSING_REFERENCE' });
    const [wrongType] = await env.push(createTx(txPayload({ type: 'expense', amountMinor: 100, accountId: ids.cash, categoryId: ids.salary })));
    expect(wrongType).toMatchObject({ status: 'rejected', code: 'VALIDATION_ERROR' });
  });

  it('another user cannot see or reference the owner namespace', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const other = setup(OTHER, env.store);
    await other.push(op({ entityType: 'profile', entityId: 'profile', action: 'create', baseRevision: 0, payload: { displayName: 'X', baseCurrency: 'LKR', currencyExponent: 2, timeZone: 'Asia/Colombo', onboardingComplete: true } }));
    const [r] = await other.push(createTx(txPayload({ type: 'expense', amountMinor: 100, accountId: ids.cash })));
    expect(r).toMatchObject({ status: 'rejected', code: 'MISSING_REFERENCE' });
    const page = await other.sync.changes(0, undefined, 100);
    expect(page.changes.flatMap((c) => c.mutations.map((m) => m.id))).not.toContain(ids.cash);
  });

  it('profile currency is locked after the first opening', async () => {
    const env = setup();
    await seedLedger(env);
    const [r] = await env.push(op({ entityType: 'profile', entityId: 'profile', action: 'update', baseRevision: 1, payload: { displayName: 'Me', baseCurrency: 'USD', currencyExponent: 2, timeZone: 'Asia/Colombo', onboardingComplete: true } }));
    expect(r).toMatchObject({ status: 'rejected', code: 'VALIDATION_ERROR' });
  });
});

describe('sync push: idempotency and dependencies', () => {
  it('replays a lost acknowledgement with the original records and no extra effect', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const o = createTx(txPayload({ type: 'transfer', amountMinor: 1000, accountId: ids.bank, destinationAccountId: ids.cash }));
    const [first] = await env.push(o);
    const [again] = await env.push(o);
    expect(again).toMatchObject({ status: 'accepted', replayed: true });
    expect(again!.status === 'accepted' && first!.status === 'accepted' && again!.seq === first!.seq).toBe(true);
    expect(again!.status === 'accepted' && again!.changes).toEqual(first!.status === 'accepted' && first!.changes);
    expect((await replayBalances(env, [ids.cash]))[ids.cash]).toBe(501000);
  });

  it('receipt check precedes revision check even after the entity changed', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const txId = uuid();
    const create = createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.cash }), txId);
    await env.push(create);
    await env.push(op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: 1, payload: txPayload({ type: 'expense', amountMinor: 20, accountId: ids.cash }) }));
    const [replay] = await env.push(create);
    expect(replay).toMatchObject({ status: 'accepted', replayed: true });
    expect(replay!.status === 'accepted' && (replay!.changes[0]!.record as unknown as { amountMinor: number }).amountMinor).toBe(10);
  });

  it('same opId with a different payload is rejected', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const a = createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.cash }));
    await env.push(a);
    const b = op({ ...a, opId: a.opId, payload: txPayload({ type: 'expense', amountMinor: 11, accountId: ids.cash }) });
    expect((await env.push(b))[0]).toMatchObject({ status: 'rejected', code: 'IDEMPOTENCY_KEY_REUSED' });
  });

  it('dependent same-entity operation resolves its base revision from the predecessor receipt', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const txId = uuid();
    const first = createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.cash }), txId);
    const second = op({ entityType: 'transaction', entityId: txId, action: 'update', baseRevision: null, dependsOnOpId: first.opId, payload: txPayload({ type: 'expense', amountMinor: 30, accountId: ids.cash }) });
    const r = await env.push(first, second);
    expect(r.map((x) => x.status)).toEqual(['accepted', 'accepted']);
    const orphan = op({ entityType: 'transaction', entityId: txId, action: 'delete', baseRevision: null, dependsOnOpId: uuid(), payload: null });
    expect((await env.push(orphan))[0]).toMatchObject({ status: 'rejected', code: 'DEPENDENCY_FAILED' });
  });

  it('partial batch: each operation is independent', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const r = await env.push(
      createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.cash })),
      createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: uuid() })),
      createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.bank })),
    );
    expect(r.map((x) => x.status)).toEqual(['accepted', 'rejected', 'accepted']);
  });

  it('a failed commit leaves no receipt, record or change', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const before = (await env.sync.changes(0, undefined, 100)).watermark;
    env.store.failNextCommit = true;
    const o = createTx(txPayload({ type: 'expense', amountMinor: 10, accountId: ids.cash }));
    await expect(env.push(o)).rejects.toThrow();
    expect((await env.sync.changes(0, undefined, 100)).watermark).toBe(before);
    expect((await env.push(o))[0]).toMatchObject({ status: 'accepted', replayed: false });
  });
});

describe('batch validation', () => {
  it('requires confirmation and a matching payload hash', () => {
    const noConfirm = op({ entityType: 'transaction', entityId: uuid(), action: 'create', baseRevision: 0, payload: txPayload({ type: 'expense', amountMinor: 1, accountId: uuid() }), confirm: false });
    expect('errors' in validateBatch([noConfirm])).toBe(true);
    const tampered = createTx(txPayload({ type: 'expense', amountMinor: 1, accountId: uuid() }));
    (tampered.payload as { amountMinor: number }).amountMinor = 2;
    const v = validateBatch([tampered]);
    expect('errors' in v && v.errors.some((e) => e.code === 'PAYLOAD_HASH_MISMATCH')).toBe(true);
  });

  it('rejects unknown/server fields, unsafe money and non-NFC text', () => {
    const extra = createTx({ ...txPayload({ type: 'expense', amountMinor: 1, accountId: uuid() }), revision: 9 });
    const unsafe = createTx(txPayload({ type: 'expense', amountMinor: 1_000_000_000_001, accountId: uuid() }));
    const nfd = createTx(txPayload({ type: 'expense', amountMinor: 1, accountId: uuid(), description: 'Café' }));
    for (const o of [extra, unsafe, nfd]) expect('errors' in validateBatch([o])).toBe(true);
  });

  it('rejects effectiveDate inconsistent with occurredAt in the entry time zone', () => {
    // 2026-09-09T20:00Z is 2026-09-10 01:30 in Asia/Colombo.
    const o = createTx(txPayload({ type: 'expense', amountMinor: 1, accountId: uuid(), occurredAt: '2026-09-09T20:00:00.000Z', effectiveDate: '2026-09-09' }));
    expect('errors' in validateBatch([o])).toBe(true);
  });

  it('only allows documented action/entity combinations', () => {
    const cases = [
      op({ entityType: 'account', entityId: uuid(), action: 'create', baseRevision: 0, payload: { name: 'x', type: 'cash', currency: 'LKR', archived: false, sortOrder: 0 } }),
      op({ entityType: 'account', entityId: uuid(), action: 'delete', baseRevision: 1, payload: null }),
      op({ entityType: 'aiInsight', entityId: uuid(), action: 'update', baseRevision: 1, payload: { status: 'dismissed' } }),
      op({ entityType: 'profile', entityId: 'someone-else', action: 'create', baseRevision: 0, payload: { displayName: 'x', baseCurrency: 'LKR', currencyExponent: 2, timeZone: 'Asia/Colombo', onboardingComplete: false } }),
    ];
    for (const c of cases) expect('errors' in validateBatch([c])).toBe(true);
  });
});

describe('sync pull', () => {
  it('pages to a captured watermark even while new changes arrive', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const first = await env.sync.changes(0, undefined, 2);
    const w = first.watermark;
    await env.push(createTx(txPayload({ type: 'expense', amountMinor: 1, accountId: ids.cash })));
    let after = first.nextAfterSeq;
    const seqs = first.changes.map((c) => c.seq);
    for (;;) {
      const p = await env.sync.changes(after, w, 2);
      seqs.push(...p.changes.map((c) => c.seq));
      after = p.nextAfterSeq;
      if (!p.hasMore) break;
    }
    expect(seqs).toEqual(Array.from({ length: w }, (_, i) => i + 1));
  });

  it('rejects cursors beyond the server sequence and watermark outside range', async () => {
    const env = setup();
    await seedLedger(env);
    await expect(env.sync.changes(10_000, undefined, 10)).rejects.toThrow();
    await expect(env.sync.changes(0, 10_000, 10)).rejects.toThrow();
  });

  it('first pull of an empty namespace returns a watermark-0 page', async () => {
    const env = setup();
    expect(await env.sync.changes(0, undefined, 100)).toEqual({ changes: [], nextAfterSeq: 0, watermark: 0, hasMore: false });
  });
});

describe('budgets and categories', () => {
  it('prevents duplicate and parent/child overlapping budgets in a month', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    const budget = (categoryId: string) =>
      op({ entityType: 'budget', entityId: uuid(), action: 'create', baseRevision: 0, payload: { month: '2026-09', categoryId, limitMinor: 1000000, currency: 'LKR' } });
    expect((await env.push(budget(ids.food)))[0]!.status).toBe('accepted');
    expect((await env.push(budget(ids.food)))[0]).toMatchObject({ status: 'rejected' });
    expect((await env.push(budget(ids.restaurant)))[0]).toMatchObject({ status: 'rejected' });
    expect((await env.push(budget(ids.salary)))[0]).toMatchObject({ status: 'rejected' });
  });

  it('limits category depth to two and keeps parent type', async () => {
    const env = setup();
    const ids = await seedLedger(env);
    expect((await env.push(category('Too deep', 'expense', ids.restaurant)))[0]).toMatchObject({ status: 'rejected' });
    expect((await env.push(category('Wrong type', 'income', ids.food)))[0]).toMatchObject({ status: 'rejected' });
  });
});
