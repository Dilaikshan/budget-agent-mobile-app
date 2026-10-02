import 'package:budget_agent/core/data/local_store.dart';
import 'package:budget_agent/core/domain/canonical_json.dart';
import 'package:budget_agent/features/accounts/presentation/accounts_screen.dart';
import 'package:budget_agent/features/budgets/data/budget_repository.dart';
import 'package:budget_agent/features/budgets/presentation/budgets_screen.dart';
import 'package:budget_agent/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> _finish(WidgetTester tester, TestEnv env) async {
  // Let the debounced sync timer fire (no engine in tests) and unmount before closing the DB.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox());
  await env.dispose();
}

void main() {
  testWidgets('Accounts screen shows derived balances for seeded accounts', (
    tester,
  ) async {
    final env = TestEnv();
    await tester.runAsync(env.seed);
    await tester.pumpWidget(env.wrap(const AccountsScreen()));
    await settle(tester);
    expect(find.text('Cash Wallet'), findsOneWidget);
    expect(find.text('Commercial Bank'), findsOneWidget);
    expect(find.text('LKR 5,000.00'), findsOneWidget);
    expect(find.text('LKR 100,000.00'), findsOneWidget);
    await _finish(tester, env);
  });

  testWidgets(
    'Creating an account goes through confirmation and writes account + opening',
    (tester) async {
      final env = TestEnv();
      await tester.runAsync(env.seed);
      await tester.pumpWidget(env.wrap(const AccountsScreen()));
      await settle(tester);

      await tester.tap(find.text('Add account'));
      await settle(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Savings Box',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Opening balance (use - if overdrawn)'),
        '-250.50',
      );
      await tester.tap(find.text('Review'));
      await settle(tester);

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('-LKR 250.50'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await settle(tester);

      final accounts = await tester.runAsync(
        () => env.db.select(env.db.accounts).get(),
      );
      final created = accounts!.where((a) => a.name == 'Savings Box').single;
      final opening = await tester.runAsync(
        () =>
            (env.db.select(env.db.transactions)
                  ..where((t) => t.id.equals(openingTransactionId(created.id))))
                .getSingle(),
      );
      expect(opening!.amountMinor, 25050);
      expect(opening.openingDirection, 'debit');
      final ops = await tester.runAsync(
        () => env.db.select(env.db.outboxOps).get(),
      );
      expect(
        ops!.where(
          (o) =>
              o.action == 'createAccountWithOpening' &&
              o.entityId == created.id,
        ),
        hasLength(1),
      );
      await _finish(tester, env);
    },
  );

  testWidgets('Budgets screen blocks a child budget when the parent has one', (
    tester,
  ) async {
    final env = TestEnv();
    await tester.runAsync(env.seed);
    final categories = (await tester.runAsync(
      () => env.db.select(env.db.categories).get(),
    ))!;
    final food = categories.firstWhere((c) => c.name == 'Food');
    final parentBudget = BudgetRepository.payload(
      month: '2026-09',
      categoryId: food.id,
      limitMinor: 1000000,
      currency: 'LKR',
    );
    final created = await tester.runAsync(
      () => BudgetRepository(
        env.store,
      ).create(parentBudget, Confirmation.ofDisplayed(parentBudget, testNow)),
    );
    expect(created!.isOk, isTrue);

    await tester.pumpWidget(env.wrap(const BudgetsScreen()));
    await settle(tester);
    expect(
      find.textContaining('Spent LKR 0.00 of LKR 10,000.00'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add budget'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await settle(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await settle(tester);
    await tester.tap(find.text('   Restaurant').last);
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Monthly limit'),
      '5000',
    );
    await tester.tap(find.text('Next'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await settle(tester);

    expect(find.text('Budget not allowed'), findsOneWidget);
    expect(find.textContaining('parent and its sub-category'), findsOneWidget);
    await _finish(tester, env);
  });

  testWidgets('Home shows the recorded balance over all accounts', (
    tester,
  ) async {
    final env = TestEnv();
    await tester.runAsync(env.seed);
    await tester.pumpWidget(env.wrap(const HomeScreen()));
    await settle(tester);
    // Let the balance count-up animation finish.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Recorded balance'), findsOneWidget);
    expect(find.text('LKR 105,000.00'), findsOneWidget);
    expect(
      find.textContaining('Transfers and opening balances are not counted'),
      findsOneWidget,
    );
    await _finish(tester, env);
  });
}
