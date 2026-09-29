import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/domain/money.dart';
import '../../../core/widgets/common.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../application/transaction_actions.dart';
import '../data/ledger_repository.dart';
import 'transaction_detail_screen.dart';

/// Daily review queue: pending suggestions and entries needing review. Every
/// acceptance opens the normal confirmation; nothing is applied silently.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final Stream<List<ProposalView>> _proposals = ref
      .read(agentRepositoryProvider)
      .watchPendingProposals();
  late final Stream<List<TransactionView>> _txs = ref
      .read(ledgerRepositoryProvider)
      .watchTransactions(const TransactionFilter(limit: 500));

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    ref.watch(categoriesProvider);
    ref.watch(accountBalancesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Review suggestions')),
      body: StreamBuilder<List<TransactionView>>(
        stream: _txs,
        builder: (context, txSnap) => StreamBuilder<List<ProposalView>>(
          stream: _proposals,
          builder: (context, pSnap) {
            if (txSnap.data == null || pSnap.data == null || profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final byId = {for (final v in txSnap.data!) v.row.id: v};
            final proposals = pSnap.data!;
            final proposedTargets = proposals
                .map((p) => p.row.targetId)
                .whereType<String>()
                .toSet();
            final needsReview = txSnap.data!
                .where(
                  (v) =>
                      v.reviewState == 'needsReview' &&
                      !proposedTargets.contains(v.row.id),
                )
                .toList();
            if (proposals.isEmpty && needsReview.isEmpty) {
              return const EmptyState(
                icon: Icons.task_alt,
                title: 'All caught up',
                message: 'No suggestions or entries need review right now.',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final p in proposals)
                  if (p.row.kind == 'categoryChange') ...[
                    if (byId[p.row.targetId] != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          byId[p.row.targetId]!.row.merchant ??
                              byId[p.row.targetId]!.row.description,
                        ),
                        subtitle: Text(
                          '${byId[p.row.targetId]!.row.effectiveDate} · ${formatMinor(byId[p.row.targetId]!.row.amountMinor, currency: profile.baseCurrency, exponent: profile.currencyExponent)}',
                        ),
                        onTap: () =>
                            context.go('/transactions/${p.row.targetId}'),
                      ),
                    ProposalCard(
                      proposal: p,
                      transaction: byId[p.row.targetId]?.row,
                    ),
                  ] else
                    _TransactionProposalCard(
                      proposal: p,
                      currency: profile.baseCurrency,
                      exponent: profile.currencyExponent,
                    ),
                if (needsReview.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Entries needing review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final v in needsReview)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.rate_review_outlined),
                      title: Text(
                        v.row.merchant ??
                            (v.row.description.isEmpty
                                ? typeLabel(v.row.type)
                                : v.row.description),
                      ),
                      subtitle: Text(
                        '${v.row.effectiveDate} · ${v.categoryName ?? 'Uncategorized'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/transactions/${v.row.id}'),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Parse proposals are accepted from the entry form at the time they were
/// made; here they can only be inspected or rejected.
class _TransactionProposalCard extends ConsumerWidget {
  const _TransactionProposalCard({
    required this.proposal,
    required this.currency,
    required this.exponent,
  });

  final ProposalView proposal;
  final String currency;
  final int exponent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = proposal.candidate;
    final amount = c['amountMinor'] as int?;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested ${c['intent'] ?? 'entry'}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              [
                if (amount != null)
                  formatMinor(amount, currency: currency, exponent: exponent),
                if (c['merchant'] != null) c['merchant'] as String,
                if ((c['description'] as String? ?? '').isNotEmpty)
                  c['description'] as String,
              ].join(' · '),
            ),
            const Text('Not saved. Use Add to enter it if it is still needed.'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => rejectProposal(context, ref, proposal),
                child: const Text('Reject'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
