import 'dart:convert';
import 'dart:io';

import 'package:budget_agent/core/data/local_store.dart';
import 'package:budget_agent/core/database/app_database.dart';
import 'package:budget_agent/core/domain/canonical_json.dart';
import 'package:budget_agent/core/domain/ledger.dart';
import 'package:budget_agent/core/domain/money.dart';
import 'package:budget_agent/core/domain/result.dart';
import 'package:budget_agent/core/domain/time.dart';
import 'package:budget_agent/core/domain/transaction.dart';
import 'package:budget_agent/core/network/api_client.dart';
import 'package:budget_agent/core/sync/sync_engine.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

const uid = 'ownerUid123';
final t0 = DateTime.utc(2026, 9, 9, 8);

AppDatabase memoryDb() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Confirmation confirm(Object? payload) => Confirmation.ofDisplayed(payload, t0);

Map<String, Object?> account(String name, String type) => {
  'name': name,
  'type': type,
  'currency': 'LKR',
  'archived': false,
  'sortOrder': 0,
};

Future<void> seedProfile(LocalStore s) async {
  final profile = {
    'displayName': 'Me',
    'baseCurrency': 'LKR',
    'currencyExponent': 2,
    'timeZone': 'Asia/Colombo',
    'onboardingComplete': true,
  };
  expect(
    (await s.upsert(
      entityType: 'profile',
      id: 'profile',
      payload: profile,
      create: true,
      confirmation: confirm(profile),
    )).isOk,
    isTrue,
  );
}

Future<String> createAccount(
  LocalStore s,
  String name,
  String type,
  int opening,
) async {
  final id = s.newId();
  final a = account(name, type);
  final payload = {
    'account': a,
    'opening': {
      'signedOpeningMinor': opening,
      'occurredAt': toInstant(noonInZone('2026-09-01', 'Asia/Colombo')),
      'effectiveDate': '2026-09-01',
      'entryTimeZone': 'Asia/Colombo',
    },
  };
  final r = await s.createAccountWithOpening(
    accountId: id,
    account: a,
    signedOpeningMinor: opening,
    effectiveDate: '2026-09-01',
    timeZone: 'Asia/Colombo',
    confirmation: confirm(payload),
  );
  expect(r.isOk, isTrue, reason: '$r');
  return id;
}

Map<String, Object?> expense(String accountId, int amount) =>
    TransactionPayload(
      type: TxType.expense,
      amountMinor: amount,
      currency: 'LKR',
      accountId: accountId,
      destinationAccountId: null,
      incomeSourceId: null,
      categoryId: null,
      merchant: null,
      description: 'Lunch',
      occurredAt: DateTime.utc(2026, 9, 9, 6, 30),
      effectiveDate: '2026-09-09',
      entryTimeZone: 'Asia/Colombo',
      origin: TxOrigin.manual,
      categorizationSource: null,
      proposalId: null,
      openingDirection: null,
    ).toJson();

Future<Map<String, int>> balances(AppDatabase db) async {
  final rows = await db.select(db.transactions).get();
  final entries = rows.map(
    (r) => LedgerEntry(
      id: r.id,
      type: r.type,
      amountMinor: r.amountMinor,
      accountId: r.accountId,
      destinationAccountId: r.destinationAccountId,
      openingDirection: r.openingDirection,
      effectiveDate: r.effectiveDate,
      deleted: r.deletedAt != null,
    ),
  );
  final accounts = await db.select(db.accounts).get();
  return {
    for (final a in accounts) a.name: balanceOf(entries, a.id).valueOrNull!,
  };
}

void main() {
  group('canonical JSON golden vectors shared with the backend', () {
    final vectors = jsonDecode(
      File('../docs/contracts/hash-vectors.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final v in (vectors['vectors'] as List).cast<Map<String, dynamic>>()) {
      test(v['name'] as String, () {
        expect(canonicalJson(v['input']), v['canonical']);
        expect(canonicalHash(v['input']), v['sha256']);
      });
    }
    for (final r
        in (vectors['rejections'] as List).cast<Map<String, dynamic>>()) {
      test(
        'rejects ${r['name']}',
        () => expect(
          () => canonicalJson(r['input']),
          throwsA(isA<CanonicalJsonException>()),
        ),
      );
    }
    test('opening IDs', () {
      for (final o
          in (vectors['openingIds'] as List).cast<Map<String, dynamic>>()) {
        expect(openingTransactionId(o['accountId'] as String), o['openingId']);
      }
    });
  });

  group('money', () {
    test('parses exactly and rejects ambiguity', () {
      expect(parseAmountToMinor('2,500.50', 2).valueOrNull, 250050);
      expect(parseAmountToMinor('0.05', 2).valueOrNull, 5);
      for (final bad in [
        '2.500',
        '1,50',
        '1.234',
        '-5',
        '1e5',
        '',
        '0',
        '10000000000.01',
      ]) {
        expect(parseAmountToMinor(bad, 2).isOk, isFalse, reason: bad);
      }
      expect(parseSignedOpeningMinor('-250.00', 2).valueOrNull, -25000);
      expect(parseSignedOpeningMinor('0', 2).valueOrNull, 0);
    });
    test('formats without floating point', () {
      expect(formatMinor(150050, currency: 'LKR', exponent: 2), 'LKR 1,500.50');
      expect(formatMinor(-5, currency: 'LKR', exponent: 2), '-LKR 0.05');
      expect(minorToInput(250000, 2), '2500.00');
    });
    test('balance overflow is detected', () {
      expect(checkedSum([maxSafeInteger, 1]).isOk, isFalse);
    });
  });

  group('transaction validation (shared by both entry flows)', () {
    final refs = _Refs();
    Result<TransactionPayload> build(TransactionDraft d) => buildPayload(
      draft: d,
      currency: 'LKR',
      exponent: 2,
      timeZone: 'Asia/Colombo',
      refs: refs,
      now: t0,
    );

    test('income requires category and income source', () {
      final r = build(
        const TransactionDraft(
          type: TxType.income,
          amountText: '100',
          accountId: 'bank',
        ),
      );
      expect(r, isA<Err<TransactionPayload>>());
      final fields = (r as Err).error.fields;
      expect(fields.keys, containsAll(['categoryId', 'incomeSourceId']));
    });
    test(
      'transfer requires two distinct accounts and drops category/source',
      () {
        expect(
          build(
            const TransactionDraft(
              type: TxType.transfer,
              amountText: '100',
              accountId: 'bank',
              destinationAccountId: 'bank',
            ),
          ).isOk,
          isFalse,
        );
        final ok = build(
          const TransactionDraft(
            type: TxType.transfer,
            amountText: '100',
            accountId: 'bank',
            destinationAccountId: 'cash',
            categoryId: 'food',
          ),
        );
        expect(ok.valueOrNull!.categoryId, isNull);
      },
    );
    test('archived references are rejected for new selections only', () {
      expect(
        build(
          const TransactionDraft(
            type: TxType.expense,
            amountText: '1',
            accountId: 'old',
          ),
        ).isOk,
        isFalse,
      );
      final previous = build(
        const TransactionDraft(
          type: TxType.expense,
          amountText: '1',
          accountId: 'cash',
        ),
      ).valueOrNull!;
      final retained = buildPayload(
        draft: const TransactionDraft(
          type: TxType.expense,
          amountText: '2',
          accountId: 'old',
        ),
        currency: 'LKR',
        exponent: 2,
        timeZone: 'Asia/Colombo',
        refs: refs,
        now: t0,
        previous: TransactionPayload.fromJson({
          ...previous.toJson(),
          'accountId': 'old',
        }),
      );
      expect(retained.isOk, isTrue);
    });
    test(
      'expense category type must match; uncategorized expense is valid',
      () {
        expect(
          build(
            const TransactionDraft(
              type: TxType.expense,
              amountText: '1',
              accountId: 'cash',
              categoryId: 'salary',
            ),
          ).isOk,
          isFalse,
        );
        final r = build(
          const TransactionDraft(
            type: TxType.expense,
            amountText: '25.00',
            accountId: 'cash',
          ),
        );
        expect(r.valueOrNull!.amountMinor, 2500);
        expect(r.valueOrNull!.effectiveDate, '2026-09-09');
      },
    );
    test('date-only selections resolve to local noon', () {
      final r = build(
        const TransactionDraft(
          type: TxType.expense,
          amountText: '1',
          accountId: 'cash',
          effectiveDate: '2026-09-01',
        ),
      );
      expect(toInstant(r.valueOrNull!.occurredAt), '2026-09-01T06:30:00.000Z');
    });
  });

  group('local store', () {
    late AppDatabase db;
    late LocalStore store;
    setUp(() {
      db = memoryDb();
      store = LocalStore(db, uid, clock: () => t0);
    });
    tearDown(() => db.close());

    test('account + opening + outbox are written atomically', () async {
      await seedProfile(store);
      final id = await createAccount(store, 'Cash Wallet', 'cash', 500000);
      final opening = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(openingTransactionId(id)))).getSingle();
      expect(opening.type, 'opening');
      expect(opening.openingDirection, 'credit');
      final ops = await db.select(db.outboxOps).get();
      expect(ops.map((o) => o.action), ['create', 'createAccountWithOpening']);
      expect(await balances(db), {'Cash Wallet': 500000});
    });

    test('a confirmation for a different payload is refused and nothing is written', () async {
      await seedProfile(store);
      final cash = await createAccount(store, 'Cash', 'cash', 0);
      final r = await store.upsert(
        entityType: 'transaction',
        id: store.newId(),
        payload: expense(cash, 100),
        create: true,
        confirmation: confirm(expense(cash, 999)),
      );
      expect(r.isOk, isFalse);
      expect((await db.select(db.transactions).get()).length, 1);
    });

    test('second edit while the first is pending depends on it; stale local version conflicts', () async {
      await seedProfile(store);
      final cash = await createAccount(store, 'Cash', 'cash', 0);
      final id = store.newId();
      await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: expense(cash, 100),
        create: true,
        confirmation: confirm(expense(cash, 100)),
      );
      final e2 = expense(cash, 200);
      expect(
        (await store.upsert(
          entityType: 'transaction',
          id: id,
          payload: e2,
          create: false,
          confirmation: confirm(e2),
          expectedLocalVersion: 1,
        )).isOk,
        isTrue,
      );
      final ops = await (db.select(
        db.outboxOps,
      )..where((o) => o.entityId.equals(id))).get();
      expect(ops[1].baseRevision, isNull);
      expect(ops[1].dependsOnOpId, ops[0].opId);
      final confirmation = jsonDecode(ops[1].confirmationJson!) as Map;
      expect(confirmation['predecessorOpId'], ops[0].opId);
      final stale = await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: e2,
        create: false,
        confirmation: confirm(e2),
        expectedLocalVersion: 1,
      );
      expect((stale as Err).error.kind, ErrorKind.conflict);
    });

    test('foreign keys reject references to unknown accounts', () async {
      await seedProfile(store);
      final r = await store.upsert(
        entityType: 'transaction',
        id: store.newId(),
        payload: expense('missing', 1),
        create: true,
        confirmation: confirm(expense('missing', 1)),
      );
      expect((r as Err).error.kind, ErrorKind.missingReference);
    });
  });

  group('sync engine against a fake server', () {
    late AppDatabase db;
    late LocalStore store;
    late FakeServer server;
    late SyncEngine engine;
    setUp(() {
      db = memoryDb();
      store = LocalStore(db, uid, clock: () => t0);
      server = FakeServer();
      engine = SyncEngine(store, server);
    });
    tearDown(() => db.close());

    test('push acknowledges, materializes canonical records and clears pending status', () async {
      await seedProfile(store);
      final cash = await createAccount(store, 'Cash', 'cash', 500000);
      await store.upsert(
        entityType: 'transaction',
        id: store.newId(),
        payload: expense(cash, 2500),
        create: true,
        confirmation: confirm(expense(cash, 2500)),
      );
      final s = await engine.syncOnce();
      expect(s.accepted, 3);
      expect(
        (await db.select(db.transactions).get()).every(
          (t) => t.syncStatus == 'synced' && t.revision == 1,
        ),
        isTrue,
      );
      expect(
        (await db.select(db.outboxOps).get()).every(
          (o) => o.state == 'acknowledged',
        ),
        isTrue,
      );
      expect(await balances(db), {'Cash': 497500});
      expect((await store.cursor()).lastAppliedSeq, server.seq);
    });

    test(
      'lost acknowledgement: retry with the same opId has no extra effect',
      () async {
        await seedProfile(store);
        final cash = await createAccount(store, 'Cash', 'cash', 100);
        server.dropNextResponse = true;
        final first = await engine.syncOnce();
        expect(first.deferred, greaterThan(0));
        // Deferred ops wait for backoff; make them due and retry.
        await (db.update(db.outboxOps))
            .write(const OutboxOpsCompanion(nextAttemptAt: Value(null)));
        await engine.syncOnce();
        expect(server.receiptCount, 2);
        expect(server.recordsOf('transaction').length, 1);
        expect(await balances(db), {'Cash': 100});
        expect(cash, isNotEmpty);
      },
    );

    test('remote edit wins acceptance; local edit is preserved as a conflict; keep remote converges', () async {
      await seedProfile(store);
      final cash = await createAccount(store, 'Cash', 'cash', 0);
      final id = store.newId();
      await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: expense(cash, 100),
        create: true,
        confirmation: confirm(expense(cash, 100)),
      );
      await engine.syncOnce();
      server.remoteEdit('transaction', id, {'amountMinor': 700});
      final mine = expense(cash, 300);
      await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: mine,
        create: false,
        confirmation: confirm(mine),
      );
      final s = await engine.syncOnce();
      expect(s.conflicts, 1);
      final conflicts = await db.select(db.syncConflicts).get();
      expect(conflicts.single.serverRevision, 2);
      var row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.syncStatus, 'conflict');
      expect(row.amountMinor, 300); // local overlay retained until resolved
      await store.keepRemote(conflicts.single.opId);
      row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.amountMinor, 700);
      expect(row.syncStatus, 'synced');
    });

    test('rejected operation is blocked, later edits wait, discard restores accepted state', () async {
      await seedProfile(store);
      final cash = await createAccount(store, 'Cash', 'cash', 0);
      await engine.syncOnce();
      server.rejectNext = 'ARCHIVED_REFERENCE';
      final id = store.newId();
      await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: expense(cash, 5),
        create: true,
        confirmation: confirm(expense(cash, 5)),
      );
      final s = await engine.syncOnce();
      expect(s.rejected, 1);
      final e2 = expense(cash, 6);
      await store.upsert(
        entityType: 'transaction',
        id: id,
        payload: e2,
        create: false,
        confirmation: confirm(e2),
      );
      final ops = await (db.select(
        db.outboxOps,
      )..where((o) => o.entityId.equals(id))).get();
      expect(ops.map((o) => o.state), ['blocked', 'blocked']);
      await store.discardBlocked(ops.first.opId);
      expect(
        await (db.select(
          db.transactions,
        )..where((t) => t.id.equals(id))).getSingleOrNull(),
        isNull,
      );
    });

    test(
      'an unknown remote entity type pauses sync without advancing the cursor',
      () async {
        await seedProfile(store);
        await engine.syncOnce();
        final before = (await store.cursor()).lastAppliedSeq;
        server.injectChange({
          'entityType': 'futureThing',
          'id': 'x',
          'revision': 1,
          'record': {'id': 'x', 'schemaVersion': 1, 'revision': 1},
        });
        final s = await engine.syncOnce();
        expect(s.pausedReason, 'UPGRADE_REQUIRED');
        expect((await store.cursor()).lastAppliedSeq, before);
      },
    );

    test(
      'a second device bootstraps from sequence 0 with bounded pages',
      () async {
        await seedProfile(store);
        final cash = await createAccount(store, 'Cash', 'cash', 1000);
        for (var i = 0; i < 5; i++) {
          final p = expense(cash, 10 + i);
          await store.upsert(
            entityType: 'transaction',
            id: store.newId(),
            payload: p,
            create: true,
            confirmation: confirm(p),
          );
        }
        await engine.syncOnce();
        driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
        final db2 = memoryDb();
        server.pageLimit = 2;
        final engine2 = SyncEngine(
          LocalStore(db2, uid, clock: () => t0),
          server,
        );
        await engine2.syncOnce();
        expect(await balances(db2), await balances(db));
        await db2.close();
      },
    );

    test('auth failure pauses sync and keeps operations pending', () async {
      await seedProfile(store);
      server.failWith = ApiFailure(401, 'UNAUTHENTICATED');
      final s = await engine.syncOnce();
      expect(s.pausedReason, 'UNAUTHENTICATED');
      expect((await db.select(db.outboxOps).get()).single.state, 'pending');
    });
  });
}

class _Refs implements ReferenceLookup {
  @override
  ({bool exists, bool archived, String? currency})? account(String id) =>
      switch (id) {
        'cash' || 'bank' => (exists: true, archived: false, currency: 'LKR'),
        'old' => (exists: true, archived: true, currency: 'LKR'),
        _ => null,
      };

  @override
  ({bool exists, bool archived, String type})? category(String id) =>
      switch (id) {
        'food' => (exists: true, archived: false, type: 'expense'),
        'salary' => (exists: true, archived: false, type: 'income'),
        _ => null,
      };

  @override
  ({bool exists, bool archived})? incomeSource(String id) =>
      id == 'acme' ? (exists: true, archived: false) : null;
}
