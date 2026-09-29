import 'package:budget_agent/app/providers.dart';
import 'package:budget_agent/core/config/app_config.dart';
import 'package:budget_agent/core/data/local_store.dart';
import 'package:budget_agent/core/database/app_database.dart';
import 'package:budget_agent/core/domain/time.dart';
import 'package:budget_agent/features/accounts/data/account_repository.dart';
import 'package:budget_agent/features/categories/data/category_repository.dart';
import 'package:budget_agent/features/settings/data/profile_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Widget-test harness: in-memory database, fixed clock, no network/Firebase.
const testUid = 'testUid1';
final testNow = DateTime.utc(2026, 9, 9, 8);

final testConfig = AppConfig(
  env: AppEnv.development,
  apiBaseUrl: Uri.parse('https://example.invalid'),
  firebaseApiKey: 'k',
  firebaseAppId: 'a',
  firebaseMessagingSenderId: 's',
  firebaseProjectId: 'p',
  googleServerClientId: 'g',
  appCheckDebug: false,
);

class TestEnv {
  TestEnv() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    ensureTimeZones();
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    store = LocalStore(db, testUid, clock: () => testNow);
  }

  late final AppDatabase db;
  late final LocalStore store;

  List<Override> get overrides => [
    appConfigProvider.overrideWithValue(testConfig),
    clockProvider.overrideWithValue(() => testNow),
    currentUidProvider.overrideWithValue(testUid),
    databaseProvider.overrideWithValue(db),
    localStoreProvider.overrideWithValue(store),
    apiClientProvider.overrideWithValue(null),
    syncEngineProvider.overrideWithValue(null),
  ];

  Widget wrap(Widget child) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );

  /// Profile + settings + Cash (LKR 5,000.00) + Bank (LKR 100,000.00) + default categories + one employer source.
  Future<({String cash, String bank})> seed() async {
    final profile = ProfileRepository.profilePayload(
      displayName: 'Me',
      baseCurrency: 'LKR',
      currencyExponent: 2,
      timeZone: 'Asia/Colombo',
      onboardingComplete: true,
    );
    await store.upsert(
      entityType: 'profile',
      id: 'profile',
      payload: profile,
      create: true,
      confirmation: Confirmation.ofDisplayed(profile, testNow),
    );
    final settings = ProfileRepository.defaultSettings();
    await store.upsert(
      entityType: 'appSettings',
      id: 'settings',
      payload: settings,
      create: true,
      confirmation: Confirmation.ofDisplayed(settings, testNow),
    );
    final accounts = AccountRepository(store);
    Future<String> account(String name, String type, int opening) async {
      final a = AccountRepository.accountPayload(
        name: name,
        type: type,
        currency: 'LKR',
      );
      final c = Confirmation.ofDisplayed(
        AccountRepository.compoundPayload(
          a,
          opening,
          '2026-09-01',
          'Asia/Colombo',
        ),
        testNow,
      );
      final r = await accounts.createWithOpening(
        account: a,
        signedOpeningMinor: opening,
        effectiveDate: '2026-09-01',
        timeZone: 'Asia/Colombo',
        confirmation: c,
      );
      return r.valueOrNull!;
    }

    final cash = await account('Cash Wallet', 'cash', 500000);
    final bank = await account('Commercial Bank', 'bank', 10000000);
    final categories = CategoryRepository(store);
    await categories.installDefaults(categories.defaultPayloads(), testNow);
    final source = IncomeSourceRepository.payload(
      name: 'Acme Employer',
      type: 'employer',
    );
    await IncomeSourceRepository(store)
        .create(source, Confirmation.ofDisplayed(source, testNow));
    return (cash: cash, bank: bank);
  }

  Future<void> dispose() => db.close();
}

/// Pumps frames until streams settle (drift streams are async).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
