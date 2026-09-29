import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ledger/ledger_calculator.dart';
import '../../../main.dart';

class TransactionEntrySheet extends ConsumerStatefulWidget {
  const TransactionEntrySheet({super.key});

  @override
  ConsumerState<TransactionEntrySheet> createState() => _TransactionEntrySheetState();
}

class _TransactionEntrySheetState extends ConsumerState<TransactionEntrySheet> {
  final _inputController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Proposal State
  Map<String, dynamic>? _candidate;
  String? _proposalId;

  // Editable candidate fields
  String _selectedType = 'expense';
  String _amountStr = '';
  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _merchant;
  String _description = '';

  Future<void> _handleParse() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final config = ref.read(appConfigProvider);
      final draftId = const Uuid().v4();
      final idempotencyKey = const Uuid().v4();

      final res = await client.parseTransaction(
        draftId: draftId,
        rawInput: text,
        referenceNow: DateTime.now().toUtc().toIso8601String(),
        timeZone: config.defaultTimeZone,
        currency: config.defaultCurrency,
        idempotencyKey: idempotencyKey,
      );

      final data = res.data['data'];
      final cand = data['candidate'];

      final db = ref.read(appDatabaseProvider);
      final accounts = await db.select(db.accounts).get();

      setState(() {
        _candidate = cand;
        _proposalId = data['proposalId'];
        _selectedType = cand['intent'] == 'income'
            ? 'income'
            : cand['intent'] == 'transfer'
                ? 'transfer'
                : 'expense';
        final minor = cand['amountMinor'] as int?;
        _amountStr = minor != null ? (minor / 100).toStringAsFixed(2) : '';
        _merchant = cand['merchant'];
        _description = cand['description'] ?? text;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts.first.id;
          if (accounts.length > 1) {
            _selectedDestinationAccountId = accounts[1].id;
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not parse with server agent: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirm() async {
    final minor = LedgerCalculator.parseDecimalToMinor(_amountStr);
    if (minor <= 0) {
      setState(() => _errorMessage = 'Amount must be greater than zero.');
      return;
    }
    if (_selectedAccountId == null) {
      setState(() => _errorMessage = 'Funding account is required.');
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final config = ref.read(appConfigProvider);
    final txId = const Uuid().v4();
    final opId = const Uuid().v4();
    final now = DateTime.now();

    final txCompanion = TransactionsCompanion(
      id: drift.Value(txId),
      type: drift.Value(_selectedType),
      amountMinor: drift.Value(minor),
      currency: drift.Value(config.defaultCurrency),
      accountId: drift.Value(_selectedAccountId!),
      destinationAccountId: drift.Value(_selectedType == 'transfer' ? _selectedDestinationAccountId : null),
      incomeSourceId: const drift.Value(null),
      categoryId: const drift.Value(null),
      merchant: drift.Value(_merchant),
      description: drift.Value(_description),
      occurredAt: drift.Value(now),
      effectiveDate: drift.Value(now.toIso8601String().substring(0, 10)),
      entryTimeZone: drift.Value(config.defaultTimeZone),
      origin: const drift.Value('aiInput'),
      categorizationSource: const drift.Value('ai'),
      proposalId: drift.Value(_proposalId),
      openingDirection: const drift.Value(null),
      localVersion: const drift.Value(1),
      syncStatus: const drift.Value('pending'),
    );

    final outboxCompanion = OutboxOperationsCompanion(
      opId: drift.Value(opId),
      entityType: const drift.Value('transaction'),
      entityId: drift.Value(txId),
      action: const drift.Value('create'),
      baseRevision: const drift.Value(0),
      dependsOnOpId: const drift.Value(null),
      payloadJson: drift.Value(jsonEncode({
        'type': _selectedType,
        'amountMinor': minor,
        'currency': config.defaultCurrency,
        'accountId': _selectedAccountId,
        'destinationAccountId': _selectedType == 'transfer' ? _selectedDestinationAccountId : null,
        'merchant': _merchant,
        'description': _description,
        'proposalId': _proposalId,
      })),
      requestHash: drift.Value('hash-$opId'),
      confirmationJson: drift.Value(jsonEncode({
        'confirmedAt': now.toIso8601String(),
        'expectedLocalVersion': 1,
      })),
    );

    await db.confirmTransaction(
      txCompanion: txCompanion,
      outboxCompanion: outboxCompanion,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                const Text(
                  'Natural Language Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Keells groceries 3500 LKR from Commercial Bank',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleParse,
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.bolt, color: Colors.black),
              label: Text(_isLoading ? 'Analyzing...' : 'Parse with Agent', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ],

            if (_candidate != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF334155)),
              const SizedBox(height: 8),
              const Text('PROPOSED CANDIDATE (CONFIRMATION REQUIRED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF10B981))),
              const SizedBox(height: 8),

              // Type Selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                  ButtonSegment(value: 'transfer', label: Text('Transfer')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (set) => setState(() => _selectedType = set.first),
              ),
              const SizedBox(height: 10),

              // Amount Field
              TextField(
                controller: TextEditingController(text: _amountStr)..selection = TextSelection.collapsed(offset: _amountStr.length),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) => _amountStr = val,
                decoration: const InputDecoration(labelText: 'Amount (Major Units)', filled: true, fillColor: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),

              // Account Selector
              FutureBuilder<List<Account>>(
                future: db.select(db.accounts).get(),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    items: list.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (val) => setState(() => _selectedAccountId = val),
                    decoration: const InputDecoration(labelText: 'Funding Account', filled: true, fillColor: Color(0xFF0F172A)),
                  );
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _handleConfirm,
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text('Confirm & Commit to Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
