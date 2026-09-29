import fs from 'node:fs';
import path from 'node:path';
import fc from 'fast-check';
import { describe, expect, it } from 'vitest';
import { canonicalHash, canonicalJson, openingTransactionId } from '../src/contracts/canonical.js';
import { ParseRequestSchema } from '../src/contracts/api.js';
import { balance, effect, periodTotals, type LedgerTransaction } from '../src/domain/ledger.js';
import { checkedSum, parseDecimalToMinor } from '../src/domain/money.js';
import { noonInZone } from '../src/domain/time.js';

const vectors = JSON.parse(fs.readFileSync(path.join(import.meta.dirname, '../../docs/contracts/hash-vectors.json'), 'utf8'));

describe('canonical JSON golden vectors (shared with Dart)', () => {
  for (const v of vectors.vectors) {
    it(v.name, () => {
      expect(canonicalJson(v.input)).toBe(v.canonical);
      expect(canonicalHash(v.input)).toBe(v.sha256);
    });
  }
  for (const r of vectors.rejections) {
    it(`rejects ${r.name}`, () => expect(() => canonicalJson(r.input)).toThrow());
  }
  it('rejects negative zero', () => expect(() => canonicalJson({ n: -0 })).toThrow());
  it('derives opening IDs', () => {
    for (const o of vectors.openingIds) expect(openingTransactionId(o.accountId)).toBe(o.openingId);
  });
});

describe('money parsing', () => {
  it.each([
    ['2500', 250000],
    ['2,500', 250000],
    ['1,234,567.5', 123456750],
    ['0.05', 5],
    ['250000', 25000000],
  ])('%s → %i minor units', (text, minor) => expect(parseDecimalToMinor(text, 2)).toEqual({ ok: true, minor }));

  it.each(['2.500', '1,50', '12.345', '1e5', '-5', 'NaN', '', '10000000000.01'])('rejects %s', (text) => {
    expect(parseDecimalToMinor(text, 2).ok).toBe(false);
  });

  it('round-trips random integers exactly without floating point', () => {
    fc.assert(
      fc.property(fc.integer({ min: 1, max: 1_000_000_000_000 }), (minor) => {
        const s = String(minor).padStart(3, '0');
        const text = `${s.slice(0, -2)}.${s.slice(-2)}`;
        expect(parseDecimalToMinor(text, 2)).toEqual({ ok: true, minor });
      }),
    );
  });

  it('detects balance overflow', () => {
    expect(() => checkedSum([Number.MAX_SAFE_INTEGER, 1])).toThrow(RangeError);
  });
});

describe('ledger properties (independent reducer)', () => {
  const accounts = ['a', 'b', 'c'];
  const txArb = fc.record({
    id: fc.uuid(),
    type: fc.constantFrom('income', 'expense', 'transfer', 'opening') as fc.Arbitrary<LedgerTransaction['type']>,
    amountMinor: fc.integer({ min: 1, max: 1_000_000 }),
    accountId: fc.constantFrom(...accounts),
    destinationAccountId: fc.constantFrom(...accounts),
    openingDirection: fc.constantFrom('credit', 'debit') as fc.Arbitrary<'credit' | 'debit'>,
    effectiveDate: fc.constantFrom('2026-08-15', '2026-09-01', '2026-09-20'),
    deleted: fc.boolean(),
  }).filter((t) => t.type !== 'transfer' || t.accountId !== t.destinationAccountId);

  const toLedger = (t: { id: string; type: LedgerTransaction['type']; amountMinor: number; accountId: string; destinationAccountId: string; openingDirection: 'credit' | 'debit'; effectiveDate: string; deleted: boolean }): LedgerTransaction => ({
    id: t.id,
    type: t.type,
    amountMinor: t.amountMinor,
    accountId: t.accountId,
    destinationAccountId: t.type === 'transfer' ? t.destinationAccountId : null,
    categoryId: null,
    openingDirection: t.type === 'opening' ? t.openingDirection : null,
    effectiveDate: t.effectiveDate,
    merchant: null,
    deletedAt: t.deleted ? '2026-09-21T00:00:00.000Z' : null,
  });

  it('net worth changes only by income - expense + openings; transfers sum to zero', () => {
    fc.assert(
      fc.property(fc.array(txArb, { maxLength: 60 }), (raw) => {
        const txs = raw.map(toLedger);
        const netWorth = accounts.reduce((s, a) => s + balance(txs, a), 0);
        let expected = 0;
        for (const t of txs) {
          if (t.deletedAt) continue;
          if (t.type === 'income') expected += t.amountMinor;
          if (t.type === 'expense') expected -= t.amountMinor;
          if (t.type === 'opening') expected += (t.openingDirection === 'debit' ? -1 : 1) * t.amountMinor;
        }
        expect(netWorth).toBe(expected);
        for (const t of txs.filter((x) => x.type === 'transfer')) {
          expect(accounts.reduce((s, a) => s + effect(t, a), 0)).toBe(0);
        }
      }),
    );
  });

  it('reports exclude transfers and openings', () => {
    fc.assert(
      fc.property(fc.array(txArb, { maxLength: 60 }), (raw) => {
        const txs = raw.map(toLedger);
        const totals = periodTotals(txs, '2026-09-01', '2026-10-01');
        const live = txs.filter((t) => !t.deletedAt && t.effectiveDate >= '2026-09-01');
        expect(totals.expenseMinor).toBe(live.filter((t) => t.type === 'expense').reduce((s, t) => s + t.amountMinor, 0));
        expect(totals.incomeMinor).toBe(live.filter((t) => t.type === 'income').reduce((s, t) => s + t.amountMinor, 0));
      }),
    );
  });
});

describe('request schemas', () => {
  it('ParseRequest is strict about unknown fields and instant precision', () => {
    const base = { draftId: '6f1c1f2e-3b1a-4c55-9a51-4b3c2f1d0e9a', rawInput: 'lunch kfc 2500 cash', referenceNow: '2026-09-09T08:00:00.000Z', timeZone: 'Asia/Colombo', currency: 'LKR' };
    expect(ParseRequestSchema.safeParse(base).success).toBe(true);
    expect(ParseRequestSchema.safeParse({ ...base, userId: 'x' }).success).toBe(false);
    expect(ParseRequestSchema.safeParse({ ...base, referenceNow: '2026-09-09T08:00:00Z' }).success).toBe(false);
    expect(ParseRequestSchema.safeParse({ ...base, timeZone: '+05:30' }).success).toBe(false);
  });

  it('date-only values resolve to local noon', () => {
    expect(noonInZone('2026-09-09', 'Asia/Colombo').toISOString()).toBe('2026-09-09T06:30:00.000Z');
  });
});
