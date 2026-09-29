import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ledger/ledger_calculator.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Ledger'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions recorded.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isExpense = tx.type == 'expense';
              final isIncome = tx.type == 'income';
              final isTransfer = tx.type == 'transfer';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpense
                        ? Colors.red.withOpacity(0.15)
                        : isIncome
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.blue.withOpacity(0.15),
                    child: Icon(
                      isExpense
                          ? Icons.arrow_outward
                          : isIncome
                              ? Icons.arrow_downward
                              : Icons.swap_horiz,
                      color: isExpense
                          ? Colors.redAccent
                          : isIncome
                              ? const Color(0xFF10B981)
                              : Colors.blueAccent,
                    ),
                  ),
                  title: Text(tx.merchant ?? tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${tx.effectiveDate} • ${tx.type.toUpperCase()} • ${tx.syncStatus}'),
                  trailing: Text(
                    '${isExpense ? '-' : isIncome ? '+' : ''}${LedgerCalculator.formatMoney(tx.amountMinor, currency: tx.currency)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: isExpense
                          ? Colors.redAccent
                          : isIncome
                              ? const Color(0xFF10B981)
                              : Colors.blueAccent,
                    ),
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
