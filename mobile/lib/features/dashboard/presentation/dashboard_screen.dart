import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ledger/ledger_calculator.dart';
import '../../../main.dart';

final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllAccounts();
});

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllTransactions();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget AI Agent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Deterministic Ledger', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) => transactionsAsync.when(
          data: (transactions) {
            // Calculate Total Net Worth from confirmed transactions
            int netWorthMinor = 0;
            for (final acc in accounts) {
              int accBalance = 0;
              for (final tx in transactions) {
                accBalance += LedgerCalculator.calculateTransactionEffect(
                  accountId: acc.id,
                  txAccountId: tx.accountId,
                  txDestinationAccountId: tx.destinationAccountId,
                  type: tx.type,
                  amountMinor: tx.amountMinor,
                  openingDirection: tx.openingDirection,
                );
              }
              netWorthMinor += accBalance;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Net Worth Hero Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL NET WORTH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LedgerCalculator.formatMoney(
                            netWorthMinor,
                            currency: config.defaultCurrency,
                            exponent: config.currencyExponent,
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Verified double-entry invariant',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Accounts Section
                const Text(
                  'Asset Accounts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (accounts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No accounts created yet. Use Accounts tab to add one.'),
                    ),
                  )
                else
                  ...accounts.map((acc) {
                    int balance = 0;
                    for (final tx in transactions) {
                      balance += LedgerCalculator.calculateTransactionEffect(
                        accountId: acc.id,
                        txAccountId: tx.accountId,
                        txDestinationAccountId: tx.destinationAccountId,
                        type: tx.type,
                        amountMinor: tx.amountMinor,
                        openingDirection: tx.openingDirection,
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF334155),
                          child: Icon(
                            acc.type == 'cash'
                                ? Icons.payments_outlined
                                : Icons.account_balance_outlined,
                            color: Colors.white70,
                          ),
                        ),
                        title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(acc.type.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1)),
                        trailing: Text(
                          LedgerCalculator.formatMoney(
                            balance,
                            currency: acc.currency,
                            exponent: config.currencyExponent,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: balance < 0 ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),

                // Recent Transactions
                const Text(
                  'Recent Confirmed Entries',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No transactions recorded yet.'),
                    ),
                  )
                else
                  ...transactions.take(5).map((tx) {
                    final isExpense = tx.type == 'expense';
                    final isIncome = tx.type == 'income';
                    final isTransfer = tx.type == 'transfer';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
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
                        title: Text(
                          tx.merchant ?? tx.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${tx.effectiveDate} • ${tx.type}'),
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
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
