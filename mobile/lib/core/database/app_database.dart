import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/canonical_json.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Per-UID SQLite database (docs/07 "Local protection"). Screens read only
/// through repositories; migrations are numbered and never recreate data.
@DriftDatabase(
  tables: [
    Profiles,
    SettingsRecords,
    Accounts,
    IncomeSources,
    Categories,
    Transactions,
    CategorizationRules,
    Budgets,
    AiInsights,
    AiProposals,
    ReviewStates,
    AiActivities,
    AgentRuns,
    OutboxOps,
    RemoteShadows,
    SyncCursors,
    SyncConflicts,
    Drafts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the file-backed database for one Firebase UID in app-private storage.
  factory AppDatabase.forUser(String uid) => AppDatabase(
    driftDatabase(name: 'budget_agent_${sha256Hex(uid).substring(0, 16)}'),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // One live budget per month/category; tombstones are kept for sync.
      await customStatement(
        'CREATE UNIQUE INDEX budgets_month_category ON budgets (user_id, month, category_id) WHERE deleted_at IS NULL',
      );
    },
    onUpgrade: (m, from, to) async {
      // Forward-only numbered migrations go here; never drop and recreate.
      throw StateError('No migration path from $from to $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
