import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/data/local_store.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../core/sync/sync_engine.dart';
import '../features/accounts/data/account_repository.dart';
import '../features/ai_activity/data/agent_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/budgets/data/budget_repository.dart';
import '../features/categories/data/category_repository.dart';
import '../features/settings/data/profile_repository.dart';
import '../features/transactions/data/ledger_repository.dart';

/// Dependency wiring. Widgets read repositories/controllers only; SDK calls
/// live in adapters. Everything below [localStoreProvider] is per-UID and is
/// disposed (database closed, requests cancelled) on sign-out.

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    FirebaseAuth.instance,
    googleServerClientId: ref.watch(appConfigProvider).googleServerClientId,
  ),
);

final userProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).userChanges(),
);

final sessionProvider = Provider<Session>(
  (ref) => sessionOf(ref.watch(userProvider).value),
);

/// UID of a verified signed-in user, or null.
final currentUidProvider = Provider<String?>(
  (ref) => switch (ref.watch(sessionProvider)) {
    SignedIn(:final uid) => uid,
    _ => null,
  },
);

final databaseProvider = Provider<AppDatabase?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = AppDatabase.forUser(uid);
  ref.onDispose(db.close);
  return db;
});

final localStoreProvider = Provider<LocalStore?>((ref) {
  final db = ref.watch(databaseProvider);
  final uid = ref.watch(currentUidProvider);
  if (db == null || uid == null) return null;
  return LocalStore(db, uid, clock: ref.watch(clockProvider));
});

LocalStore _store(Ref ref) =>
    ref.watch(localStoreProvider) ?? (throw StateError('No signed-in user'));

class FirebaseCredentials implements CredentialSource {
  @override
  Future<String?> idToken({bool forceRefresh = false}) async =>
      FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);

  @override
  Future<String?> appCheckToken() async {
    try {
      return await FirebaseAppCheck.instance.getToken();
    } on FirebaseException {
      return null; // the backend rejects the request; sync stays paused, data stays local
    }
  }
}

final apiClientProvider = Provider<ApiClient?>((ref) {
  if (ref.watch(currentUidProvider) == null) return null;
  final client = ApiClient(
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
    credentials: FirebaseCredentials(),
  );
  ref.onDispose(() => client.dio.close(force: true));
  return client;
});

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(_store(ref)),
);
final accountRepositoryProvider = Provider(
  (ref) => AccountRepository(_store(ref)),
);
final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(_store(ref)),
);
final incomeSourceRepositoryProvider = Provider(
  (ref) => IncomeSourceRepository(_store(ref)),
);
final ruleRepositoryProvider = Provider((ref) => RuleRepository(_store(ref)));
final ledgerRepositoryProvider = Provider(
  (ref) => LedgerRepository(_store(ref)),
);
final budgetRepositoryProvider = Provider(
  (ref) => BudgetRepository(_store(ref)),
);
final agentRepositoryProvider = Provider(
  (ref) => AgentRepository(_store(ref), ref.watch(apiClientProvider)),
);

final profileProvider = StreamProvider<ProfileRow?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);
final settingsProvider = StreamProvider<SettingsRow?>(
  (ref) => ref.watch(profileRepositoryProvider).watchSettings(),
);
final accountBalancesProvider = StreamProvider<List<AccountBalance>>(
  (ref) => ref.watch(accountRepositoryProvider).watchBalances(),
);
final activeAccountsProvider = StreamProvider<List<AccountRow>>(
  (ref) => ref.watch(accountRepositoryProvider).watchActive(),
);
final categoriesProvider = StreamProvider<List<CategoryRow>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);
final incomeSourcesProvider = StreamProvider<List<IncomeSourceRow>>(
  (ref) => ref.watch(incomeSourceRepositoryProvider).watchAll(),
);
final pendingOpsProvider = StreamProvider<int>(
  (ref) => _store(ref).watchPendingCount(),
);
final cursorProvider = StreamProvider<CursorRow?>(
  (ref) => _store(ref).watchCursor(),
);
final conflictsProvider = StreamProvider<List<ConflictRow>>(
  (ref) => _store(ref).watchOpenConflicts(),
);
final blockedOpsProvider = StreamProvider<List<OutboxRow>>(
  (ref) => _store(ref).watchBlocked(),
);
final reviewCountProvider = StreamProvider<int>(
  (ref) => ref.watch(agentRepositoryProvider).watchReviewCount(),
);

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final store = ref.watch(localStoreProvider);
  final api = ref.watch(apiClientProvider);
  if (store == null || api == null) return null;
  return SyncEngine(store, api);
});

class SyncStatus {
  const SyncStatus({this.running = false, this.last, this.message});
  final bool running;
  final SyncSummary? last;
  final String? message;
}

/// Serialized, opportunistic sync triggers: launch, resume, connectivity,
/// local writes and "Sync now". Background execution is never required.
class SyncController extends Notifier<SyncStatus> {
  Timer? _debounce;

  @override
  SyncStatus build() {
    ref.onDispose(() => _debounce?.cancel());
    // Local writes schedule a debounced cycle.
    ref.listen(pendingOpsProvider, (prev, next) {
      final before = prev?.value ?? 0;
      final after = next.value ?? 0;
      if (after > before) schedule();
    });
    return const SyncStatus();
  }

  void schedule([Duration delay = const Duration(seconds: 2)]) {
    _debounce?.cancel();
    _debounce = Timer(delay, syncNow);
  }

  Future<void> syncNow() async {
    final engine = ref.read(syncEngineProvider);
    if (engine == null || state.running) return;
    state = SyncStatus(running: true, last: state.last);
    try {
      final s = await engine.syncOnce();
      state = SyncStatus(
        last: s,
        message: s.pausedReason == null
            ? null
            : ApiFailure(0, s.pausedReason!).toAppError().message,
      );
    } catch (_) {
      state = SyncStatus(
        last: state.last,
        message: 'Sync failed; your data is safe on this device.',
      );
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);
