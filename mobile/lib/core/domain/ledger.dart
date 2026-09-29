import 'money.dart';
import 'result.dart';

/// Ledger mathematics (docs/04 "Ledger mathematics"). Balances are always
/// derived from confirmed transactions; there is no stored balance.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.accountId,
    this.destinationAccountId,
    this.openingDirection,
    required this.effectiveDate,
    this.categoryId,
    this.deleted = false,
  });

  final String id;
  final String type;
  final int amountMinor;
  final String accountId;
  final String? destinationAccountId;
  final String? openingDirection;
  final String effectiveDate;
  final String? categoryId;
  final bool deleted;
}

int effect(LedgerEntry t, String accountId) {
  if (t.deleted) return 0;
  switch (t.type) {
    case 'income':
      return t.accountId == accountId ? t.amountMinor : 0;
    case 'expense':
      return t.accountId == accountId ? -t.amountMinor : 0;
    case 'transfer':
      if (t.accountId == accountId) return -t.amountMinor;
      if (t.destinationAccountId == accountId) return t.amountMinor;
      return 0;
    case 'opening':
      return t.accountId == accountId
          ? (t.openingDirection == 'debit' ? -1 : 1) * t.amountMinor
          : 0;
    default:
      return 0;
  }
}

Result<int> balanceOf(Iterable<LedgerEntry> txs, String accountId) =>
    checkedSum(txs.map((t) => effect(t, accountId)));

/// Income/expense for [from, toExclusive); openings and transfers excluded.
({int income, int expense}) periodTotals(
  Iterable<LedgerEntry> txs,
  String from,
  String toExclusive,
) {
  var income = 0;
  var expense = 0;
  for (final t in txs) {
    if (t.deleted ||
        t.effectiveDate.compareTo(from) < 0 ||
        t.effectiveDate.compareTo(toExclusive) >= 0) {
      continue;
    }
    if (t.type == 'income') income += t.amountMinor;
    if (t.type == 'expense') expense += t.amountMinor;
  }
  return (income: income, expense: expense);
}
