import 'package:budget_agent/features/transactions/presentation/entry_sheet.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<TestEnv> open(WidgetTester tester, EntryMode mode) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final env = TestEnv();
  await tester.runAsync(env.seed);
  await tester.pumpWidget(
    env.wrap(
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showEntrySheet(context, mode: mode),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await settle(tester);
  await tester.tap(find.text('open'));
  await settle(tester);
  return env;
}

Future<void> close(WidgetTester tester, TestEnv env) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
  await tester.runAsync(env.dispose);
}

Future<void> choose(
  WidgetTester tester,
  String dropdownLabel,
  String item,
) async {
  final field = find.text(dropdownLabel);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await settle(tester);
  await tester.tap(find.text(item).last);
  await settle(tester);
}

Future<void> enterAmount(WidgetTester tester, String text) async {
  final f = find.widgetWithText(TextField, 'Amount');
  await tester.ensureVisible(f);
  await tester.enterText(f, text);
  await settle(tester);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await settle(tester);
}

/// Transaction create operations in the outbox.
Future<int> transactionCreates(TestEnv env) async =>
    (await (env.db.select(env.db.outboxOps)..where(
              (o) =>
                  o.entityType.equals('transaction') &
                  o.action.equals('create'),
            ))
            .get())
        .length;

void main() {
  testWidgets(
    'category-entry expense: confirm writes one transaction and one outbox op',
    (tester) async {
      final env = await open(tester, EntryMode.category);
      await enterAmount(tester, '2500');
      await choose(tester, 'Paid from account', 'Cash Wallet');
      await tapText(tester, 'Review & save');
      expect(find.text('Save expense?'), findsOneWidget);
      expect(find.text('LKR 2,500.00'), findsOneWidget);
      await tapText(tester, 'Save');
      final txs = await tester.runAsync(
        () => env.db.select(env.db.transactions).get(),
      );
      expect(txs!.where((t) => t.type == 'expense').single.amountMinor, 250000);
      expect(await tester.runAsync(() => transactionCreates(env)), 1);
      expect(find.text('Saved on this device'), findsOneWidget);
      await close(tester, env);
    },
  );

  testWidgets('missing amount and account block Save with field errors', (
    tester,
  ) async {
    final env = await open(tester, EntryMode.category);
    await tapText(tester, 'Review & save');
    expect(find.text('Enter an amount.'), findsOneWidget);
    expect(find.text('Choose the account.'), findsOneWidget);
    expect(find.text('Save expense?'), findsNothing);
    expect(await tester.runAsync(() => transactionCreates(env)), 0);
    await close(tester, env);
  });

  testWidgets('double-tapping confirm produces exactly one operation', (
    tester,
  ) async {
    final env = await open(tester, EntryMode.category);
    await enterAmount(tester, '10');
    await choose(tester, 'Paid from account', 'Cash Wallet');
    await tapText(tester, 'Review & save');
    final save = find.text('Save').last;
    await tester.tap(save);
    await tester.tap(save, warnIfMissed: false);
    await settle(tester);
    expect(await tester.runAsync(() => transactionCreates(env)), 1);
    await close(tester, env);
  });

  testWidgets('income without an income source is blocked', (tester) async {
    final env = await open(tester, EntryMode.category);
    await tapText(tester, 'Income');
    await choose(tester, 'Income category', 'Salary');
    await enterAmount(tester, '250000');
    await choose(tester, 'Received into account', 'Commercial Bank');
    await tapText(tester, 'Review & save');
    expect(find.text('Income needs an income source.'), findsOneWidget);
    expect(await tester.runAsync(() => transactionCreates(env)), 0);
    await close(tester, env);
  });

  testWidgets('transfer confirmation says it is not spending or income', (
    tester,
  ) async {
    final env = await open(tester, EntryMode.transfer);
    await choose(tester, 'From account', 'Commercial Bank');
    await choose(tester, 'To account', 'Cash Wallet');
    await enterAmount(tester, '200');
    await tapText(tester, 'Review & save');
    expect(
      find.textContaining('Not counted as spending or income'),
      findsOneWidget,
    );
    await tapText(tester, 'Save');
    final t = await tester.runAsync(
      () => (env.db.select(
        env.db.transactions,
      )..where((t) => t.type.equals('transfer'))).getSingle(),
    );
    expect(t!.amountMinor, 20000);
    expect(t.destinationAccountId, isNot(t.accountId));
    await close(tester, env);
  });
}
