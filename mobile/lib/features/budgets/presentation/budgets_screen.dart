import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ledger/ledger_calculator.dart';
import '../../../main.dart';

final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
  return ref.watch(appDatabaseProvider).watchBudgetsForMonth(currentMonth);
});

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budgets'),
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No category budgets established for this month.\nDeterministic limits will be tracked in real-time against confirmed ledger transactions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final b = budgets[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Text('Category ${b.categoryId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            LedgerCalculator.formatMoney(b.limitMinor, currency: b.currency, exponent: config.currencyExponent),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(
                        value: 0.35,
                        backgroundColor: Color(0xFF0F172A),
                        color: Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
