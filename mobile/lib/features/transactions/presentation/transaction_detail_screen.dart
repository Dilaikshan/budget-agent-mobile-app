import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/widgets/common.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../application/transaction_actions.dart';
import 'entry_sheet.dart';

/// Detail: fields, provenance, sync/review state, related AI activity and
/// actions. Nothing here changes the ledger without a confirmation step.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  late final Stream<TransactionRow?> _row = ref
      .read(ledgerRepositoryProvider)
      .watchOne(widget.id);
  late final Stream<List<ActivityView>> _activity = ref
      .read(agentRepositoryProvider)
      .watchActivity();
  late final Stream<List<ProposalView>> _proposals = ref
      .read(agentRepositoryProvider)
      .watchPendingProposals();
  bool _classifying = false;

  Future<void> _suggestCategory(TransactionRow row) async {
    setState(() => _classifying = true);
    final r = await ref
        .read(agentRepositoryProvider)
        .requestClassification(row);
    if (!mounted) return;
    setState(() => _classifying = false);
    showMessage(context, switch (r) {
      Ok() => 'Suggestion requested. It appears here after the next sync.',
      Err(:final error) => error.message,
    });
    if (r.isOk) {
      ref.read(syncControllerProvider.notifier).schedule(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final names = nameLookup(ref);
    ref.watch(accountBalancesProvider);
    ref.watch(categoriesProvider);
    ref.watch(incomeSourcesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: StreamBuilder<TransactionRow?>(
        stream: _row,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting ||
              profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final t = snap.data;
          if (t == null || t.deletedAt != null) {
            return const EmptyState(
              icon: Icons.delete_outline,
              title: 'Entry not found',
              message: 'It may have been deleted on this or another device.',
            );
          }
          final amount = formatMinor(
            t.amountMinor,
            currency: t.currency,
            exponent: profile.currencyExponent,
          );
          final classifiable =
              (t.type == 'expense' || t.type == 'income') &&
              t.categoryId == null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                typeLabel(t.type),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Semantics(
                label: '${typeLabel(t.type)} $amount',
                excludeSemantics: true,
                child: Text(
                  t.type == 'opening' && t.openingDirection == 'debit'
                      ? '-$amount'
                      : amount,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SyncBadge(t.syncStatus),
                  const SizedBox(width: 6),
                  Text(_syncLabel(t.syncStatus)),
                ],
              ),
              const Divider(height: 24),
              if (t.type == 'transfer') ...[
                _field('From', names.account(t.accountId)),
                _field('To', names.account(t.destinationAccountId)),
                _field('Effect', 'Not counted as spending or income'),
              ] else
                _field(
                  t.type == 'income'
                      ? 'Received into'
                      : (t.type == 'opening' ? 'Account' : 'Paid from'),
                  names.account(t.accountId),
                ),
              if (t.type == 'income' || t.type == 'expense')
                _field('Category', names.category(t.categoryId)),
              if (t.type == 'income')
                _field('Income source', names.source(t.incomeSourceId)),
              if (t.merchant != null) _field('Merchant', t.merchant!),
              if (t.description.isNotEmpty)
                _field('Description', t.description),
              _field('Date', t.effectiveDate),
              _field('Entered via', switch (t.origin) {
                'aiInput' => 'Quick entry',
                'opening' => 'Account setup',
                _ => 'Manual entry',
              }),
              if (t.categorizationSource != null)
                _field('Category chosen by', switch (t.categorizationSource) {
                  'ai' => 'AI suggestion you confirmed',
                  'rule' => 'Your rule, confirmed',
                  _ => 'You',
                }),
              if (t.proposalId != null)
                _field('Linked suggestion', 'Accepted AI proposal'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (t.type != 'opening') ...[
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          showEntrySheet(context, editTransactionId: t.id),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (await confirmDeleteTransaction(context, ref, t) &&
                            context.mounted) {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ] else
                    const Text('Edit opening balances from More › Accounts.'),
                  if (classifiable)
                    OutlinedButton.icon(
                      onPressed: _classifying || t.revision == 0
                          ? null
                          : () => _suggestCategory(t),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        t.revision == 0
                            ? 'Suggest category (after sync)'
                            : 'Suggest category',
                      ),
                    ),
                ],
              ),
              StreamBuilder<List<ProposalView>>(
                stream: _proposals,
                builder: (context, ps) {
                  final mine = (ps.data ?? const <ProposalView>[])
                      .where(
                        (p) =>
                            p.row.kind == 'categoryChange' &&
                            p.row.targetId == t.id,
                      )
                      .toList();
                  if (mine.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Suggestions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final p in mine)
                        ProposalCard(proposal: p, transaction: t),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'AI Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              StreamBuilder<List<ActivityView>>(
                stream: _activity,
                builder: (context, as) {
                  final related = (as.data ?? const <ActivityView>[])
                      .where((a) => a.entityIds.contains(t.id))
                      .toList();
                  if (related.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No AI activity for this entry.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final a in related)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.auto_awesome_outlined),
                          title: Text(a.summary),
                          subtitle: Text(
                            [
                              a.row.outcome,
                              if (a.createdAt != null)
                                a.createdAt!.toLocal().toString().substring(
                                  0,
                                  16,
                                ),
                            ].join(' · '),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _syncLabel(String s) => switch (s) {
    'synced' => 'Synced',
    'pending' || 'syncing' => 'Saved on this device; waiting to sync',
    'conflict' => 'Changed on another device — resolve in More › Sync',
    _ => 'Could not sync — see More › Sync',
  };

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

/// A category-change suggestion with explicit Accept/Reject; stale ones are
/// marked out of date and offer manual editing instead.
class ProposalCard extends ConsumerWidget {
  const ProposalCard({
    super.key,
    required this.proposal,
    required this.transaction,
  });

  final ProposalView proposal;
  final TransactionRow? transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = nameLookup(ref);
    final t = transaction;
    final stale =
        proposal.isStaleAt(
          ref.read(clockProvider)(),
          currentTargetRevision: t?.revision,
          targetDeleted: t == null || t.deletedAt != null,
        ) ||
        (t != null && t.syncStatus != 'synced');
    final categoryId = proposal.candidate['categoryId'] as String?;
    final confidence = (proposal.confidence * 100).round();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryId == null
                  ? 'No confident category — choose one'
                  : 'Suggested category: ${names.category(categoryId)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              confidence < 60
                  ? 'Low confidence ($confidence%)'
                  : 'Confidence $confidence% (advisory)',
            ),
            for (final q in proposal.questions) Text('• $q'),
            if (proposal.evidenceIds.isNotEmpty)
              Text(
                'Based on ${proposal.evidenceIds.length} past entr${proposal.evidenceIds.length == 1 ? 'y' : 'ies'}',
              ),
            if (stale)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Out of date — the entry changed. Review it and choose a category manually.',
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (!stale && categoryId != null)
                  FilledButton(
                    onPressed: () => acceptCategoryProposal(
                      context,
                      ref,
                      proposal,
                      onNeedsManualEdit: () => t == null
                          ? null
                          : showEntrySheet(context, editTransactionId: t.id),
                    ),
                    child: const Text('Review & accept'),
                  ),
                if ((stale || categoryId == null) &&
                    t != null &&
                    t.deletedAt == null)
                  FilledButton.tonal(
                    onPressed: () =>
                        showEntrySheet(context, editTransactionId: t.id),
                    child: const Text('Edit manually'),
                  ),
                TextButton(
                  onPressed: () => rejectProposal(context, ref, proposal),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
