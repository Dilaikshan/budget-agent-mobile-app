import 'package:drift/drift.dart';

import '../../../core/data/codecs.dart';
import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/text.dart';
import '../../../core/domain/time.dart';

/// Profile and settings singletons (docs/04). Settings saves carry
/// confirmation for audit consistency like every other metadata save.
class ProfileRepository {
  ProfileRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  Stream<ProfileRow?> watchProfile() =>
      (_db.select(_db.profiles)
            ..where((p) => p.userId.equals(store.uid) & p.id.equals('profile')))
          .watchSingleOrNull();

  Stream<SettingsRow?> watchSettings() =>
      (_db.select(
            _db.settingsRecords,
          )..where((s) => s.userId.equals(store.uid) & s.id.equals('settings')))
          .watchSingleOrNull();

  Future<ProfileRow?> profile() =>
      (_db.select(_db.profiles)
            ..where((p) => p.userId.equals(store.uid) & p.id.equals('profile')))
          .getSingleOrNull();

  Future<SettingsRow?> settings() =>
      (_db.select(
            _db.settingsRecords,
          )..where((s) => s.userId.equals(store.uid) & s.id.equals('settings')))
          .getSingleOrNull();

  static Map<String, Object?> profilePayload({
    required String displayName,
    required String baseCurrency,
    required int currencyExponent,
    required String timeZone,
    required bool onboardingComplete,
  }) => {
    'displayName': normalizeText(displayName),
    'baseCurrency': baseCurrency,
    'currencyExponent': currencyExponent,
    'timeZone': timeZone,
    'onboardingComplete': onboardingComplete,
  };

  static Map<String, Object?> defaultSettings() => {
    'theme': 'system',
    'aiEnabled': false,
    'dailyReviewEnabled': false,
    'learningEnabled': true,
    'fallbackEnabled': false,
    'privacyPolicyVersion': null,
    'providerConsentAt': null,
    'defaultExpenseAccountId': null,
  };

  Result<Map<String, Object?>> validateProfile(Map<String, Object?> p) {
    final name = boundedText(
      'displayName',
      p['displayName'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(p['baseCurrency'] as String)) {
      return Err(
        AppError.validation({'baseCurrency': 'Use a 3-letter ISO code.'}),
      );
    }
    if (!isValidTimeZone(p['timeZone'] as String)) {
      return Err(AppError.validation({'timeZone': 'Unknown time zone.'}));
    }
    return Ok(p);
  }

  Future<Result<void>> saveProfile(
    Map<String, Object?> payload,
    Confirmation c,
  ) async {
    final v = validateProfile(payload);
    if (v case Err(:final error)) return Err(error);
    final existing = await profile();
    return store.upsert(
      entityType: 'profile',
      id: 'profile',
      payload: payload,
      create: existing == null,
      confirmation: c,
      expectedLocalVersion: existing?.localVersion,
    );
  }

  Future<Result<void>> saveSettings(
    Map<String, Object?> payload,
    Confirmation c,
  ) async {
    final existing = await settings();
    return store.upsert(
      entityType: 'appSettings',
      id: 'settings',
      payload: payload,
      create: existing == null,
      confirmation: c,
      expectedLocalVersion: existing?.localVersion,
    );
  }

  Map<String, Object?> settingsPayload(SettingsRow s) =>
      payloadFromRow('appSettings', s);
  Map<String, Object?> profilePayloadOf(ProfileRow p) =>
      payloadFromRow('profile', p);
}
