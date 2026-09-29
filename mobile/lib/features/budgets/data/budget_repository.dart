import 'package:drift/drift.dart';

import '../../../core/data/codecs.dart';
import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/time.dart';

class BudgetProgress {
  const BudgetProgress(this.budget, this.categoryName, this.spentMinor);

  final BudgetRow budget;
  final String categoryName;

  /// Expense in the category subtree for the month; each expense counted once.
  final int spentMinor;
  int get remainingMinor => budget.limitMinor - spentMinor;
}

/// Monthly category budgets: no rollover, never affect balances (docs/09).
class BudgetRepository {
  BudgetRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  static const _sql = '''
SELECT b.*, c.name AS category_name,
  COALESCE((SELECT SUM(t.amount_minor) FROM transactions t
    LEFT JOIN categories tc ON tc.user_id = t.user_id AND tc.id = t.category_id
    WHERE t.user_id = b.user_id AND t.deleted_at IS NULL AND t.type = 'expense'
      AND t.effective_date >= ? AND t.effective_date < ?
      AND (t.category_id = b.category_id OR tc.parent_id = b.category_id)), 0) AS spent_minor
FROM budgets b JOIN categories c ON c.user_id = b.user_id AND c.id = b.category_id
WHERE b.user_id = ? AND b.month = ? AND b.deleted_at IS NULL
ORDER BY c.name
''';

  Stream<List<BudgetProgress>> watchMonth(String month) {
    final from = '$month-01';
    final to = firstOfNextMonth(month);
    return _db
        .customSelect(
          _sql,
          variables: [
            Variable(from),
            Variable(to),
            Variable(store.uid),
            Variable(month),
          ],
          readsFrom: {_db.budgets, _db.categories, _db.transactions},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => BudgetProgress(
                  _db.budgets.map(r.data),
                  r.read<String>('category_name'),
                  r.read<int>('spent_minor'),
                ),
              )
              .toList(),
        );
  }

  static Map<String, Object?> payload({
    required String month,
    required String categoryId,
    required int limitMinor,
    required String currency,
  }) => {
    'month': month,
    'categoryId': categoryId,
    'limitMinor': limitMinor,
    'currency': currency,
  };

  /// Parent and child budgets may not coexist in a month (docs/04).
  Future<Result<void>> validate(
    Map<String, Object?> p, {
    String? excludingId,
  }) async {
    final month = p['month'] as String;
    final categoryId = p['categoryId'] as String;
    final categories = {
      for (final c in await (_db.select(
        _db.categories,
      )..where((c) => c.userId.equals(store.uid))).get())
        c.id: c,
    };
    final cat = categories[categoryId];
    if (cat == null || cat.type != 'expense') {
      return Err(
        AppError.validation({'categoryId': 'Choose an expense category.'}),
      );
    }
    final others =
        await (_db.select(_db.budgets)..where(
              (b) =>
                  b.userId.equals(store.uid) &
                  b.month.equals(month) &
                  b.deletedAt.isNull() &
                  (excludingId == null
                      ? const Constant(true)
                      : b.id.equals(excludingId).not()),
            ))
            .get();
    for (final o in others) {
      if (o.categoryId == categoryId) {
        return Err(
          AppError.validation({
            'categoryId': 'This category already has a budget this month.',
          }),
        );
      }
      if (o.categoryId == cat.parentId ||
          categories[o.categoryId]?.parentId == categoryId) {
        return Err(
          AppError.validation({
            'categoryId': 'A parent and its sub-category cannot both have budgets in the same month.',
          }),
        );
      }
    }
    return const Ok(null);
  }

  Future<Result<void>> create(Map<String, Object?> p, Confirmation c) async {
    final v = await validate(p);
    if (v case Err(:final error)) return Err(error);
    return store.upsert(
      entityType: 'budget',
      id: store.newId(),
      payload: p,
      create: true,
      confirmation: c,
    );
  }

  Future<Result<void>> update(
    BudgetRow current,
    Map<String, Object?> p,
    Confirmation c,
  ) async {
    final v = await validate(p, excludingId: current.id);
    if (v case Err(:final error)) return Err(error);
    return store.upsert(
      entityType: 'budget',
      id: current.id,
      payload: p,
      create: false,
      confirmation: c,
      expectedLocalVersion: current.localVersion,
    );
  }

  Future<Result<void>> delete(BudgetRow current, Confirmation c) =>
      store.delete(
        entityType: 'budget',
        id: current.id,
        confirmation: c,
        expectedLocalVersion: current.localVersion,
      );

  Map<String, Object?> payloadOf(BudgetRow b) => payloadFromRow('budget', b);
}
