import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/presentation/accounts_screen.dart';
import '../features/ai_activity/presentation/activity_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/more_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transactions/presentation/entry_sheet.dart';
import '../features/transactions/presentation/review_screen.dart';
import '../features/transactions/presentation/sync_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import 'animated_splash.dart';
import 'providers.dart';

/// Route guards distinguish signed-out, email-verification, onboarding and
/// ready states (docs/09 "Navigation") without discarding saved drafts.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(userProvider, (_, _) => notifyListeners());
    ref.listen(currentUidProvider, (_, _) => notifyListeners());
  }

  void ping() => notifyListeners();
}

final onboardingStateProvider = Provider<bool?>((ref) {
  if (ref.watch(currentUidProvider) == null) return null;
  final profile = ref.watch(profileProvider);
  if (profile.isLoading && !profile.hasValue) return null;
  return profile.value?.onboardingComplete ?? false;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.listen(onboardingStateProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final user = ref.read(userProvider);
      if (user.isLoading && !user.hasValue) {
        return loc == '/splash' ? null : '/splash';
      }
      final session = ref.read(sessionProvider);
      switch (session) {
        case SignedOut():
          return loc == '/sign-in' ? null : '/sign-in';
        case Unverified():
          return loc == '/verify-email' ? null : '/verify-email';
        case SignedIn():
          final onboarded = ref.read(onboardingStateProvider);
          if (onboarded == null) return loc == '/splash' ? null : '/splash';
          if (!onboarded) return loc == '/onboarding' ? null : '/onboarding';
          if (const [
            '/splash',
            '/sign-in',
            '/verify-email',
            '/onboarding',
          ].contains(loc)) {
            return '/home';
          }
          return null;
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _Splash()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'review',
                    builder: (_, _) => const ReviewScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (_, _) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        TransactionDetailScreen(id: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, _) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'accounts',
                    builder: (_, _) => const AccountsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, s) =>
                            AccountDetailScreen(id: s.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (_, _) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'income-sources',
                    builder: (_, _) => const IncomeSourcesScreen(),
                  ),
                  GoRoute(
                    path: 'rules',
                    builder: (_, _) => const RulesScreen(),
                  ),
                  GoRoute(
                    path: 'budgets',
                    builder: (_, _) => const BudgetsScreen(),
                  ),
                  GoRoute(
                    path: 'activity',
                    builder: (_, _) => const ActivityScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(path: 'sync', builder: (_, _) => const SyncScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const BrandedLoading();
}

/// Bottom navigation: Home, Transactions, Insights, More; persistent Add
/// action opens AI quick input with an adjacent category-entry option.
class _Shell extends ConsumerWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: shell,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'category-entry',
            tooltip: 'Add by category',
            onPressed: () => showEntrySheet(context, mode: EntryMode.category),
            child: const Icon(Icons.category_outlined),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'quick-entry',
            onPressed: () => showEntrySheet(context, mode: EntryMode.quick),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
