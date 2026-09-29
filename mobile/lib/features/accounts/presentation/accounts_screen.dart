import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../home/presentation/shared.dart';
import '../../home/presentation/tx_tile.dart';
import '../data/account_repository.dart';

const _accountTypes = ['bank', 'cash', 'wallet', 'savings'];

/// Accounts hold money; balances are always derived from the ledger (docs/09).
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final balances = ref.watch(accountBalancesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-account',
        onPressed: () => showCreateAccountDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add account'),
      ),
      body: whenData(balances, (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No accounts yet',
            message: 'An account is where money is kept: a bank account, savings, a wallet or cash.',
          );
        }
        final active = list.where((a) => !a.account.archived).toList();
        final archived = list.where((a) => a.account.archived).toList();
        Widget tile(AccountBalance a) => ListTile(
          title: Text(a.account.name, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            [
              typeLabel(a.account.type),
              a.account.currency,
              if (a.balanceMinor < 0) 'Negative balance',
              if (a.account.archived) 'Archived',
            ].join(' · '),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SyncBadge(a.hasPending ? 'pending' : 'synced'),
              const SizedBox(width: 4),
              MoneyText(
                a.balanceMinor,
                currency: money.currency,
                exponent: money.exponent,
              ),
            ],
          ),
          onTap: () => context.go('/more/accounts/${a.account.id}'),
        );
        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final a in active) tile(a),
            if (archived.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Archived (still counted in recorded balance)'),
              ),
              for (final a in archived) tile(a),
            ],
          ],
        );
      }),
    );
  }
}

/// Create account + signed opening balance as one confirmed operation.
Future<void> showCreateAccountDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final money = ref.read(moneyProvider);
  final today = ref.read(todayProvider);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CreateAccountForm(money: money, today: today),
  );
}

class _CreateAccountForm extends ConsumerStatefulWidget {
  const _CreateAccountForm({required this.money, required this.today});
  final Money money;
  final String today;

  @override
  ConsumerState<_CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends ConsumerState<_CreateAccountForm> {
  final _name = TextEditingController();
  final _opening = TextEditingController(text: '0');
  String _type = 'bank';
  late String _date = widget.today;
  Map<String, String> _errors = {};

  Future<void> _submit() async {
    final opening = parseSignedOpeningMinor(
      _opening.text,
      widget.money.exponent,
    );
    final errors = <String, String>{};
    if (_name.text.trim().isEmpty) errors['name'] = 'Enter a name.';
    if (opening case Err(:final error)) errors['opening'] = error.message;
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    final signed = opening.valueOrNull!;
    final account = AccountRepository.accountPayload(
      name: _name.text,
      type: _type,
      currency: widget.money.currency,
    );
    final payload = AccountRepository.compoundPayload(
      account,
      signed,
      _date,
      widget.money.timeZone,
    );
    final repo = ref.read(accountRepositoryProvider);
    final confirmed = await showConfirmationSheet(
      context,
      title: 'Create account',
      payload: payload,
      rows: [
        ConfirmRow('Name', account['name'] as String, emphasis: true),
        ConfirmRow('Type', typeLabel(_type)),
        ConfirmRow('Currency', widget.money.currency),
        ConfirmRow(
          'Opening balance',
          formatMinor(
            signed,
            currency: widget.money.currency,
            exponent: widget.money.exponent,
          ),
          emphasis: true,
        ),
        ConfirmRow('As of', _date),
      ],
      note: 'The opening balance is recorded as an opening entry. It is not income.',
      onConfirm: (c) => confirmResult(
        context,
        () => repo.createWithOpening(
          account: account,
          signedOpeningMinor: signed,
          effectiveDate: _date,
          timeZone: widget.money.timeZone,
          confirmation: c,
        ),
        success: 'Account created',
      ),
    );
    if (confirmed != null && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      16 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: _errors['name'],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final t in _accountTypes)
                DropdownMenuItem(value: t, child: Text(typeLabel(t))),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          AmountField(
            controller: _opening,
            currency: widget.money.currency,
            label: 'Opening balance (use - if overdrawn)',
            allowNegative: true,
            errorText: _errors['opening'],
          ),
          const SizedBox(height: 12),
          DateField(
            label: 'Opening date',
            value: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Review')),
        ],
      ),
    ),
  );
}

/// Account detail: derived balance, chronological activity, opening entry.
class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final balances = ref.watch(accountBalancesProvider);
    final activity = ref.watch(
      transactionsProvider((accountId: id, limit: 500)),
    );
    return whenData(balances, (list) {
      final a = list.where((b) => b.account.id == id).firstOrNull;
      if (a == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Account not found.')),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(a.account.name),
          actions: [
            IconButton(
              tooltip: 'Rename',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _rename(context, ref, a.account),
            ),
            IconButton(
              tooltip: a.account.archived ? 'Unarchive' : 'Archive',
              icon: Icon(
                a.account.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              onPressed: () => _saveAccount(
                context,
                ref,
                a.account,
                archived: !a.account.archived,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ListTile(
              title: const Text('Balance (from recorded entries)'),
              subtitle: Text(
                [
                  typeLabel(a.account.type),
                  a.account.currency,
                  if (a.account.archived) 'Archived: hidden from new entries, still counted in totals',
                ].join(' · '),
              ),
              trailing: MoneyText(
                a.balanceMinor,
                currency: money.currency,
                exponent: money.exponent,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (a.balanceMinor < 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(
                  'This account is below zero. That is allowed; check the entries if it is unexpected.',
                  info: true,
                ),
              ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Edit opening balance'),
              subtitle: const Text('Preview the new balance before confirming'),
              onTap: () => _editOpening(context, ref, a),
            ),
            const Divider(),
            whenData(
              activity,
              (rows) => Column(
                children: [
                  if (rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No entries yet.'),
                    ),
                  for (final v in rows)
                    TxTile(v, money: money, perspectiveAccountId: id),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    AccountRow account,
  ) async {
    final controller = TextEditingController(text: account.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename account'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Next'),
          ),
        ],
      ),
    );
    if (name == null || !context.mounted) return;
    await _saveAccount(context, ref, account, name: name);
  }

  Future<void> _saveAccount(
    BuildContext context,
    WidgetRef ref,
    AccountRow account, {
    String? name,
    bool? archived,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    final payload = {
      ...repo.payloadOf(account),
      if (name != null)
        'name': AccountRepository.accountPayload(
          name: name,
          type: account.type,
          currency: account.currency,
        )['name'],
      'archived': ?archived,
    };
    await showConfirmationSheet(
      context,
      title: 'Save account',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['name'] as String, emphasis: true),
        ConfirmRow(
          'Status',
          payload['archived'] == true
              ? 'Archived (kept in totals and history)'
              : 'Active',
        ),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => repo.update(account, payload, c),
        success: 'Saved',
      ),
    );
  }

  Future<void> _editOpening(
    BuildContext context,
    WidgetRef ref,
    AccountBalance a,
  ) async {
    final repo = ref.read(accountRepositoryProvider);
    final money = ref.read(moneyProvider);
    final opening = await repo.opening(a.account.id);
    if (opening == null || !context.mounted) return;
    final currentSigned = opening.openingDirection == 'debit'
        ? -opening.amountMinor
        : opening.amountMinor;
    final controller = TextEditingController(
      text:
          (currentSigned < 0 ? '-' : '') +
          minorToInput(currentSigned.abs(), money.exponent),
    );
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Opening balance'),
        content: AmountField(
          controller: controller,
          currency: money.currency,
          allowNegative: true,
          label: 'Opening balance',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Preview'),
          ),
        ],
      ),
    );
    if (text == null || !context.mounted) return;
    final parsed = parseSignedOpeningMinor(text, money.exponent);
    if (parsed case Err(:final error)) {
      showResult(context, Err<void>(error));
      return;
    }
    final signed = parsed.valueOrNull!;
    final after = a.balanceMinor - currentSigned + signed;
    String fmt(int m) =>
        formatMinor(m, currency: money.currency, exponent: money.exponent);
    await showConfirmationSheet(
      context,
      title: 'Change opening balance',
      payload: AccountRepository.openingPayload(opening, signed),
      rows: [
        ConfirmRow('Account', a.account.name),
        ConfirmRow(
          'Opening balance',
          '${fmt(currentSigned)} → ${fmt(signed)}',
          emphasis: true,
        ),
        ConfirmRow(
          'Account balance',
          '${fmt(a.balanceMinor)} → ${fmt(after)}',
          emphasis: true,
        ),
      ],
      note: 'This edits the existing opening entry; it is not income or spending.',
      onConfirm: (c) => confirmResult(
        context,
        () => repo.changeOpening(opening, signed, c),
        success: 'Opening balance updated',
      ),
    );
  }
}
