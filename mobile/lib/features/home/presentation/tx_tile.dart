import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common.dart';
import '../../transactions/data/ledger_repository.dart';
import 'shared.dart';

/// Compact ledger row: account direction, amount and date. Transfers use an
/// arrow and no income/expense colour semantics.
class TxTile extends StatelessWidget {
  const TxTile(
    this.view, {
    super.key,
    required this.money,
    this.perspectiveAccountId,
  });

  final TransactionView view;
  final Money money;

  /// When shown inside an account, sign the amount from that account's view.
  final String? perspectiveAccountId;

  @override
  Widget build(BuildContext context) {
    final t = view.row;
    final title = switch (t.type) {
      'transfer' =>
        '${view.accountName ?? '?'} → ${view.destinationName ?? '?'}',
      'opening' => 'Opening balance',
      'income' => view.sourceName ?? view.categoryName ?? 'Income',
      _ =>
        t.merchant ??
            view.categoryName ??
            (t.description.isEmpty ? 'Expense' : t.description),
    };
    final subtitle = [
      t.effectiveDate,
      if (t.type == 'expense' || t.type == 'income')
        view.categoryName ?? 'Uncategorized',
      if (t.type != 'transfer' && t.type != 'opening') view.accountName ?? '',
      if (view.reviewState == 'needsReview') 'Needs review',
    ].where((s) => s.isNotEmpty).join(' · ');
    var kind = t.type;
    var amount = t.amountMinor;
    if (t.type == 'opening') {
      kind = 'opening';
      amount = t.openingDirection == 'debit' ? -amount : amount;
    } else if (t.type == 'transfer' && perspectiveAccountId != null) {
      amount = t.accountId == perspectiveAccountId ? -amount : amount;
    }
    final icon = switch (t.type) {
      'transfer' => Icons.swap_horiz,
      'income' => Icons.south_west,
      'opening' => Icons.flag_outlined,
      _ => Icons.north_east,
    };
    return ListTile(
      leading: Icon(icon, semanticLabel: t.type),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyncBadge(t.syncStatus),
          const SizedBox(width: 4),
          MoneyText(
            amount,
            currency: money.currency,
            exponent: money.exponent,
            kind: kind == 'opening' ? null : kind,
          ),
        ],
      ),
      onTap: () => context.go('/transactions/${t.id}'),
    );
  }
}
