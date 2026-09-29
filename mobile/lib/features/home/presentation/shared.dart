import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/time.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../../budgets/data/budget_repository.dart';
import '../../transactions/data/ledger_repository.dart';

/// Screen-level providers and helpers shared by the home/more/settings family
/// of screens. Everything reads repositories; no SQL or SDK calls here.

class Money {
  const Money(this.currency, this.exponent, this.timeZone);
  final String currency;
  final int exponent;
  final String timeZone;
}

/// Currency/exponent/time zone from the local profile (defaults until loaded).
final moneyProvider = Provider<Money>((ref) {
  final p = ref.watch(profileProvider).value;
  return Money(
    p?.baseCurrency ?? 'LKR',
    p?.currencyExponent ?? 2,
    p?.timeZone ?? 'Asia/Colombo',
  );
});

/// Today's local date in the profile time zone.
final todayProvider = Provider<String>(
  (ref) => localDateOf(
    ref.watch(clockProvider)(),
    ref.watch(moneyProvider).timeZone,
  ),
);

final monthTotalsProvider =
    StreamProvider.family<({int income, int expense}), (String, String)>(
      (ref, range) =>
          ref.watch(ledgerRepositoryProvider).watchTotals(range.$1, range.$2),
    );

final budgetMonthProvider = StreamProvider.family<List<BudgetProgress>, String>(
  (ref, month) => ref.watch(budgetRepositoryProvider).watchMonth(month),
);

/// Keyed by a record (TransactionFilter has no value equality).
final transactionsProvider =
    StreamProvider.family<
      List<TransactionView>,
      ({String? accountId, int limit})
    >(
      (ref, k) => ref
          .watch(ledgerRepositoryProvider)
          .watchTransactions(
            TransactionFilter(accountId: k.accountId, limit: k.limit),
          ),
    );

final insightsProvider = StreamProvider<List<InsightView>>(
  (ref) => ref.watch(agentRepositoryProvider).watchInsights(),
);

final freshnessProvider =
    StreamProvider<({int lastLedgerSeq, int pendingLedgerOps})>(
      (ref) => ref.watch(agentRepositoryProvider).watchFreshness(),
    );

final pendingProposalsProvider = StreamProvider<List<ProposalView>>(
  (ref) => ref.watch(agentRepositoryProvider).watchPendingProposals(),
);

final activityProvider = StreamProvider.family<List<ActivityView>, String?>(
  (ref, outcome) =>
      ref.watch(agentRepositoryProvider).watchActivity(outcome: outcome),
);

final rulesProvider = StreamProvider<List<RuleRow>>(
  (ref) => ref.watch(ruleRepositoryProvider).watchAll(),
);

bool isInsightStale(
  InsightView i,
  ({int lastLedgerSeq, int pendingLedgerOps})? f,
) =>
    f != null &&
    (f.pendingLedgerOps > 0 || f.lastLedgerSeq > i.row.sourceWatermark);

String formatLocalTime(int? epochMs) {
  if (epochMs == null) return 'Never';
  final t = DateTime.fromMillisecondsSinceEpoch(epochMs).toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

void showResult(BuildContext context, Result<Object?> r, {String? success}) {
  if (!context.mounted) return;
  final message = switch (r) {
    Ok() => success,
    Err(:final error) =>
      error.fields.isNotEmpty ? error.fields.values.join('\n') : error.message,
  };
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Converts a Result into the ConfirmationSheet onConfirm contract, showing errors.
Future<bool> confirmResult(
  BuildContext context,
  Future<Result<Object?>> Function() action, {
  String? success,
}) async {
  final r = await action();
  if (context.mounted) showResult(context, r, success: success);
  return r.isOk;
}

/// Consistent async rendering for stream-backed sections.
Widget whenData<T>(AsyncValue<T> v, Widget Function(T) data) => v.when(
  data: data,
  loading: () => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator()),
  ),
  error: (_, _) => const Padding(
    padding: EdgeInsets.all(24),
    child: Text('Could not load local data.'),
  ),
);

String typeLabel(String t) =>
    t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
