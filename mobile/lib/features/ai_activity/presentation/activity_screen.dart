import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common.dart';
import '../../home/presentation/shared.dart';
import '../data/agent_repository.dart';

/// Chronological AI Activity timeline (docs/09, docs/11).
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String? _outcome;

  static const _filters = <(String?, String)>[
    (null, 'All'),
    ('needsReview', 'Needs review'),
    ('proposed', 'Suggested'),
    ('applied', 'Applied'),
    ('skipped', 'Skipped'),
    ('failed', 'Failed'),
  ];

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(activityProvider(_outcome));
    return Scaffold(
      appBar: AppBar(title: const Text('AI Activity')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final (value, label) in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _outcome == value,
                      onSelected: (_) => setState(() => _outcome = value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: whenData(activity, (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.history,
                  title: 'Nothing here yet',
                  message: 'When the assistant suggests something or the daily review runs, it is recorded here.',
                );
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _ActivityTile(list[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

String _agentLabel(String t) => switch (t) {
  'transactionParsing' => 'Quick entry',
  'categorization' => 'Categorization',
  'dailyReview' => 'Daily review',
  'consistencyCheck' => 'Consistency check',
  'recurringDetection' => 'Recurring detection',
  'patternLearning' => 'Pattern learning',
  'insight' => 'Insight',
  'accountSuggestion' => 'Account suggestion',
  _ => t,
};

String _outcomeLabel(String o) => switch (o) {
  'needsReview' => 'Needs review',
  'proposed' => 'Suggested (not applied)',
  'applied' => 'Applied after your confirmation',
  'skipped' => 'No change',
  'failed' => 'Failed',
  _ => o,
};

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(this.a);
  final ActivityView a;

  @override
  Widget build(BuildContext context) {
    final created = a.createdAt == null
        ? ''
        : formatLocalTime(a.createdAt!.millisecondsSinceEpoch);
    final icon = switch (a.row.outcome) {
      'failed' => Icons.error_outline,
      'needsReview' => Icons.fact_check_outlined,
      'applied' => Icons.check_circle_outline,
      _ => Icons.auto_awesome_outlined,
    };
    return ExpansionTile(
      leading: Icon(icon, semanticLabel: _outcomeLabel(a.row.outcome)),
      title: Text(a.summary),
      subtitle: Text(
        '${_agentLabel(a.row.agentType)} · ${_outcomeLabel(a.row.outcome)}${created.isEmpty ? '' : ' · $created'}',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a.provider == null
              ? 'No AI call needed (rules or deterministic checks).'
              : 'Provider: ${a.provider} · Model: ${a.model ?? 'unknown'}',
        ),
        Wrap(
          spacing: 8,
          children: [
            if (a.proposalId != null)
              TextButton(
                onPressed: () => context.go('/home/review'),
                child: const Text('Open suggestion'),
              ),
            for (final id in a.entityIds.take(5))
              TextButton(
                onPressed: () => context.go('/transactions/$id'),
                child: Text(
                  'Entry ${id.substring(0, id.length < 8 ? id.length : 8)}',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
