import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/domain/money.dart';
import '../../../core/widgets/common.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../../home/presentation/shared.dart';

/// Deterministic insights from the daily review (docs/09 "AI Activity and Insights").
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final freshness = ref.watch(freshnessProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: whenData(insights, (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.insights_outlined,
            title: 'No insights yet',
            message:
                'Insights appear after the daily review has synced data to work with. Trends need two complete months; '
                'recurring patterns need at least three similar payments. Your totals on Home are always current.',
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Insights summarise synced data at the time they were made. Home totals are always current.',
              ),
            ),
            for (final i in list)
              _InsightCard(i, stale: isInsightStale(i, freshness)),
          ],
        );
      }),
    );
  }
}

class _InsightCard extends ConsumerWidget {
  const _InsightCard(this.insight, {required this.stale});
  final InsightView insight;
  final bool stale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final f = insight.facts;
    final currency = f['currency'] as String? ?? money.currency;
    String fmt(Object? m) => m is int
        ? formatMinor(m, currency: currency, exponent: money.exponent)
        : '—';
    final facts = <String>[
      if (f['periodStart'] != null)
        'Period: ${f['periodStart']} to before ${f['periodEndExclusive']}',
      if (insight.row.kind == 'dailySummary' ||
          insight.row.kind == 'spendingTrend')
        'Spent ${fmt(f['expenseMinor'])}',
      if (f['comparisonExpenseMinor'] != null)
        'Compared with ${fmt(f['comparisonExpenseMinor'])}',
      if (f['occurrenceCount'] != null)
        '${f['occurrenceCount']} matching entries',
      if (f['medianIntervalDays'] != null)
        'About every ${f['medianIntervalDays']} days',
    ];
    final evidence = insight.evidenceIds;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(insight.summary),
            const SizedBox(height: 8),
            for (final line in facts)
              Text(line, style: Theme.of(context).textTheme.bodySmall),
            if (stale)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: ErrorBanner(
                  'Based on older synced data — newer entries are not included yet.',
                  info: true,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (evidence.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showEvidence(context, evidence),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      '${evidence.length} supporting entr${evidence.length == 1 ? 'y' : 'ies'}',
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    final r = await ref
                        .read(agentRepositoryProvider)
                        .dismissInsight(insight.row.id);
                    if (context.mounted) {
                      showResult(context, r, success: 'Insight dismissed');
                    }
                  },
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEvidence(BuildContext context, List<String> ids) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => ListView(
          children: [
            const ListTile(title: Text('Supporting entries')),
            for (final id in ids)
              ListTile(
                leading: const Icon(Icons.receipt_outlined),
                title: Text('Entry ${id.substring(0, 8)}'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/transactions/$id');
                },
              ),
          ],
        ),
      );
}
