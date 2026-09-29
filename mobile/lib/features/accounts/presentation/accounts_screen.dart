import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ledger/ledger_calculator.dart';
import '../../../main.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0.00');
    String type = 'bank';
    String direction = 'credit';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Account & Opening Balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Account Name (e.g. Commercial Bank)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash Wallet')),
                  DropdownMenuItem(value: 'savings', child: Text('Savings Account')),
                  DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
                ],
                onChanged: (val) => setDialogState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Account Type'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Opening Balance (Major Units)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: direction,
                items: const [
                  DropdownMenuItem(value: 'credit', child: Text('Credit (Positive Asset)')),
                  DropdownMenuItem(value: 'debit', child: Text('Debit (Overdraft/Liability)')),
                ],
                onChanged: (val) => setDialogState(() => direction = val!),
                decoration: const InputDecoration(labelText: 'Direction'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final minor = LedgerCalculator.parseDecimalToMinor(balanceCtrl.text);

                final db = ref.read(appDatabaseProvider);
                final config = ref.read(appConfigProvider);
                final accountId = const Uuid().v4();
                final openingTxId = const Uuid().v4();
                final opId = const Uuid().v4();
                final now = DateTime.now();

                final accountComp = AccountsCompanion(
                  id: drift.Value(accountId),
                  name: drift.Value(name),
                  type: drift.Value(type),
                  currency: drift.Value(config.defaultCurrency),
                  archived: const drift.Value(false),
                  sortOrder: const drift.Value(1),
                );

                final openingTxComp = TransactionsCompanion(
                  id: drift.Value(openingTxId),
                  type: const drift.Value('opening'),
                  amountMinor: drift.Value(minor.abs()),
                  currency: drift.Value(config.defaultCurrency),
                  accountId: drift.Value(accountId),
                  destinationAccountId: const drift.Value(null),
                  incomeSourceId: const drift.Value(null),
                  categoryId: const drift.Value(null),
                  merchant: const drift.Value(null),
                  description: drift.Value('Opening balance for $name'),
                  occurredAt: drift.Value(now),
                  effectiveDate: drift.Value(now.toIso8601String().substring(0, 10)),
                  entryTimeZone: drift.Value(config.defaultTimeZone),
                  origin: const drift.Value('opening'),
                  categorizationSource: const drift.Value(null),
                  proposalId: const drift.Value(null),
                  openingDirection: drift.Value(direction),
                  localVersion: const drift.Value(1),
                  syncStatus: const drift.Value('pending'),
                );

                final outboxComp = OutboxOperationsCompanion(
                  opId: drift.Value(opId),
                  entityType: const drift.Value('account'),
                  entityId: drift.Value(accountId),
                  action: const drift.Value('createAccountWithOpening'),
                  baseRevision: const drift.Value(0),
                  dependsOnOpId: const drift.Value(null),
                  payloadJson: drift.Value(jsonEncode({
                    'account': {'name': name, 'type': type, 'currency': config.defaultCurrency},
                    'opening': {'signedOpeningMinor': direction == 'debit' ? -minor.abs() : minor.abs()},
                  })),
                  requestHash: drift.Value('hash-$opId'),
                  confirmationJson: drift.Value(jsonEncode({'confirmedAt': now.toIso8601String()})),
                );

                await db.createAccountWithOpening(
                  accountCompanion: accountComp,
                  openingTxCompanion: openingTxComp,
                  outboxCompanion: outboxComp,
                );

                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Accounts'),
        actions: [
          IconButton(
            onPressed: () => _showAddAccountDialog(context, ref),
            icon: const Icon(Icons.add, color: Color(0xFF10B981)),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) => transactionsAsync.when(
          data: (transactions) {
            if (accounts.isEmpty) {
              return const Center(child: Text('No accounts found. Tap + to add.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final acc = accounts[index];
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF334155),
                      child: Icon(
                        acc.type == 'cash' ? Icons.payments_outlined : Icons.account_balance_outlined,
                        color: Colors.white70,
                      ),
                    ),
                    title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${acc.type.toUpperCase()} • ${acc.currency}'),
                    trailing: Text(
                      LedgerCalculator.formatMoney(balance, currency: acc.currency, exponent: config.currencyExponent),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: balance < 0 ? Colors.redAccent : const Color(0xFF10B981),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
