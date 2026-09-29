import 'package:drift/drift.dart';

import '../../../core/data/codecs.dart';
import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/canonical_json.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/text.dart';
import '../../../core/domain/time.dart';

class AccountBalance {
  const AccountBalance(
    this.account,
    this.balanceMinor, {
    required this.hasPending,
  });

  final AccountRow account;

  /// Derived from confirmed ledger rows (including local pending overlays).
  final int balanceMinor;
  final bool hasPending;
}

/// Accounts hold money; balances are always computed from transactions.
class AccountRepository {
  AccountRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  static const _balanceSql = '''
SELECT a.*,
  COALESCE(SUM(CASE
    WHEN t.id IS NULL THEN 0
    WHEN t.type = 'income' AND t.account_id = a.id THEN t.amount_minor
    WHEN t.type = 'expense' AND t.account_id = a.id THEN -t.amount_minor
    WHEN t.type = 'transfer' AND t.account_id = a.id THEN -t.amount_minor
    WHEN t.type = 'transfer' AND t.destination_account_id = a.id THEN t.amount_minor
    WHEN t.type = 'opening' AND t.account_id = a.id THEN CASE WHEN t.opening_direction = 'debit' THEN -t.amount_minor ELSE t.amount_minor END
    ELSE 0 END), 0) AS balance_minor,
  MAX(CASE WHEN t.sync_status IS NOT NULL AND t.sync_status <> 'synced' THEN 1 WHEN a.sync_status <> 'synced' THEN 1 ELSE 0 END) AS has_pending
FROM accounts a
LEFT JOIN transactions t ON t.user_id = a.user_id AND t.deleted_at IS NULL AND (t.account_id = a.id OR t.destination_account_id = a.id)
WHERE a.user_id = ? AND a.deleted_at IS NULL
GROUP BY a.user_id, a.id
ORDER BY a.archived, a.sort_order, a.name
''';

  /// All accounts (archived included, for total recorded balance) with balances.
  Stream<List<AccountBalance>> watchBalances() => _db
      .customSelect(
        _balanceSql,
        variables: [Variable(store.uid)],
        readsFrom: {_db.accounts, _db.transactions},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => AccountBalance(
                _db.accounts.map(r.data),
                r.read<int>('balance_minor'),
                hasPending: r.read<int>('has_pending') == 1,
              ),
            )
            .toList(),
      );

  Stream<List<AccountRow>> watchActive() =>
      (_db.select(_db.accounts)
            ..where(
              (a) =>
                  a.userId.equals(store.uid) &
                  a.deletedAt.isNull() &
                  a.archived.equals(false),
            )
            ..orderBy([
              (a) => OrderingTerm.asc(a.sortOrder),
              (a) => OrderingTerm.asc(a.name),
            ]))
          .watch();

  Future<List<AccountRow>> all() => (_db.select(
    _db.accounts,
  )..where((a) => a.userId.equals(store.uid) & a.deletedAt.isNull())).get();

  Future<AccountRow?> byId(String id) =>
      (_db.select(_db.accounts)
            ..where((a) => a.userId.equals(store.uid) & a.id.equals(id)))
          .getSingleOrNull();

  static Map<String, Object?> accountPayload({
    required String name,
    required String type,
    required String currency,
    bool archived = false,
    int sortOrder = 0,
  }) => {
    'name': normalizeText(name),
    'type': type,
    'currency': currency,
    'archived': archived,
    'sortOrder': sortOrder,
  };

  /// The exact payload the confirmation sheet must display for account creation.
  static Map<String, Object?> compoundPayload(
    Map<String, Object?> account,
    int signedOpeningMinor,
    String effectiveDate,
    String timeZone,
  ) => {
    'account': account,
    'opening': {
      'signedOpeningMinor': signedOpeningMinor,
      'occurredAt': toInstant(noonInZone(effectiveDate, timeZone)),
      'effectiveDate': effectiveDate,
      'entryTimeZone': timeZone,
    },
  };

  Future<Result<String>> createWithOpening({
    required Map<String, Object?> account,
    required int signedOpeningMinor,
    required String effectiveDate,
    required String timeZone,
    required Confirmation confirmation,
    String? id,
  }) async {
    final name = boundedText(
      'name',
      account['name'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    final accountId = id ?? store.newId();
    final r = await store.createAccountWithOpening(
      accountId: accountId,
      account: account,
      signedOpeningMinor: signedOpeningMinor,
      effectiveDate: effectiveDate,
      timeZone: timeZone,
      confirmation: confirmation,
    );
    return switch (r) {
      Ok() => Ok(accountId),
      Err(:final error) => Err(error),
    };
  }

  /// Rename/archive/sort. Type and currency are immutable once referenced.
  Future<Result<void>> update(
    AccountRow current,
    Map<String, Object?> payload,
    Confirmation c,
  ) async {
    if (payload['type'] != current.type ||
        payload['currency'] != current.currency) {
      return Err(
        AppError.validation({
          'type': 'Account type and currency cannot change; archive and create a new account.',
        }),
      );
    }
    final name = boundedText(
      'name',
      payload['name'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    return store.upsert(
      entityType: 'account',
      id: current.id,
      payload: payload,
      create: false,
      confirmation: c,
      expectedLocalVersion: current.localVersion,
    );
  }

  Map<String, Object?> payloadOf(AccountRow a) => payloadFromRow('account', a);

  Future<TransactionRow?> opening(String accountId) =>
      (_db.select(_db.transactions)..where(
            (t) =>
                t.userId.equals(store.uid) &
                t.id.equals(openingTransactionId(accountId)),
          ))
          .getSingleOrNull();

  /// Opening correction: same transaction, revision-checked, confirmed (docs/04).
  static Map<String, Object?> openingPayload(
    TransactionRow opening,
    int signedOpeningMinor,
  ) => {
    ...payloadFromRow('transaction', opening),
    'amountMinor': signedOpeningMinor.abs(),
    'openingDirection': signedOpeningMinor < 0 ? 'debit' : 'credit',
  };

  Future<Result<void>> changeOpening(
    TransactionRow opening,
    int signedOpeningMinor,
    Confirmation c,
  ) => store.upsert(
    entityType: 'transaction',
    id: opening.id,
    payload: openingPayload(opening, signedOpeningMinor),
    create: false,
    confirmation: c,
    expectedLocalVersion: opening.localVersion,
  );
}
