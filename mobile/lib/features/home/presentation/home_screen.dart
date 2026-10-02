import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/domain/time.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/motion.dart';
import '../../transactions/presentation/entry_sheet.dart';
import 'shared.dart';
import 'tx_tile.dart';

/// Home dashboard (docs/09 "Home dashboard"): recorded balance, accounts,
/// month-to-date totals, budgets, daily review, one insight, recent entries.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final balances = ref.watch(accountBalancesProvider);
    final today = ref.watch(todayProvider);
    final monthStart = '${monthOf(today)}-01';
    final totals = ref.watch(
      monthTotalsProvider((monthStart, addDays(today, 1))),
    );
    final budgets = ref.watch(budgetMonthProvider(monthOf(today)));
    final reviewCount = ref.watch(reviewCountProvider).value ?? 0;
    final proposals = ref.watch(pendingProposalsProvider).value ?? const [];
    final insights = ref.watch(insightsProvider).value ?? const [];
    final freshness = ref.watch(freshnessProvider).value;
    final recent = ref.watch(transactionsProvider((accountId: null, limit: 5)));
    final pending = ref.watch(pendingOpsProvider).value ?? 0;
    final cursor = ref.watch(cursorProvider).value;
    final sync = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: sync.running
                ? null
                : () => ref.read(syncControllerProvider.notifier).syncNow(),
            icon: sync.running
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: whenData(balances, (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Add your first account',
            message: 'Accounts are where your money is — for example Cash Wallet or Primary Bank. Add one with its opening balance to start recording.',
            actions: [
              FilledButton(
                onPressed: () => context.go('/more/accounts'),
                child: const Text('Set up accounts'),
              ),
            ],
          );
        }
        final total = list.fold<int>(0, (s, a) => s + a.balanceMinor);
        final anyPending = pending > 0 || list.any((a) => a.hasPending);
        final active = list.where((a) => !a.account.archived).toList();
        final insight = insights.isEmpty ? null : insights.first;
        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: staggered([
            if (sync.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(sync.message!, info: true),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recorded balance',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(width: 8),
                        if (anyPending) const SyncBadge('pending'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CountUpMoney(
                      total,
                      currency: money.currency,
                      exponent: money.exponent,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total of all recorded accounts, including archived. Not a bank-verified balance.'
                      '${anyPending ? ' Includes $pending change(s) not yet synced.' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Last synced: ${formatLocalTime(cursor?.lastSyncedAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Accounts', style: theme.textTheme.titleSmall),
                    trailing: TextButton(
                      onPressed: () => context.go('/more/accounts'),
                      child: const Text('All'),
                    ),
                  ),
                  for (final a in active)
                    ListTile(
                      title: Text(
                        a.account.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: a.balanceMinor < 0
                          ? const Text('Negative balance')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (a.hasPending) const SyncBadge('pending'),
                          const SizedBox(width: 4),
                          MoneyText(
                            a.balanceMinor,
                            currency: money.currency,
                            exponent: money.exponent,
                          ),
                        ],
                      ),
                      onTap: () => context.go('/more/accounts/${a.account.id}'),
                    ),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: whenData(
                  totals,
                  (t) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This month so far',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Income'),
                                MoneyText(
                                  t.income,
                                  currency: money.currency,
                                  exponent: money.exponent,
                                  kind: 'income',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Spending'),
                                MoneyText(
                                  t.expense,
                                  currency: money.currency,
                                  exponent: money.exponent,
                                  kind: 'expense',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transfers and opening balances are not counted.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (reviewCount > 0 || proposals.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.fact_check_outlined,
                    semanticLabel: 'Review',
                  ),
                  title: const Text('Daily review'),
                  subtitle: Text(
                    '${proposals.length} suggestion(s) and $reviewCount entr${reviewCount == 1 ? 'y' : 'ies'} need a look',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => context.go('/home/review'),
                    child: const Text('Review suggestions'),
                  ),
                ),
              ),
            whenData(
              budgets,
              (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Budgets this month',
                              style: theme.textTheme.titleSmall,
                            ),
                            trailing: TextButton(
                              onPressed: () => context.go('/more/budgets'),
                              child: const Text('All'),
                            ),
                          ),
                          for (final b in list.take(3))
                            ListTile(
                              title: Text(b.categoryName),
                              subtitle: Semantics(
                                label:
                                    'Spent ${b.spentMinor} of ${b.budget.limitMinor}',
                                child: LinearProgressIndicator(
                                  value: (b.spentMinor / b.budget.limitMinor)
                                      .clamp(0, 1)
                                      .toDouble(),
                                ),
                              ),
                              trailing: Text(
                                b.remainingMinor < 0
                                    ? 'Over budget'
                                    : 'On track',
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            if (insight != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    semanticLabel: 'Insight',
                  ),
                  title: Text(insight.title),
                  subtitle: Text(
                    '${insight.summary}${isInsightStale(insight, freshness) ? '\nBased on older synced data — may be out of date.' : ''}',
                  ),
                  onTap: () => context.go('/insights'),
                ),
              ),
            Card(
              child: whenData(
                recent,
                (rows) => Column(
                  children: [
                    ListTile(
                      title: Text('Recent', style: theme.textTheme.titleSmall),
                      trailing: TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: const Text('All'),
                      ),
                    ),
                    if (rows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const Text('No entries yet.'),
                            OutlinedButton(
                              onPressed: () => showEntrySheet(
                                context,
                                mode: EntryMode.quick,
                              ),
                              child: const Text('Quick entry'),
                            ),
                            OutlinedButton(
                              onPressed: () => showEntrySheet(
                                context,
                                mode: EntryMode.category,
                              ),
                              child: const Text('By category'),
                            ),
                          ],
                        ),
                      ),
                    for (final v in rows) TxTile(v, money: money),
                  ],
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
