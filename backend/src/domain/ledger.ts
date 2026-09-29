import { checkedSum } from './money.js';

/** Ledger mathematics from docs/04-DATA-MODEL.md; the only balance/report arithmetic. */

export interface LedgerTransaction {
  id: string;
  type: 'income' | 'expense' | 'transfer' | 'opening';
  amountMinor: number;
  accountId: string;
  destinationAccountId: string | null;
  categoryId: string | null;
  openingDirection: 'credit' | 'debit' | null;
  effectiveDate: string;
  merchant: string | null;
  deletedAt: string | null;
}

export function effect(t: LedgerTransaction, accountId: string): number {
  if (t.deletedAt !== null) return 0;
  switch (t.type) {
    case 'income':
      return t.accountId === accountId ? t.amountMinor : 0;
    case 'expense':
      return t.accountId === accountId ? -t.amountMinor : 0;
    case 'transfer':
      if (t.accountId === accountId) return -t.amountMinor;
      if (t.destinationAccountId === accountId) return t.amountMinor;
      return 0;
    case 'opening':
      return t.accountId === accountId ? (t.openingDirection === 'debit' ? -1 : 1) * t.amountMinor : 0;
  }
}

export function balance(txs: LedgerTransaction[], accountId: string): number {
  return checkedSum(txs.map((t) => effect(t, accountId)));
}

/** Income/expense totals for [from, toExclusive); openings and transfers excluded. */
export function periodTotals(txs: LedgerTransaction[], from: string, toExclusive: string) {
  const inPeriod = txs.filter((t) => t.deletedAt === null && t.effectiveDate >= from && t.effectiveDate < toExclusive);
  return {
    incomeMinor: checkedSum(inPeriod.filter((t) => t.type === 'income').map((t) => t.amountMinor)),
    expenseMinor: checkedSum(inPeriod.filter((t) => t.type === 'expense').map((t) => t.amountMinor)),
  };
}
