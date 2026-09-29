import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../accounts/data/account_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/time.dart';
import '../../../core/widgets/common.dart';
import '../application/transaction_actions.dart';
import '../data/ledger_repository.dart';
import 'entry_sheet.dart';

/// History with type/account/category/month/sync filters (docs/09).
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _type;
  String? _accountId;
  String? _categoryId;
  String? _syncStatus;
  String? _month; // null = all time
  Stream<List<TransactionView>>? _stream;

  TransactionFilter get _filter => TransactionFilter(
    type: _type,
    accountId: _accountId,
    categoryId: _categoryId,
    syncStatus: _syncStatus,
    from: _month == null ? null : '$_month-01',
    toExclusive: _month == null ? null : firstOfNextMonth(_month!),
  );

  void _refilter(VoidCallback change) {
    setState(() {
      change();
      _stream = ref.read(ledgerRepositoryProvider).watchTransactions(_filter);
    });
  }

  String _shiftMonth(String month, int delta) {
    final p = month.split('-').map(int.parse).toList();
    final d = DateTime.utc(p[0], p[1] + delta, 1);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    _stream ??= ref.read(ledgerRepositoryProvider).watchTransactions(_filter);
    final profile = ref.watch(profileProvider).value;
    final accounts =
        (ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[])
            .map((b) => b.account)
            .toList();
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryRow>[];
    final thisMonth = profile == null
        ? null
        : monthOf(localDateOf(ref.read(clockProvider)(), profile.timeZone));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _menu<String?>(
                  label: _type == null ? 'All types' : typeLabel(_type!),
                  options: {
                    null: 'All types',
                    'expense': 'Expense',
                    'income': 'Income',
                    'transfer': 'Transfer',
                    'opening': 'Opening balance',
                  },
                  onSelected: (v) => _refilter(() => _type = v),
                ),
                _menu<String?>(
                  label: _accountId == null
                      ? 'All accounts'
                      : accounts
                                .where((a) => a.id == _accountId)
                                .firstOrNull
                                ?.name ??
                            'Account',
                  options: {
                    null: 'All accounts',
                    for (final a in accounts) a.id: a.name,
                  },
                  onSelected: (v) => _refilter(() => _accountId = v),
                ),
                _menu<String?>(
                  label: _categoryId == null
                      ? 'All categories'
                      : categories
                                .where((c) => c.id == _categoryId)
                                .firstOrNull
                                ?.name ??
                            'Category',
                  options: {
                    null: 'All categories',
                    for (final c in categories) c.id: c.name,
                  },
                  onSelected: (v) => _refilter(() => _categoryId = v),
                ),
                _menu<String?>(
                  label: switch (_syncStatus) {
                    null => 'Any sync state',
                    'pending' => 'Pending sync',
                    'conflict' => 'Conflicts',
                    'blocked' => 'Needs attention',
                    _ => 'Synced',
                  },
                  options: const {
                    null: 'Any sync state',
                    'synced': 'Synced',
                    'pending': 'Pending sync',
                    'conflict': 'Conflicts',
                    'blocked': 'Needs attention',
                  },
                  onSelected: (v) => _refilter(() => _syncStatus = v),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: thisMonth == null
                    ? null
                    : () => _refilter(
                        () => _month = _shiftMonth(_month ?? thisMonth, -1),
                      ),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _refilter(
                    () => _month = _month == null ? thisMonth : null,
                  ),
                  child: Text(_month ?? 'All time'),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: thisMonth == null
                    ? null
                    : () => _refilter(
                        () => _month = _shiftMonth(_month ?? thisMonth, 1),
                      ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<TransactionView>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(
                    child: Text('Could not load local data.'),
                  );
                }
                final rows = snap.data;
                if (rows == null || profile == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions here',
                    message: 'Type something like "lunch kfc 2500 cash" or pick a category.',
                    actions: [
                      FilledButton.icon(
                        onPressed: () => showEntrySheet(context),
                        icon: const Icon(Icons.bolt),
                        label: const Text('Quick entry'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            showEntrySheet(context, mode: EntryMode.category),
                        icon: const Icon(Icons.category_outlined),
                        label: const Text('By category'),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => TransactionTile(
                    view: rows[i],
                    currency: profile.baseCurrency,
                    exponent: profile.currencyExponent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu<T>({
    required String label,
    required Map<T, String> options,
    required ValueChanged<T> onSelected,
  }) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: PopupMenuButton<T>(
      tooltip: 'Filter',
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final e in options.entries)
          PopupMenuItem<T>(value: e.key, child: Text(e.value)),
      ],
      child: Chip(
        label: Text(label),
        avatar: const Icon(Icons.filter_list, size: 18),
      ),
    ),
  );
}

/// One history row: direction, amount, date, sync and review state.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.view,
    required this.currency,
    required this.exponent,
  });

  final TransactionView view;
  final String currency;
  final int exponent;

  @override
  Widget build(BuildContext context) {
    final t = view.row;
    final title = switch (t.type) {
      'transfer' =>
        '${view.accountName ?? '?'} → ${view.destinationName ?? '?'}',
      'opening' => 'Opening balance · ${view.accountName ?? ''}',
      'income' => view.categoryName ?? 'Income',
      _ => t.merchant ?? view.categoryName ?? 'Uncategorized expense',
    };
    final subtitle = [
      t.effectiveDate,
      if (t.type == 'transfer')
        'Transfer'
      else if (t.type != 'opening')
        view.accountName ?? '',
      if (t.type == 'income' && view.sourceName != null) view.sourceName!,
      if (t.type == 'expense' &&
          t.merchant != null &&
          view.categoryName != null)
        view.categoryName!,
    ].where((s) => s.isNotEmpty).join(' · ');
    final icon = switch (t.type) {
      'transfer' => Icons.swap_horiz,
      'income' => Icons.south_west,
      'opening' => Icons.flag_outlined,
      _ => Icons.north_east,
    };
    return ListTile(
      leading: Icon(icon, semanticLabel: typeLabel(t.type)),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(subtitle),
          if (view.reviewState == 'needsReview') const _Chip('Needs review'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(
            t.type == 'opening' && t.openingDirection == 'debit'
                ? -t.amountMinor
                : t.amountMinor,
            currency: currency,
            exponent: exponent,
            kind: t.type == 'income' || t.type == 'expense'
                ? t.type
                : 'transfer',
          ),
          const SizedBox(width: 6),
          SyncBadge(t.syncStatus),
        ],
      ),
      onTap: () => context.go('/transactions/${t.id}'),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    ),
  );
}
