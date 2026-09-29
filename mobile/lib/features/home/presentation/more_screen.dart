import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(conflictsProvider).value?.length ?? 0;
    final blocked = ref.watch(blockedOpsProvider).value?.length ?? 0;
    final items = <(IconData, String, String, String?)>[
      (
        Icons.account_balance_wallet_outlined,
        'Accounts',
        '/more/accounts',
        'Where your money is',
      ),
      (
        Icons.category_outlined,
        'Categories',
        '/more/categories',
        'What money is for',
      ),
      (
        Icons.work_outline,
        'Income sources',
        '/more/income-sources',
        'Where income comes from',
      ),
      (
        Icons.rule,
        'Rules',
        '/more/rules',
        'Remembered merchant → category mappings',
      ),
      (
        Icons.pie_chart_outline,
        'Budgets',
        '/more/budgets',
        'Monthly category limits',
      ),
      (
        Icons.history,
        'AI Activity',
        '/more/activity',
        'What the assistant suggested',
      ),
      (
        Icons.sync_problem_outlined,
        'Sync & conflicts',
        '/more/sync',
        conflicts + blocked > 0
            ? '${conflicts + blocked} item(s) need attention'
            : 'Queue and conflicts',
      ),
      (Icons.settings_outlined, 'Settings', '/more/settings', null),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          for (final (icon, title, path, subtitle) in items)
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(path),
            ),
        ],
      ),
    );
  }
}
