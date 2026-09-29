import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/transactions/presentation/ledger_screen.dart';
import 'features/accounts/presentation/accounts_screen.dart';
import 'features/budgets/presentation/budgets_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/transactions/presentation/transaction_entry_sheet.dart';

// Riverpod Global Providers
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config: config);
});

// App Router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Ledger'),
                NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Accounts'),
                NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Budgets'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const TransactionEntrySheet(),
                );
              },
              backgroundColor: AppTheme.primaryEmerald,
              icon: const Icon(Icons.auto_awesome, color: Colors.black),
              label: const Text(
                'AI Entry',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/ledger', builder: (_, __) => const LedgerScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/accounts', builder: (_, __) => const AccountsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/budgets', builder: (_, __) => const BudgetsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen())]),
        ],
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BudgetAgentApp()));
}

class BudgetAgentApp extends ConsumerWidget {
  const BudgetAgentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Budget Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
