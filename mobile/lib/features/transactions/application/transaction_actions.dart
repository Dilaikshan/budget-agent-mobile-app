import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/data/codecs.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/transaction.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../data/ledger_repository.dart';

/// Shared presentation helpers for transaction confirmation, deletion and
/// proposal review. Every financial change goes through [showConfirmationSheet].

String typeLabel(String type) => switch (type) {
  'income' => 'Income',
  'expense' => 'Expense',
  'transfer' => 'Transfer',
  'opening' => 'Opening balance',
  _ => type,
};

String errorText(AppError e) =>
    e.fields.isEmpty ? e.message : e.fields.values.join(' ');

/// Human-readable names for the confirmation rows.
class NameLookup {
  NameLookup({
    required List<AccountRow> accounts,
    required List<CategoryRow> categories,
    required List<IncomeSourceRow> sources,
  }) : _accounts = {for (final a in accounts) a.id: a.name},
       _categories = {for (final c in categories) c.id: c},
       _sources = {for (final s in sources) s.id: s.name};

  final Map<String, String> _accounts;
  final Map<String, CategoryRow> _categories;
  final Map<String, String> _sources;

  String account(String? id) =>
      id == null ? '—' : (_accounts[id] ?? 'Unknown account');
  String source(String? id) =>
      id == null ? '—' : (_sources[id] ?? 'Unknown source');
  String category(String? id) {
    if (id == null) return 'Uncategorized';
    final c = _categories[id];
    if (c == null) return 'Unknown category';
    final parent = c.parentId == null ? null : _categories[c.parentId];
    return parent == null ? c.name : '${parent.name} › ${c.name}';
  }
}

NameLookup nameLookup(WidgetRef ref) => NameLookup(
  accounts: [
    for (final b in ref.read(accountBalancesProvider).value ?? const [])
      b.account,
  ],
  categories: ref.read(categoriesProvider).value ?? const [],
  sources: ref.read(incomeSourcesProvider).value ?? const [],
);

/// Rows shown before saving; [provenance] maps field → "Suggested by AI/rule".
List<ConfirmRow> payloadRows(
  TransactionPayload p,
  NameLookup names, {
  required int exponent,
  Map<String, String> provenance = const {},
}) {
  final amount = formatMinor(
    p.amountMinor,
    currency: p.currency,
    exponent: exponent,
  );
  return [
    ConfirmRow('Type', typeLabel(p.type.name), provenance: provenance['type']),
    ConfirmRow(
      'Amount',
      amount,
      emphasis: true,
      provenance: provenance['amount'],
    ),
    if (p.type == TxType.transfer) ...[
      ConfirmRow(
        'From',
        names.account(p.accountId),
        provenance: provenance['accountId'],
      ),
      ConfirmRow(
        'To',
        names.account(p.destinationAccountId),
        provenance: provenance['destinationAccountId'],
      ),
    ] else
      ConfirmRow(
        p.type == TxType.income ? 'Received into' : 'Paid from',
        names.account(p.accountId),
        provenance: provenance['accountId'],
      ),
    if (p.type != TxType.transfer)
      ConfirmRow(
        'Category',
        names.category(p.categoryId),
        provenance: provenance['categoryId'],
      ),
    if (p.type == TxType.income)
      ConfirmRow(
        'Income source',
        names.source(p.incomeSourceId),
        provenance: provenance['incomeSourceId'],
      ),
    if (p.merchant != null) ConfirmRow('Merchant', p.merchant!),
    if (p.description.isNotEmpty) ConfirmRow('Description', p.description),
    ConfirmRow('Date', p.effectiveDate),
  ];
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
      ?.showSnackBar(SnackBar(content: Text(message)));
}

/// Confirmed tombstone delete; opening balances are refused by the repository.
Future<bool> confirmDeleteTransaction(
  BuildContext context,
  WidgetRef ref,
  TransactionRow row,
) async {
  final profile = ref.read(profileProvider).value;
  final ledger = ref.read(ledgerRepositoryProvider);
  String? failure;
  final c = await showConfirmationSheet(
    context,
    title: 'Delete this ${typeLabel(row.type).toLowerCase()}?',
    rows: [
      ConfirmRow(
        'Amount',
        formatMinor(
          row.amountMinor,
          currency: row.currency,
          exponent: profile?.currencyExponent ?? 2,
        ),
        emphasis: true,
      ),
      ConfirmRow('Date', row.effectiveDate),
      if (row.description.isNotEmpty)
        ConfirmRow('Description', row.description),
    ],
    payload: LedgerRepository.deleteConfirmationPayload(row.id),
    saveLabel: 'Delete',
    destructive: true,
    note: 'Its effect is removed from balances. The deletion syncs to your other devices.',
    onConfirm: (c) async {
      final r = await ledger.confirmDelete(row, c);
      if (r case Err(:final error)) failure = errorText(error);
      return r.isOk;
    },
  );
  if (failure != null && context.mounted) showMessage(context, failure!);
  return c != null;
}

/// Accept a category-change proposal: exact current payload with the new
/// category, bound to the proposal; stale or empty proposals are never accepted.
Future<void> acceptCategoryProposal(
  BuildContext context,
  WidgetRef ref,
  ProposalView proposal, {
  required VoidCallback onNeedsManualEdit,
}) async {
  final store = ref.read(localStoreProvider)!;
  final targetId = proposal.row.targetId;
  final row = targetId == null
      ? null
      : await store.row('transaction', targetId) as TransactionRow?;
  final now = ref.read(clockProvider)();
  final stale = proposal.isStaleAt(
    now,
    currentTargetRevision: row?.revision,
    targetDeleted: row == null || row.deletedAt != null,
  );
  // A pending local edit also makes the suggestion out of date.
  if (stale || row == null || row.syncStatus != 'synced') {
    if (context.mounted) {
      showMessage(
        context,
        'This suggestion is out of date. Review the entry and choose a category manually.',
      );
    }
    return;
  }
  final categoryId = proposal.candidate['categoryId'] as String?;
  if (categoryId == null) {
    onNeedsManualEdit();
    return;
  }
  if (!context.mounted) return;
  final current = TransactionPayload.fromJson(
    payloadFromRow('transaction', row),
  );
  final payload = TransactionPayload.fromJson({
    ...current.toJson(),
    'categoryId': categoryId,
    'categorizationSource': 'ai',
    'proposalId': proposal.row.id,
  });
  final exponent = ref.read(profileProvider).value?.currencyExponent ?? 2;
  final ledger = ref.read(ledgerRepositoryProvider);
  String? failure;
  await showConfirmationSheet(
    context,
    title: 'Change category?',
    rows: [
      ConfirmRow(
        'Category',
        '${nameLookup(ref).category(current.categoryId)} → ${nameLookup(ref).category(categoryId)}',
        emphasis: true,
        provenance:
            'Suggested by AI (${(proposal.confidence * 100).round()}% confidence)',
      ),
      ...payloadRows(
        payload,
        nameLookup(ref),
        exponent: exponent,
      ).where((r) => r.label != 'Category'),
    ],
    payload: payload.toJson(),
    note: 'Only the category changes. Amount, account and date stay the same.',
    onConfirm: (c) async {
      final r = await ledger.confirmUpdate(row, payload, c);
      if (r case Err(:final error)) failure = errorText(error);
      return r.isOk;
    },
  );
  if (failure != null && context.mounted) showMessage(context, failure!);
}

Future<void> rejectProposal(
  BuildContext context,
  WidgetRef ref,
  ProposalView proposal,
) async {
  final r = await ref
      .read(agentRepositoryProvider)
      .rejectProposal(proposal.row.id);
  if (!context.mounted) return;
  showMessage(
    context,
    r.isOk ? 'Suggestion dismissed.' : 'Could not dismiss the suggestion.',
  );
}
