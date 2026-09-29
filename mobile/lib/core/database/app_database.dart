import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserProfiles,
  Accounts,
  IncomeSources,
  Categories,
  Transactions,
  CategorizationRules,
  Budgets,
  OutboxOperations,
  SyncCursors,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'budget_agent_db',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
      ),
    );
  }

  // Reactive Watchers
  Stream<List<Account>> watchAllAccounts() =>
      (select(accounts)..where((a) => a.archived.equals(false))).watch();

  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).watch();

  Stream<List<Category>> watchCategories() =>
      (select(categories)..where((c) => c.archived.equals(false))).watch();

  Stream<List<IncomeSource>> watchIncomeSources() =>
      (select(incomeSources)..where((s) => s.archived.equals(false))).watch();

  Stream<List<Budget>> watchBudgetsForMonth(String month) =>
      (select(budgets)..where((b) => b.month.equals(month))).watch();

  Stream<List<CategorizationRule>> watchActiveRules() =>
      (select(categorizationRules)
            ..where((r) => r.enabled.equals(true))
            ..orderBy([(r) => OrderingTerm.desc(r.priority)]))
          .watch();

  // Atomic Account Creation with Opening Balance
  Future<void> createAccountWithOpening({
    required AccountsCompanion accountCompanion,
    required TransactionsCompanion openingTxCompanion,
    required OutboxOperationsCompanion outboxCompanion,
  }) {
    return transaction(() async {
      await into(accounts).insert(accountCompanion);
      await into(transactions).insert(openingTxCompanion);
      await into(outboxOperations).insert(outboxCompanion);
    });
  }

  // Atomic Transaction Confirmation with Outbox Enqueue
  Future<void> confirmTransaction({
    required TransactionsCompanion txCompanion,
    required OutboxOperationsCompanion outboxCompanion,
  }) {
    return transaction(() async {
      await into(transactions).insert(txCompanion);
      await into(outboxOperations).insert(outboxCompanion);
    });
  }
}
