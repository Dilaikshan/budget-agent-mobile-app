import 'package:drift/drift.dart';

import '../../../core/data/codecs.dart';
import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/text.dart';

/// Categories identify purpose; two levels max, same type as parent (docs/04).
class CategoryRepository {
  CategoryRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  Stream<List<CategoryRow>> watchAll({bool includeArchived = true}) =>
      (_db.select(_db.categories)
            ..where(
              (c) =>
                  c.userId.equals(store.uid) &
                  c.deletedAt.isNull() &
                  (includeArchived
                      ? const Constant(true)
                      : c.archived.equals(false)),
            )
            ..orderBy([
              (c) => OrderingTerm.asc(c.type),
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.name),
            ]))
          .watch();

  Future<List<CategoryRow>> all() => (_db.select(
    _db.categories,
  )..where((c) => c.userId.equals(store.uid) & c.deletedAt.isNull())).get();

  static Map<String, Object?> payload({
    required String name,
    required String type,
    String? parentId,
    String? icon,
    int sortOrder = 0,
    bool isSystem = false,
    bool archived = false,
  }) => {
    'name': normalizeText(name),
    'type': type,
    'parentId': parentId,
    'icon': icon,
    'sortOrder': sortOrder,
    'isSystem': isSystem,
    'archived': archived,
  };

  Future<Result<void>> validate(
    Map<String, Object?> p, {
    CategoryRow? current,
  }) async {
    final name = boundedText(
      'name',
      p['name'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    if (current != null &&
        (p['type'] != current.type || p['parentId'] != current.parentId)) {
      return Err(
        AppError.validation({
          'parentId': 'Type and parent cannot change after creation; archive and create a new category.',
        }),
      );
    }
    final parentId = p['parentId'] as String?;
    if (parentId != null && current == null) {
      final parent = (await all()).where((c) => c.id == parentId).firstOrNull;
      if (parent == null) {
        return Err(AppError.validation({'parentId': 'Parent not found.'}));
      }
      if (parent.parentId != null) {
        return Err(
          AppError.validation({
            'parentId': 'Categories can be at most two levels deep.',
          }),
        );
      }
      if (parent.type != p['type']) {
        return Err(
          AppError.validation({'parentId': 'Parent must be the same type.'}),
        );
      }
      if (parent.archived) {
        return Err(AppError.validation({'parentId': 'Parent is archived.'}));
      }
    }
    return const Ok(null);
  }

  Future<Result<String>> create(
    Map<String, Object?> p,
    Confirmation c, {
    String? id,
  }) async {
    final v = await validate(p);
    if (v case Err(:final error)) return Err(error);
    final newId = id ?? store.newId();
    final r = await store.upsert(
      entityType: 'category',
      id: newId,
      payload: p,
      create: true,
      confirmation: c,
    );
    return switch (r) {
      Ok() => Ok(newId),
      Err(:final error) => Err(error),
    };
  }

  Future<Result<void>> update(
    CategoryRow current,
    Map<String, Object?> p,
    Confirmation c,
  ) async {
    final v = await validate(p, current: current);
    if (v case Err(:final error)) return Err(error);
    return store.upsert(
      entityType: 'category',
      id: current.id,
      payload: p,
      create: false,
      confirmation: c,
      expectedLocalVersion: current.localVersion,
    );
  }

  Map<String, Object?> payloadOf(CategoryRow c) =>
      payloadFromRow('category', c);

  /// Editable default tree, installed only after the user accepts it (docs/09).
  static const defaults = <({String name, String type, List<String> children})>[
    (name: 'Food', type: 'expense', children: ['Restaurant', 'Groceries']),
    (name: 'Transport', type: 'expense', children: ['Fuel', 'Taxi']),
    (
      name: 'Bills',
      type: 'expense',
      children: ['Electricity', 'Water', 'Phone', 'Internet'],
    ),
    (name: 'Shopping', type: 'expense', children: []),
    (name: 'Health', type: 'expense', children: []),
    (name: 'Salary', type: 'income', children: []),
    (name: 'Freelance', type: 'income', children: []),
    (name: 'Other income', type: 'income', children: []),
  ];

  /// Payload list for the default tree, with stable local UUIDs chosen up front
  /// so the confirmation shows exactly what will be saved.
  List<({String id, Map<String, Object?> payload})> defaultPayloads() {
    final out = <({String id, Map<String, Object?> payload})>[];
    var order = 0;
    for (final root in defaults) {
      final rootId = store.newId();
      out.add((
        id: rootId,
        payload: payload(
          name: root.name,
          type: root.type,
          sortOrder: order++,
          isSystem: true,
        ),
      ));
      for (final child in root.children) {
        out.add((
          id: store.newId(),
          payload: payload(
            name: child,
            type: root.type,
            parentId: rootId,
            sortOrder: order++,
            isSystem: true,
          ),
        ));
      }
    }
    return out;
  }

  Future<Result<void>> installDefaults(
    List<({String id, Map<String, Object?> payload})> items,
    DateTime now,
  ) async {
    for (final item in items) {
      final r = await store.upsert(
        entityType: 'category',
        id: item.id,
        payload: item.payload,
        create: true,
        confirmation: Confirmation.ofDisplayed(item.payload, now),
      );
      if (r case Err(:final error)) return Err(error);
    }
    return const Ok(null);
  }
}

/// Income sources identify origin; they never hold balances.
class IncomeSourceRepository {
  IncomeSourceRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  Stream<List<IncomeSourceRow>> watchAll({bool includeArchived = true}) =>
      (_db.select(_db.incomeSources)
            ..where(
              (s) =>
                  s.userId.equals(store.uid) &
                  s.deletedAt.isNull() &
                  (includeArchived
                      ? const Constant(true)
                      : s.archived.equals(false)),
            )
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .watch();

  Future<List<IncomeSourceRow>> all() => (_db.select(
    _db.incomeSources,
  )..where((s) => s.userId.equals(store.uid) & s.deletedAt.isNull())).get();

  static Map<String, Object?> payload({
    required String name,
    required String type,
    String? defaultAccountId,
    bool archived = false,
  }) => {
    'name': normalizeText(name),
    'type': type,
    'defaultAccountId': defaultAccountId,
    'archived': archived,
  };

  Future<Result<String>> create(Map<String, Object?> p, Confirmation c) async {
    final name = boundedText(
      'name',
      p['name'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    final id = store.newId();
    final r = await store.upsert(
      entityType: 'incomeSource',
      id: id,
      payload: p,
      create: true,
      confirmation: c,
    );
    return switch (r) {
      Ok() => Ok(id),
      Err(:final error) => Err(error),
    };
  }

  Future<Result<void>> update(
    IncomeSourceRow current,
    Map<String, Object?> p,
    Confirmation c,
  ) async {
    if (p['type'] != current.type) {
      return Err(
        AppError.validation({
          'type': 'Type cannot change; archive and create a new source.',
        }),
      );
    }
    final name = boundedText(
      'name',
      p['name'] as String,
      nameLimit,
      required: true,
    );
    if (name case Err(:final error)) return Err(error);
    return store.upsert(
      entityType: 'incomeSource',
      id: current.id,
      payload: p,
      create: false,
      confirmation: c,
      expectedLocalVersion: current.localVersion,
    );
  }

  Map<String, Object?> payloadOf(IncomeSourceRow s) =>
      payloadFromRow('incomeSource', s);
}

/// Learned merchant/keyword rules; activated only by an explicit "Remember" action.
class RuleRepository {
  RuleRepository(this.store);

  final LocalStore store;
  AppDatabase get _db => store.db;

  Stream<List<RuleRow>> watchAll() =>
      (_db.select(_db.categorizationRules)
            ..where((r) => r.userId.equals(store.uid) & r.deletedAt.isNull())
            ..orderBy([
              (r) => OrderingTerm.desc(r.priority),
              (r) => OrderingTerm.asc(r.normalizedPattern),
            ]))
          .watch();

  Future<List<RuleRow>> enabled() =>
      (_db.select(_db.categorizationRules)
            ..where(
              (r) =>
                  r.userId.equals(store.uid) &
                  r.deletedAt.isNull() &
                  r.enabled.equals(true),
            )
            ..orderBy([(r) => OrderingTerm.desc(r.priority)]))
          .get();

  static Map<String, Object?> merchantRule({
    required String merchant,
    required String transactionType,
    required String categoryId,
    String? suggestedAccountId,
    String? suggestedIncomeSourceId,
    required String evidenceTransactionId,
    int priority = 100,
  }) => {
    'matchKind': 'merchantExact',
    'normalizedPattern': normalizeMerchant(merchant),
    'transactionType': transactionType,
    'categoryId': categoryId,
    'suggestedAccountId': suggestedAccountId,
    'suggestedIncomeSourceId': suggestedIncomeSourceId,
    'priority': priority,
    'enabled': true,
    'origin': 'user',
    'evidenceTransactionIds': [evidenceTransactionId],
  };

  Future<Result<String>> save(Map<String, Object?> p, Confirmation c) async {
    final id = store.newId();
    final r = await store.upsert(
      entityType: 'categorizationRule',
      id: id,
      payload: p,
      create: true,
      confirmation: c,
    );
    return switch (r) {
      Ok() => Ok(id),
      Err(:final error) => Err(error),
    };
  }

  Future<Result<void>> update(
    RuleRow current,
    Map<String, Object?> p,
    Confirmation c,
  ) => store.upsert(
    entityType: 'categorizationRule',
    id: current.id,
    payload: p,
    create: false,
    confirmation: c,
    expectedLocalVersion: current.localVersion,
  );

  Future<Result<void>> delete(RuleRow current, Confirmation c) => store.delete(
    entityType: 'categorizationRule',
    id: current.id,
    confirmation: c,
    expectedLocalVersion: current.localVersion,
  );

  Map<String, Object?> payloadOf(RuleRow r) =>
      payloadFromRow('categorizationRule', r);
}
