import 'package:drift/drift.dart';

import '../../../core/data/codecs.dart';
import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/transaction.dart';

/// Filter for history (docs/09 "History, conflicts and budgets").
class TransactionFilter {
  const TransactionFilter({
    this.type,
    this.accountId,
    this.categoryId,
    this.incomeSourceId,
    this.from,
    this.toExclusive,
    this.syncStatus,
    this.limit = 200,
  });

  final String? type;
  final String? accountId;
  final String? categoryId;
  final String? incomeSourceId;
  final String? from;
  final String? toExclusive;
  final String? syncStatus;
  final int limit;
}

class TransactionView {
  const TransactionView(
    this.row, {
    this.accountName,
    this.destinationName,
    this.categoryName,
    this.sourceName,
    this.reviewState,
  });

  final TransactionRow row;
  final String? accountName;
  final String? destinationName;
  final String? categoryName;
  final String? sourceName;
  final String? reviewState;
}

/// Synchronous reference snapshot used by the shared draft validator.
class ReferenceSnapshot implements ReferenceLookup {
  ReferenceSnapshot({
    required List<AccountRow> accounts,
    required List<CategoryRow> categories,
    required List<IncomeSourceRow> sources,
  }) : _accounts = {for (final a in accounts) a.id: a},
       _categories = {for (final c in categories) c.id: c},
       _sources = {for (final s in sources) s.id: s};

  final Map<String, AccountRow> _accounts;
  final Map<String, CategoryRow> _categories;
  final Map<String, IncomeSourceRow> _sources;

  @override
  ({bool exists, bool archived, String? currency})? account(String id) {
    final a = _accounts[id];
    return a == null || a.deletedAt != null
        ? null
        : (exists: true, archived: a.archived, currency: a.currency);
  }

  @override
  ({bool exists, bool archived, String type})? category(String id) {
    final c = _categories[id];
    return c == null || c.deletedAt != null
        ? null
        : (exists: true, archived: c.archived, type: c.type);
  }

  @override
  ({bool exists, bool archived})? incomeSource(String id) {
    final s = _sources[id];
    return s == null || s.deletedAt != null
        ? null
        : (exists: true, archived: s.archived);
  }
}

class LedgerRepository {
  LedgerRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  Future<ReferenceSnapshot> references() async => ReferenceSnapshot(
    accounts: await (_db.select(
      _db.accounts,
    )..where((a) => a.userId.equals(store.uid))).get(),
    categories: await (_db.select(
      _db.categories,
    )..where((c) => c.userId.equals(store.uid))).get(),
    sources: await (_db.select(
      _db.incomeSources,
    )..where((s) => s.userId.equals(store.uid))).get(),
  );

  Stream<List<TransactionView>> watchTransactions(TransactionFilter f) {
    final tx = _db.transactions;
    final q =
        _db.select(tx).join([
            leftOuterJoin(
              _db.reviewStates,
              _db.reviewStates.userId.equalsExp(tx.userId) &
                  _db.reviewStates.id.equalsExp(tx.id) &
                  _db.reviewStates.deletedAt.isNull(),
            ),
          ])
          ..where(tx.userId.equals(store.uid) & tx.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.desc(tx.effectiveDate),
            OrderingTerm.desc(tx.occurredAt),
            OrderingTerm.desc(tx.id),
          ])
          ..limit(f.limit);
    if (f.type != null) q.where(tx.type.equals(f.type!));
    if (f.accountId != null) {
      q.where(
        tx.accountId.equals(f.accountId!) |
            tx.destinationAccountId.equals(f.accountId!),
      );
    }
    if (f.categoryId != null) q.where(tx.categoryId.equals(f.categoryId!));
    if (f.incomeSourceId != null) {
      q.where(tx.incomeSourceId.equals(f.incomeSourceId!));
    }
    if (f.from != null) q.where(tx.effectiveDate.isBiggerOrEqualValue(f.from!));
    if (f.toExclusive != null) {
      q.where(tx.effectiveDate.isSmallerThanValue(f.toExclusive!));
    }
    if (f.syncStatus != null) q.where(tx.syncStatus.equals(f.syncStatus!));

    return q.watch().asyncMap((rows) async {
      final names = await _names();
      return rows.map((r) {
        final t = r.readTable(tx);
        return TransactionView(
          t,
          accountName: names.accounts[t.accountId],
          destinationName: names.accounts[t.destinationAccountId],
          categoryName: names.categories[t.categoryId],
          sourceName: names.sources[t.incomeSourceId],
          reviewState: r.readTableOrNull(_db.reviewStates)?.state,
        );
      }).toList();
    });
  }

  Future<
    ({
      Map<String, String> accounts,
      Map<String, String> categories,
      Map<String, String> sources,
    })
  >
  _names() async => (
    accounts: {
      for (final a in await (_db.select(
        _db.accounts,
      )..where((a) => a.userId.equals(store.uid))).get())
        a.id: a.name,
    },
    categories: {
      for (final c in await (_db.select(
        _db.categories,
      )..where((c) => c.userId.equals(store.uid))).get())
        c.id: c.name,
    },
    sources: {
      for (final s in await (_db.select(
        _db.incomeSources,
      )..where((s) => s.userId.equals(store.uid))).get())
        s.id: s.name,
    },
  );

  Stream<TransactionRow?> watchOne(String id) =>
      (_db.select(_db.transactions)
            ..where((t) => t.userId.equals(store.uid) & t.id.equals(id)))
          .watchSingleOrNull();

  /// Month-to-date style totals: openings and transfers excluded.
  Stream<({int income, int expense})> watchTotals(
    String from,
    String toExclusive,
  ) {
    return _db
        .customSelect(
          "SELECT COALESCE(SUM(CASE WHEN type = 'income' THEN amount_minor ELSE 0 END), 0) AS income, "
          "COALESCE(SUM(CASE WHEN type = 'expense' THEN amount_minor ELSE 0 END), 0) AS expense "
          'FROM transactions WHERE user_id = ? AND deleted_at IS NULL AND effective_date >= ? AND effective_date < ?',
          variables: [
            Variable(store.uid),
            Variable(from),
            Variable(toExclusive),
          ],
          readsFrom: {_db.transactions},
        )
        .watchSingle()
        .map(
          (r) =>
              (income: r.read<int>('income'), expense: r.read<int>('expense')),
        );
  }

  Future<Result<void>> confirmCreate(
    String id,
    TransactionPayload p,
    Confirmation c,
  ) => store.upsert(
    entityType: 'transaction',
    id: id,
    payload: p.toJson(),
    create: true,
    confirmation: c,
  );

  Future<Result<void>> confirmUpdate(
    TransactionRow current,
    TransactionPayload p,
    Confirmation c,
  ) => store.upsert(
    entityType: 'transaction',
    id: current.id,
    payload: p.toJson(),
    create: false,
    confirmation: c,
    expectedLocalVersion: current.localVersion,
  );

  Future<Result<void>> confirmDelete(TransactionRow current, Confirmation c) {
    if (current.type == 'opening') {
      return Future.value(
        Err(
          AppError.validation({
            'type':
                'Opening balances cannot be deleted; edit the amount instead.',
          }),
        ),
      );
    }
    return store.delete(
      entityType: 'transaction',
      id: current.id,
      confirmation: c,
      expectedLocalVersion: current.localVersion,
    );
  }

  static Map<String, Object?> deleteConfirmationPayload(String id) => {
    'delete': 'transaction',
    'id': id,
  };

  TransactionPayload payloadOf(TransactionRow r) =>
      TransactionPayload.fromJson(payloadFromRow('transaction', r));
}
