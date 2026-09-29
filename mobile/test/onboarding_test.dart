import 'package:budget_agent/core/data/local_store.dart';
import 'package:budget_agent/core/domain/canonical_json.dart';
import 'package:budget_agent/features/onboarding/presentation/onboarding_screen.dart';
import 'package:budget_agent/features/settings/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets(
    'creating an account goes through confirmation and writes account + opening',
    (tester) async {
      final env = TestEnv();
      await tester.runAsync(() async {
        final profile = ProfileRepository.profilePayload(
          displayName: 'Me',
          baseCurrency: 'LKR',
          currencyExponent: 2,
          timeZone: 'Asia/Colombo',
          onboardingComplete: false,
        );
        await env.store.upsert(
          entityType: 'profile',
          id: 'profile',
          payload: profile,
          create: true,
          confirmation: Confirmation.ofDisplayed(profile, testNow),
        );
        final settings = ProfileRepository.defaultSettings();
        await env.store.upsert(
          entityType: 'appSettings',
          id: 'settings',
          payload: settings,
          create: true,
          confirmation: Confirmation.ofDisplayed(settings, testNow),
        );
      });
      await tester.pumpWidget(env.wrap(const OnboardingScreen()));
      await settle(tester);

      // Resumes at the accounts step; Next is disabled until an account exists.
      expect(find.text('Accounts'), findsOneWidget);
      await tester.ensureVisible(find.text('Cash Wallet'));
      await tester.tap(find.text('Cash Wallet'));
      await tester.enterText(find.byKey(const Key('account-opening')), '2500');
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('add-account')));
      await tester.tap(find.byKey(const Key('add-account')));
      await settle(tester);

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('LKR 2,500.00'), findsOneWidget);
      await tester.tap(find.text('Confirm & save'));
      await settle(tester);

      final accounts = await tester.runAsync(
        () => env.db.select(env.db.accounts).get(),
      );
      expect(accounts!.single.name, 'Cash Wallet');
      expect(accounts.single.type, 'cash');
      final opening = await tester.runAsync(
        () =>
            (env.db.select(env.db.transactions)..where(
                  (t) => t.id.equals(openingTransactionId(accounts.single.id)),
                ))
                .getSingle(),
      );
      expect(opening!.amountMinor, 250000);
      expect(opening.openingDirection, 'credit');
      final ops = await tester.runAsync(
        () => env.db.select(env.db.outboxOps).get(),
      );
      expect(ops!.map((o) => o.action), contains('createAccountWithOpening'));

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(env.dispose);
    },
  );

  testWidgets(
    'resume shows existing accounts without duplicating the profile',
    (tester) async {
      final env = TestEnv();
      await tester.runAsync(env.seed);
      await tester.pumpWidget(env.wrap(const OnboardingScreen()));
      await settle(tester);

      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsWidgets);
      expect(find.text('Commercial Bank'), findsOneWidget);
      final profiles = await tester.runAsync(
        () => env.db.select(env.db.profiles).get(),
      );
      expect(profiles, hasLength(1));

      // Categories already exist: the step shows them instead of offering install.
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await settle(tester);
      expect(find.text('Use these categories'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(env.dispose);
    },
  );
}
