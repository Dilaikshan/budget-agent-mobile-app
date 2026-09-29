import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import '../domain/canonical_json.dart';
import '../domain/result.dart';
import '../domain/time.dart';
import 'codecs.dart';

/// Proof that the trusted mobile flow showed the exact payload and the user
/// tapped Save (docs/05 "Confirmation"). Only ConfirmationSheet creates one.
class Confirmation {
  const Confirmation._(this.payloadHash, this.confirmedAt);

  factory Confirmation.ofDisplayed(Object? payload, DateTime now) =>
      Confirmation._(canonicalHash(payload), now.toUtc());

  final String payloadHash;
  final DateTime confirmedAt;

  bool matches(Object? payload) => canonicalHash(payload) == payloadHash;
}

class UnsupportedSchemaException implements Exception {
  UnsupportedSchemaException(this.detail);
  final String detail;
}

typedef Clock = DateTime Function();

/// All local writes: overlay row + immutable outbox operation in one SQLite
/// transaction (docs/08). No network call ever happens inside it.
class LocalStore {
  LocalStore(this.db, this.uid, {Clock? clock, Uuid? uuid})
    : clock = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final String uid;
  final Clock clock;
  final Uuid _uuid;

  String newId() => _uuid.v4();

  static const _unackedStates = ['pending', 'syncing', 'conflict', 'blocked'];

  // ---------------------------------------------------------------- reads

  Future<D?> _one<T extends SyncMeta, D>(TableInfo<T, D> t, String id) =>
      (db.select(t)..where((r) => r.userId.equals(uid) & r.id.equals(id)))
          .getSingleOrNull();

  /// Typed row for any replicated entity.
  Future<Object?> row(String entityType, String id) => switch (entityType) {
    'profile' => _one(db.profiles, id),
    'appSettings' => _one(db.settingsRecords, id),
    'account' => _one(db.accounts, id),
    'incomeSource' => _one(db.incomeSources, id),
    'category' => _one(db.categories, id),
    'transaction' => _one(db.transactions, id),
    'categorizationRule' => _one(db.categorizationRules, id),
    'budget' => _one(db.budgets, id),
    'aiInsight' => _one(db.aiInsights, id),
    'aiProposal' => _one(db.aiProposals, id),
    'reviewState' => _one(db.reviewStates, id),
    'aiActivity' => _one(db.aiActivities, id),
    'agentRun' => _one(db.agentRuns, id),
    _ => throw UnsupportedSchemaException(entityType),
  };

  Future<
    ({int revision, int localVersion, int? deletedAt, int localCreatedAt})?
  >
  _meta(String entityType, String id) async {
    final t = tableFor(db, entityType);
    final r = await db
        .customSelect(
          'SELECT revision, local_version, deleted_at, local_created_at FROM ${t.actualTableName} WHERE user_id = ? AND id = ?',
          variables: [Variable(uid), Variable(id)],
          readsFrom: {t},
        )
        .getSingleOrNull();
    if (r == null) return null;
    return (
      revision: r.read<int>('revision'),
      localVersion: r.read<int>('local_version'),
      deletedAt: r.readNullable<int>('deleted_at'),
      localCreatedAt: r.read<int>('local_created_at'),
    );
  }

  Future<OutboxRow?> _latestUnacked(
    String entityType,
    String id, {
    String? excludingOpId,
  }) {
    final q = db.select(db.outboxOps)
      ..where(
        (o) =>
            o.userId.equals(uid) &
            o.entityType.equals(entityType) &
            o.entityId.equals(id) &
            o.state.isIn(_unackedStates) &
            (excludingOpId == null
                ? const Constant(true)
                : o.opId.equals(excludingOpId).not()),
      )
      ..orderBy([(o) => OrderingTerm.desc(o.ordinal)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  // ---------------------------------------------------------------- local commits

  /// Create or full-replacement update of a client-writable entity.
  Future<Result<void>> upsert({
    required String entityType,
    required String id,
    required Map<String, Object?> payload,
    required bool create,
    required Confirmation confirmation,
    int? expectedLocalVersion,
  }) async {
    if (!confirmation.matches(payload)) return _confirmationMismatch();
    try {
      return await db.transaction(() async {
        final meta = await _meta(entityType, id);
        if (create && meta != null) return _conflict('Already exists.');
        if (!create) {
          if (meta == null || meta.deletedAt != null) {
            return _conflict('This record no longer exists.');
          }
          if (expectedLocalVersion != null &&
              meta.localVersion != expectedLocalVersion) {
            return _conflict('This record changed; reopen it and try again.');
          }
        }
        final now = clock().millisecondsSinceEpoch;
        final localVersion = (meta?.localVersion ?? 0) + 1;
        await _enqueue(
          entityType: entityType,
          entityId: id,
          action: create ? 'create' : 'update',
          payload: payload,
          currentRevision: meta?.revision ?? 0,
          localVersion: localVersion,
          confirmation: confirmation,
        );
        await db
            .into(tableFor(db, entityType))
            .insertOnConflictUpdate(
              companionFor(
                entityType,
                uid,
                id,
                payload,
                RowMeta(
                  revision: meta?.revision ?? 0,
                  createdAt: null,
                  serverUpdatedAt: null,
                  deletedAt: null,
                  localVersion: localVersion,
                  syncStatus: 'pending',
                  localCreatedAt: meta?.localCreatedAt ?? now,
                  localUpdatedAt: now,
                ),
              ),
            );
        return const Ok(null);
      });
    } on SqliteException catch (e) {
      return Err(_sqliteError(e));
    }
  }

  /// Tombstone delete (transactions, rules, budgets).
  Future<Result<void>> delete({
    required String entityType,
    required String id,
    required Confirmation confirmation,
    int? expectedLocalVersion,
  }) async {
    if (!confirmation.matches({'delete': entityType, 'id': id})) {
      return _confirmationMismatch();
    }
    return db.transaction(() async {
      final meta = await _meta(entityType, id);
      if (meta == null || meta.deletedAt != null) {
        return _conflict('This record no longer exists.');
      }
      if (expectedLocalVersion != null &&
          meta.localVersion != expectedLocalVersion) {
        return _conflict('This record changed; reopen it.');
      }
      final now = clock().millisecondsSinceEpoch;
      final localVersion = meta.localVersion + 1;
      await _enqueue(
        entityType: entityType,
        entityId: id,
        action: 'delete',
        payload: null,
        currentRevision: meta.revision,
        localVersion: localVersion,
        confirmation: confirmation,
      );
      final t = tableFor(db, entityType);
      await db.customUpdate(
        'UPDATE ${t.actualTableName} SET deleted_at = ?, local_version = ?, sync_status = ?, local_updated_at = ? WHERE user_id = ? AND id = ?',
        variables: [
          Variable(now),
          Variable(localVersion),
          const Variable('pending'),
          Variable(now),
          Variable(uid),
          Variable(id),
        ],
        updates: {t},
      );
      return const Ok(null);
    });
  }

  /// Account + signed opening balance as one compound operation (docs/05).
  Future<Result<void>> createAccountWithOpening({
    required String accountId,
    required Map<String, Object?> account,
    required int signedOpeningMinor,
    required String effectiveDate,
    required String timeZone,
    required Confirmation confirmation,
  }) async {
    final occurredAt = toInstant(noonInZone(effectiveDate, timeZone));
    final payload = {
      'account': account,
      'opening': {
        'signedOpeningMinor': signedOpeningMinor,
        'occurredAt': occurredAt,
        'effectiveDate': effectiveDate,
        'entryTimeZone': timeZone,
      },
    };
    if (!confirmation.matches(payload)) return _confirmationMismatch();
    try {
      return await db.transaction(() async {
        if (await _meta('account', accountId) != null) {
          return _conflict('Account already exists.');
        }
        final now = clock().millisecondsSinceEpoch;
        await _enqueue(
          entityType: 'account',
          entityId: accountId,
          action: 'createAccountWithOpening',
          payload: payload,
          currentRevision: 0,
          localVersion: 1,
          confirmation: confirmation,
        );
        RowMeta meta() => RowMeta(
          revision: 0,
          createdAt: null,
          serverUpdatedAt: null,
          deletedAt: null,
          localVersion: 1,
          syncStatus: 'pending',
          localCreatedAt: now,
          localUpdatedAt: now,
        );
        await db
            .into(tableFor(db, 'account'))
            .insert(companionFor('account', uid, accountId, account, meta()));
        await db
            .into(tableFor(db, 'transaction'))
            .insert(
              companionFor(
                'transaction',
                uid,
                openingTransactionId(accountId),
                {
                  'type': 'opening',
                  'amountMinor': signedOpeningMinor.abs(),
                  'currency': account['currency'],
                  'accountId': accountId,
                  'destinationAccountId': null,
                  'incomeSourceId': null,
                  'categoryId': null,
                  'merchant': null,
                  'description': 'Opening balance',
                  'occurredAt': occurredAt,
                  'effectiveDate': effectiveDate,
                  'entryTimeZone': timeZone,
                  'origin': 'opening',
                  'categorizationSource': null,
                  'proposalId': null,
                  'openingDirection': signedOpeningMinor < 0
                      ? 'debit'
                      : 'credit',
                },
                meta(),
              ),
            );
        return const Ok(null);
      });
    } on SqliteException catch (e) {
      return Err(_sqliteError(e));
    }
  }

  /// Narrow server-owned actions with no ledger effect.
  Future<Result<void>> dismissInsight(String id) =>
      _narrow('aiInsight', id, 'dismissInsight', {'status': 'dismissed'});
  Future<Result<void>> rejectProposal(String id) =>
      _narrow('aiProposal', id, 'rejectProposal', {'status': 'rejected'});

  Future<Result<void>> _narrow(
    String entityType,
    String id,
    String action,
    Map<String, Object?> payload,
  ) => db.transaction(() async {
    final meta = await _meta(entityType, id);
    if (meta == null || meta.deletedAt != null) return _conflict('Not found.');
    final localVersion = meta.localVersion + 1;
    await _enqueue(
      entityType: entityType,
      entityId: id,
      action: action,
      payload: payload,
      currentRevision: meta.revision,
      localVersion: localVersion,
      confirmation: null,
    );
    final t = tableFor(db, entityType);
    final now = clock().millisecondsSinceEpoch;
    await db.customUpdate(
      'UPDATE ${t.actualTableName} SET status = ?, local_version = ?, sync_status = ?, local_updated_at = ? WHERE user_id = ? AND id = ?',
      variables: [
        Variable(payload['status'] as String),
        Variable(localVersion),
        const Variable('pending'),
        Variable(now),
        Variable(uid),
        Variable(id),
      ],
      updates: {t},
    );
    return const Ok(null);
  });

  Future<void> _enqueue({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, Object?>? payload,
    required int currentRevision,
    required int localVersion,
    required Confirmation? confirmation,
  }) async {
    final isNew = action == 'create' || action == 'createAccountWithOpening';
    final predecessor = isNew
        ? null
        : await _latestUnacked(entityType, entityId);
    final int? baseRevision = isNew
        ? 0
        : (predecessor == null ? currentRevision : null);
    final dependsOnOpId = predecessor?.opId;
    final hashInput = {
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'baseRevision': baseRevision,
      'dependsOnOpId': dependsOnOpId,
      'payload': payload,
    };
    final confirmationJson = confirmation == null
        ? null
        : {
            'confirmedAt': toInstant(confirmation.confirmedAt),
            'payloadHash': canonicalHash(hashInput),
            'expectedLocalVersion': localVersion,
            'predecessorOpId': dependsOnOpId,
          };
    final opId = _uuid.v4();
    final op = {'opId': opId, ...hashInput, 'confirmation': confirmationJson};
    final blockedByPredecessor =
        predecessor != null &&
        (predecessor.state == 'conflict' || predecessor.state == 'blocked');
    await db
        .into(db.outboxOps)
        .insert(
          OutboxOpsCompanion.insert(
            opId: opId,
            userId: uid,
            entityType: entityType,
            entityId: entityId,
            action: action,
            baseRevision: Value(baseRevision),
            dependsOnOpId: Value(dependsOnOpId),
            payloadJson: Value(payload == null ? null : jsonEncode(payload)),
            confirmationJson: Value(
              confirmationJson == null ? null : jsonEncode(confirmationJson),
            ),
            requestHash: canonicalHash(op),
            localVersion: localVersion,
            state: blockedByPredecessor ? 'blocked' : 'pending',
            errorCode: Value(
              blockedByPredecessor ? 'DEPENDENCY_UNRESOLVED' : null,
            ),
            createdAt: clock().millisecondsSinceEpoch,
          ),
        );
  }

  // ---------------------------------------------------------------- sync application

  /// Wire form of an outbox row (the immutable Operation).
  static Map<String, Object?> operationJson(OutboxRow o) => {
    'opId': o.opId,
    'entityType': o.entityType,
    'entityId': o.entityId,
    'action': o.action,
    'baseRevision': o.baseRevision,
    'dependsOnOpId': o.dependsOnOpId,
    'payload': o.payloadJson == null ? null : jsonDecode(o.payloadJson!),
    'confirmation': o.confirmationJson == null
        ? null
        : jsonDecode(o.confirmationJson!),
  };

  Future<ShadowRow?> shadow(String entityType, String id) =>
      (db.select(db.remoteShadows)..where(
            (s) =>
                s.userId.equals(uid) &
                s.entityType.equals(entityType) &
                s.entityId.equals(id),
          ))
          .getSingleOrNull();

  /// Applies one accepted canonical record: shadow first, then the visible row
  /// only when no local operation for the entity is outstanding.
  Future<void> applyRecord(
    String entityType,
    Map<String, Object?> record, {
    String? acknowledgingOpId,
  }) async {
    if (!replicatedTypes.contains(entityType)) {
      throw UnsupportedSchemaException(entityType);
    }
    if (record['schemaVersion'] != 1) {
      throw UnsupportedSchemaException(
        '$entityType schemaVersion ${record['schemaVersion']}',
      );
    }
    final id = record['id'] as String;
    final revision = record['revision'] as int;
    final existing = await shadow(entityType, id);
    if (existing != null && existing.revision >= revision) return;
    await db
        .into(db.remoteShadows)
        .insertOnConflictUpdate(
          RemoteShadowsCompanion.insert(
            userId: uid,
            entityType: entityType,
            entityId: id,
            revision: revision,
            canonicalJson: jsonEncode(record),
            deletedAt: Value(
              record['deletedAt'] == null
                  ? null
                  : parseInstant(record['deletedAt'] as String)
                        .millisecondsSinceEpoch,
            ),
          ),
        );
    final outstanding = await _latestUnacked(
      entityType,
      id,
      excludingOpId: acknowledgingOpId,
    );
    final meta = await _meta(entityType, id);
    final now = clock().millisecondsSinceEpoch;
    if (outstanding == null) {
      await db
          .into(tableFor(db, entityType))
          .insertOnConflictUpdate(
            companionFor(
              entityType,
              uid,
              id,
              record,
              metaFromRecord(
                record,
                localVersion: meta?.localVersion ?? 0,
                now: now,
                localCreatedAt: meta?.localCreatedAt,
              ),
            ),
          );
    } else if (meta != null) {
      // Keep the pending overlay; record the newest accepted revision.
      final t = tableFor(db, entityType);
      await db.customUpdate(
        'UPDATE ${t.actualTableName} SET revision = ? WHERE user_id = ? AND id = ? AND revision < ?',
        variables: [
          Variable(revision),
          Variable(uid),
          Variable(id),
          Variable(revision),
        ],
        updates: {t},
      );
    }
  }

  Future<CursorRow> cursor() async {
    final c = await (db.select(
      db.syncCursors,
    )..where((c) => c.userId.equals(uid))).getSingleOrNull();
    if (c != null) return c;
    await db
        .into(db.syncCursors)
        .insert(SyncCursorsCompanion.insert(userId: uid));
    return (await (db.select(
      db.syncCursors,
    )..where((c) => c.userId.equals(uid))).getSingle());
  }

  /// Applies a pulled page and advances the cursor atomically. An unknown
  /// schema aborts the whole page without advancing (docs/08 step 3).
  Future<void> applyPage(
    List<Map<String, Object?>> changes, {
    required int nextAfterSeq,
    required int watermark,
    required bool hasMore,
  }) => db.transaction(() async {
    final c = await cursor();
    var lastLedgerSeq = c.lastLedgerSeq;
    for (final change in changes) {
      for (final m
          in (change['mutations'] as List).cast<Map<String, Object?>>()) {
        await applyRecord(
          m['entityType'] as String,
          (m['record'] as Map).cast<String, Object?>(),
        );
      }
      if (change['ledgerChanged'] == true) lastLedgerSeq = change['seq'] as int;
    }
    await (db.update(db.syncCursors)..where((x) => x.userId.equals(uid))).write(
      SyncCursorsCompanion(
        lastAppliedSeq: Value(nextAfterSeq),
        lastLedgerSeq: Value(lastLedgerSeq),
        pageWatermark: Value(hasMore ? watermark : null),
        lastSyncedAt: Value(
          hasMore ? c.lastSyncedAt : clock().millisecondsSinceEpoch,
        ),
        pausedReason: const Value(null),
      ),
    );
  });

  Future<void> pauseSync(String reason) => cursor().then(
    (_) => (db.update(db.syncCursors)..where((x) => x.userId.equals(uid)))
        .write(SyncCursorsCompanion(pausedReason: Value(reason))),
  );

  /// On startup, operations interrupted mid-delivery return to pending with the same opId.
  Future<void> resetInterrupted() =>
      (db.update(db.outboxOps)
            ..where((o) => o.userId.equals(uid) & o.state.equals('syncing')))
          .write(const OutboxOpsCompanion(state: Value('pending')));

  /// Ready operations in queue order; an operation whose predecessor failed is blocked.
  Future<List<OutboxRow>> readyOperations(int limit) async {
    final now = clock().millisecondsSinceEpoch;
    final rows =
        await (db.select(db.outboxOps)
              ..where(
                (o) =>
                    o.userId.equals(uid) &
                    o.state.equals('pending') &
                    (o.nextAttemptAt.isNull() |
                        o.nextAttemptAt.isSmallerOrEqualValue(now)),
              )
              ..orderBy([(o) => OrderingTerm.asc(o.ordinal)])
              ..limit(limit))
            .get();
    return rows;
  }

  Future<void> markState(
    Iterable<String> opIds,
    String state, {
    String? errorCode,
    int? nextAttemptAt,
    bool countAttempt = false,
  }) async {
    for (final id in opIds) {
      final o = await (db.select(
        db.outboxOps,
      )..where((x) => x.opId.equals(id))).getSingle();
      await (db.update(db.outboxOps)..where((x) => x.opId.equals(id))).write(
        OutboxOpsCompanion(
          state: Value(state),
          errorCode: Value(errorCode),
          nextAttemptAt: Value(nextAttemptAt),
          attempts: Value(countAttempt ? o.attempts + 1 : o.attempts),
        ),
      );
    }
  }

  Future<void> acknowledgeAccepted(
    OutboxRow op,
    List<Map<String, Object?>> changes,
  ) => db.transaction(() async {
    await markState([op.opId], 'acknowledged');
    for (final m in changes) {
      await applyRecord(
        m['entityType'] as String,
        (m['record'] as Map).cast<String, Object?>(),
        acknowledgingOpId: op.opId,
      );
    }
    await _refreshStatus(op.entityType, op.entityId);
  });

  Future<void> recordConflict(OutboxRow op, Map<String, Object?>? current) =>
      db.transaction(() async {
        final base = await shadow(op.entityType, op.entityId);
        if (current != null) {
          await applyRecord(op.entityType, current, acknowledgingOpId: op.opId);
        }
        await markState([op.opId], 'conflict', errorCode: 'REVISION_CONFLICT');
        await _blockDependents(op, 'DEPENDENCY_CONFLICT');
        await db
            .into(db.syncConflicts)
            .insertOnConflictUpdate(
              SyncConflictsCompanion.insert(
                opId: op.opId,
                userId: uid,
                entityType: op.entityType,
                entityId: op.entityId,
                baseJson: Value(base?.canonicalJson),
                proposedJson: Value(op.payloadJson),
                serverJson: Value(current == null ? null : jsonEncode(current)),
                serverRevision: Value(current?['revision'] as int?),
                detectedAt: clock().millisecondsSinceEpoch,
              ),
            );
        await _setStatus(op.entityType, op.entityId, 'conflict');
      });

  Future<void> recordRejected(OutboxRow op, String code) =>
      db.transaction(() async {
        await markState([op.opId], 'blocked', errorCode: code);
        await _blockDependents(op, 'DEPENDENCY_FAILED');
        await _setStatus(op.entityType, op.entityId, 'blocked');
      });

  Future<void> _blockDependents(OutboxRow op, String code) async {
    final later =
        await (db.select(db.outboxOps)..where(
              (o) =>
                  o.userId.equals(uid) &
                  o.entityType.equals(op.entityType) &
                  o.entityId.equals(op.entityId) &
                  o.ordinal.isBiggerThanValue(op.ordinal) &
                  o.state.equals('pending'),
            ))
            .get();
    await markState(later.map((o) => o.opId), 'blocked', errorCode: code);
  }

  Future<void> _refreshStatus(String entityType, String id) async {
    final outstanding = await _latestUnacked(entityType, id);
    await _setStatus(
      entityType,
      id,
      outstanding == null
          ? 'synced'
          : (outstanding.state == 'syncing' ? 'pending' : outstanding.state),
    );
  }

  Future<void> _setStatus(String entityType, String id, String status) async {
    final t = tableFor(db, entityType);
    await db.customUpdate(
      'UPDATE ${t.actualTableName} SET sync_status = ? WHERE user_id = ? AND id = ?',
      variables: [Variable(status), Variable(uid), Variable(id)],
      updates: {t},
    );
  }

  // ---------------------------------------------------------------- conflict resolution

  Stream<List<ConflictRow>> watchOpenConflicts() => (db.select(
    db.syncConflicts,
  )..where((c) => c.userId.equals(uid) & c.resolvedAt.isNull())).watch();

  /// Blocked (rejected) operations awaiting a user decision.
  Stream<List<OutboxRow>> watchBlocked() => (db.select(
    db.outboxOps,
  )..where((o) => o.userId.equals(uid) & o.state.equals('blocked'))).watch();

  Stream<int> watchPendingCount() {
    final count = db.outboxOps.opId.count();
    final q = db.selectOnly(db.outboxOps)
      ..addColumns([count])
      ..where(
        db.outboxOps.userId.equals(uid) &
            db.outboxOps.state.isIn(const ['pending', 'syncing']),
      );
    return q.map((r) => r.read(count) ?? 0).watchSingle();
  }

  Stream<CursorRow?> watchCursor() => (db.select(
    db.syncCursors,
  )..where((c) => c.userId.equals(uid))).watchSingleOrNull();

  /// "Keep remote": drop the local overlay and every later operation for the entity.
  Future<void> keepRemote(String opId) => db.transaction(() async {
    final op = await (db.select(
      db.outboxOps,
    )..where((o) => o.opId.equals(opId))).getSingle();
    await _supersedeFrom(op);
    await _restoreShadow(op.entityType, op.entityId);
    await (db.update(
      db.syncConflicts,
    )..where((c) => c.opId.equals(opId))).write(
      SyncConflictsCompanion(resolvedAt: Value(clock().millisecondsSinceEpoch)),
    );
  });

  /// Discard a blocked (rejected) local change and return to the accepted version.
  Future<void> discardBlocked(String opId) => keepRemote(opId);

  /// "Apply my changes": after keepRemote-style cleanup, the caller re-confirms
  /// the payload, which becomes a new operation against the current revision.
  Future<Result<void>> applyMine(
    String opId,
    Map<String, Object?> payload,
    Confirmation confirmation,
  ) async {
    final op = await (db.select(
      db.outboxOps,
    )..where((o) => o.opId.equals(opId))).getSingle();
    await keepRemote(opId);
    final shadowRow = await shadow(op.entityType, op.entityId);
    if (shadowRow == null || shadowRow.deletedAt != null) {
      return const Err(
        AppError(
          ErrorKind.conflict,
          'The record was deleted on another device; create a new entry instead.',
        ),
      );
    }
    return upsert(
      entityType: op.entityType,
      id: op.entityId,
      payload: payload,
      create: false,
      confirmation: confirmation,
    );
  }

  Future<void> _supersedeFrom(OutboxRow op) async {
    final chain =
        await (db.select(db.outboxOps)..where(
              (o) =>
                  o.userId.equals(uid) &
                  o.entityType.equals(op.entityType) &
                  o.entityId.equals(op.entityId) &
                  o.ordinal.isBiggerOrEqualValue(op.ordinal) &
                  o.state.isIn(_unackedStates),
            ))
            .get();
    await markState(chain.map((o) => o.opId), 'superseded');
  }

  Future<void> _restoreShadow(String entityType, String id) async {
    final s = await shadow(entityType, id);
    final t = tableFor(db, entityType);
    if (s == null) {
      // Never accepted remotely: remove the local-only row (and a compound opening).
      if (entityType == 'account') {
        await db.customUpdate(
          'DELETE FROM transactions WHERE user_id = ? AND id = ?',
          variables: [Variable(uid), Variable(openingTransactionId(id))],
          updates: {db.transactions},
        );
      }
      await db.customUpdate(
        'DELETE FROM ${t.actualTableName} WHERE user_id = ? AND id = ?',
        variables: [Variable(uid), Variable(id)],
        updates: {t},
      );
      return;
    }
    final record = (jsonDecode(s.canonicalJson) as Map).cast<String, Object?>();
    final meta = await _meta(entityType, id);
    await db
        .into(t)
        .insertOnConflictUpdate(
          companionFor(
            entityType,
            uid,
            id,
            record,
            metaFromRecord(
              record,
              localVersion: (meta?.localVersion ?? 0) + 1,
              now: clock().millisecondsSinceEpoch,
              localCreatedAt: meta?.localCreatedAt,
            ),
          ),
        );
  }

  // ---------------------------------------------------------------- drafts

  Future<void> saveDraft(
    String id,
    String rawInput, {
    Map<String, Object?>? candidate,
  }) async {
    final now = clock().millisecondsSinceEpoch;
    await db
        .into(db.drafts)
        .insertOnConflictUpdate(
          DraftsCompanion.insert(
            id: id,
            userId: uid,
            rawInput: rawInput,
            candidateJson: Value(
              candidate == null ? null : jsonEncode(candidate),
            ),
            createdAt: now,
            updatedAt: now,
            expiresAt: now + const Duration(hours: 24).inMilliseconds,
          ),
        );
  }

  Future<void> deleteDraft(String id) =>
      (db.delete(db.drafts)..where((d) => d.id.equals(id))).go();

  /// Raw input is removed 24 hours after save (docs/04).
  Future<void> purgeExpiredDrafts() =>
      (db.delete(db.drafts)..where(
            (d) =>
                d.expiresAt.isSmallerThanValue(clock().millisecondsSinceEpoch),
          ))
          .go();

  // ---------------------------------------------------------------- errors

  Result<void> _confirmationMismatch() => const Err(
    AppError(
      ErrorKind.validation,
      'The confirmed details do not match; review and confirm again.',
    ),
  );

  Result<void> _conflict(String message) =>
      Err(AppError(ErrorKind.conflict, message));

  AppError _sqliteError(SqliteException e) {
    final msg = e.toString();
    if (msg.contains('FOREIGN KEY')) {
      return const AppError(
        ErrorKind.missingReference,
        'A referenced record is missing.',
      );
    }
    if (msg.contains('full') || msg.contains('SQLITE_FULL')) {
      return const AppError(
        ErrorKind.storageFull,
        'Device storage is full; nothing was saved.',
      );
    }
    if (msg.contains('UNIQUE')) {
      return const AppError(
        ErrorKind.validation,
        'A record like this already exists.',
      );
    }
    return const AppError(
      ErrorKind.validation,
      'The record could not be saved.',
    );
  }
}
