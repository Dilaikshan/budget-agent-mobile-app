import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../accounts/data/account_repository.dart';
import '../../../core/data/codecs.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/text.dart';
import '../../../core/domain/time.dart';
import '../../../core/domain/transaction.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../ai_activity/data/agent_repository.dart';
import '../../categories/data/category_repository.dart';
import '../application/transaction_actions.dart';
import '../data/ledger_repository.dart';

enum EntryMode { quick, category, transfer }

/// Outcome of a confirmed save, used for Undo and the optional rule offer.
class _Saved {
  const _Saved(
    this.id,
    this.payload, {
    required this.edit,
    required this.rememberable,
  });

  final String id;
  final TransactionPayload payload;
  final bool edit;
  final bool rememberable;
}

/// Opens the shared entry sheet. Quick input, category entry and transfers all
/// build the same [TransactionDraft] and use the same validator and
/// confirmation (docs/09 "Entry flows").
Future<void> showEntrySheet(
  BuildContext context, {
  EntryMode mode = EntryMode.quick,
  String? editTransactionId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final saved = await showModalBottomSheet<_Saved>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _EntrySheet(mode: mode, editTransactionId: editTransactionId),
  );
  if (saved == null || messenger == null) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        saved.edit ? 'Changes saved on this device' : 'Saved on this device',
      ),
      action: saved.edit
          ? null
          : SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                if (!context.mounted) return;
                final row =
                    await container
                            .read(localStoreProvider)
                            ?.row('transaction', saved.id)
                        as TransactionRow?;
                if (row == null || !context.mounted) return;
                await showConfirmationSheet(
                  context,
                  title: 'Undo: delete this entry?',
                  rows: [
                    ConfirmRow(
                      'Amount',
                      formatMinor(
                        row.amountMinor,
                        currency: row.currency,
                        exponent:
                            container
                                .read(profileProvider)
                                .value
                                ?.currencyExponent ??
                            2,
                      ),
                      emphasis: true,
                    ),
                    ConfirmRow('Date', row.effectiveDate),
                  ],
                  payload: LedgerRepository.deleteConfirmationPayload(row.id),
                  saveLabel: 'Delete',
                  destructive: true,
                  onConfirm: (c) async =>
                      (await container
                              .read(ledgerRepositoryProvider)
                              .confirmDelete(row, c))
                          .isOk,
                );
              },
            ),
    ),
  );

  final learning =
      container.read(settingsProvider).value?.learningEnabled ?? false;
  final p = saved.payload;
  if (!learning ||
      !saved.rememberable ||
      p.merchant == null ||
      p.categoryId == null) {
    return;
  }
  final categoryName =
      (container.read(categoriesProvider).value ?? const <CategoryRow>[])
          .where((c) => c.id == p.categoryId)
          .firstOrNull
          ?.name ??
      'this category';
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 8),
      content: Text('Remember ${p.merchant} → $categoryName for next time?'),
      action: SnackBarAction(
        label: 'Remember',
        onPressed: () async {
          if (!context.mounted) return;
          final rule = RuleRepository.merchantRule(
            merchant: p.merchant!,
            transactionType: p.type.name,
            categoryId: p.categoryId!,
            evidenceTransactionId: saved.id,
          );
          await showConfirmationSheet(
            context,
            title: 'Remember this mapping?',
            rows: [
              ConfirmRow('Merchant', p.merchant!),
              ConfirmRow('Category', categoryName),
              ConfirmRow('Applies to', typeLabel(p.type.name)),
            ],
            payload: rule,
            note: 'Future entries from this merchant will be pre-filled. You still confirm every save, and you can edit or delete the rule in More › Rules.',
            onConfirm: (c) async =>
                (await container.read(ruleRepositoryProvider).save(rule, c))
                    .isOk,
          );
        },
      ),
    ),
  );
}

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.mode, this.editTransactionId});

  final EntryMode mode;
  final String? editTransactionId;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late EntryMode _mode = widget.mode;
  late final String _txId;
  final String _draftId = const Uuid().v4();

  final _raw = TextEditingController();
  final _amount = TextEditingController();
  final _merchant = TextEditingController();
  final _description = TextEditingController();

  TxType? _type;
  String? _accountId;
  String? _destinationId;
  String? _categoryId;
  String? _sourceId;
  String? _date;
  DateTime? _occurredAt;
  String? _proposalId;
  CategorizationSource? _suggestedCategorySource;

  /// Fields the user changed by hand; suggestions never overwrite them.
  final Set<String> _edited = {};

  /// Fields whose current value came from a rule/AI suggestion.
  final Map<String, String> _suggestedBy = {};

  Map<String, String> _errors = {};
  List<String> _questions = [];
  String? _aiMessage;
  String? _saveError;
  bool _aiLoading = false;
  CancelToken? _cancel;
  ParseOutcome? _unapplied;
  Timer? _debounce;
  bool _usedQuickInput = false;

  TransactionRow? _editing;
  bool _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(localStoreProvider)!;
    _txId = widget.editTransactionId ?? store.newId();
    if (_mode == EntryMode.transfer) _type = TxType.transfer;
    if (_mode == EntryMode.category) _type = TxType.expense;
    if (widget.editTransactionId != null) {
      _loadingEdit = true;
      _loadEdit(store.row('transaction', widget.editTransactionId!));
    }
  }

  Future<void> _loadEdit(Future<Object?> rowFuture) async {
    final row = await rowFuture as TransactionRow?;
    if (!mounted) return;
    setState(() {
      _loadingEdit = false;
      _editing = row;
      if (row == null) return;
      final p = TransactionPayload.fromJson(payloadFromRow('transaction', row));
      _mode = p.type == TxType.transfer
          ? EntryMode.transfer
          : EntryMode.category;
      _type = p.type;
      _amount.text = minorToInput(
        p.amountMinor,
        ref.read(profileProvider).value?.currencyExponent ?? 2,
      );
      _accountId = p.accountId;
      _destinationId = p.destinationAccountId;
      _categoryId = p.categoryId;
      _sourceId = p.incomeSourceId;
      _merchant.text = p.merchant ?? '';
      _description.text = p.description;
      _date = p.effectiveDate;
      _occurredAt = p.occurredAt;
      _proposalId = p.proposalId;
      _suggestedCategorySource = p.categorizationSource;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancel?.cancel();
    _raw.dispose();
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ quick input

  void _onRawChanged(String text) {
    _usedQuickInput = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final store = ref.read(localStoreProvider);
      final profile = ref.read(profileProvider).value;
      if (store == null || profile == null || !mounted) return;
      if (text.trim().isEmpty) {
        await store.deleteDraft(_draftId);
        return;
      }
      await store.saveDraft(_draftId, text);
      final local = await ref
          .read(agentRepositoryProvider)
          .localParse(text, profile.currencyExponent);
      if (!mounted) return;
      setState(() {
        _apply(local.draft, local.suggested, 'Offline suggestion');
        _questions = local.questions;
      });
    });
  }

  Future<void> _askAi() async {
    final text = _raw.text;
    final profile = ref.read(profileProvider).value;
    if (text.trim().isEmpty || profile == null) return;
    if (codePointLength(text) > rawInputLimit) {
      setState(
        () => _aiMessage = 'Input is too long (max $rawInputLimit characters).',
      );
      return;
    }
    _cancel?.cancel();
    final cancel = _cancel = CancelToken();
    setState(() {
      _aiLoading = true;
      _aiMessage = null;
    });
    await ref.read(localStoreProvider)?.saveDraft(_draftId, text);
    final outcome = await ref
        .read(agentRepositoryProvider)
        .parse(
          draftId: _draftId,
          rawInput: text,
          profile: profile,
          settings: ref.read(settingsProvider).value,
          now: ref.read(clockProvider)(),
          cancel: cancel,
        );
    if (!mounted || cancel.isCancelled) return;
    setState(() {
      _aiLoading = false;
      _aiMessage = outcome.aiMessage;
      _questions = outcome.questions;
      final label = switch (outcome.source) {
        'gemini' || 'openrouter' => 'Suggested by AI',
        'rule' => 'Suggested by your rules',
        'history' => 'Suggested from past entries',
        _ => 'Offline suggestion',
      };
      final blocked = _apply(outcome.draft, outcome.suggested, label);
      if (outcome.proposalId != null) _proposalId = outcome.proposalId;
      if (outcome.draft.occurredAt != null && !_edited.contains('date')) {
        _occurredAt = outcome.draft.occurredAt;
      }
      if (outcome.draft.effectiveDate != null && !_edited.contains('date')) {
        _date = outcome.draft.effectiveDate;
      }
      // Values for fields the user already edited are offered, not applied.
      _unapplied = blocked ? outcome : null;
    });
  }

  void _cancelAi() {
    _cancel?.cancel();
    setState(() {
      _aiLoading = false;
      _aiMessage =
          'AI request cancelled. Your text is kept; finish the details below.';
    });
  }

  /// Applies suggestions to fields the user has not edited. Returns true if
  /// some suggested values were withheld because the user edited that field.
  bool _apply(
    TransactionDraft d,
    Set<String> suggested,
    String label, {
    bool force = false,
  }) {
    var withheld = false;
    void set(String field, VoidCallback assign) {
      if (!suggested.contains(field)) return;
      if (_edited.contains(field) && !force) {
        withheld = true;
        return;
      }
      assign();
      _suggestedBy[field] = label;
    }

    set('type', () => _type = d.type);
    set('amount', () => _amount.text = d.amountText);
    set('accountId', () => _accountId = d.accountId);
    set('destinationAccountId', () => _destinationId = d.destinationAccountId);
    set('categoryId', () {
      _categoryId = d.categoryId;
      _suggestedCategorySource = d.categorizationSource;
    });
    set('incomeSourceId', () => _sourceId = d.incomeSourceId);
    if ((!_edited.contains('merchant') || force) && d.merchant.isNotEmpty) {
      _merchant.text = d.merchant;
    }
    if ((!_edited.contains('description') || force) &&
        d.description.isNotEmpty) {
      _description.text = d.description;
    }
    return withheld;
  }

  void _edit(String field, VoidCallback change) {
    setState(() {
      change();
      _edited.add(field);
      _suggestedBy.remove(field);
      _errors.remove(field == 'amount' ? 'amount' : field);
    });
  }

  // ------------------------------------------------------------ save

  TransactionDraft _draft(String today) {
    final categoryByUser =
        _edited.contains('categoryId') || _suggestedBy['categoryId'] == null;
    final isQuick = _usedQuickInput || (_editing?.origin == 'aiInput');
    return TransactionDraft(
      type: _type,
      amountText: _amount.text,
      accountId: _accountId,
      destinationAccountId: _type == TxType.transfer ? _destinationId : null,
      incomeSourceId: _type == TxType.income ? _sourceId : null,
      categoryId: _type == TxType.transfer ? null : _categoryId,
      merchant: _merchant.text,
      description: _description.text,
      effectiveDate: _date ?? today,
      occurredAt: _occurredAt,
      origin: isQuick ? TxOrigin.aiInput : TxOrigin.manual,
      categorizationSource: _categoryId == null
          ? null
          : (categoryByUser
                ? CategorizationSource.manual
                : (_suggestedCategorySource ?? CategorizationSource.manual)),
      proposalId: _proposalId,
    );
  }

  Future<void> _save() async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;
    final ledger = ref.read(ledgerRepositoryProvider);
    final now = ref.read(clockProvider)();
    final today = localDateOf(now, profile.timeZone);
    final refs = await ledger.references();
    final previous = _editing == null ? null : ledger.payloadOf(_editing!);
    final built = buildPayload(
      draft: _draft(today),
      currency: profile.baseCurrency,
      exponent: profile.currencyExponent,
      timeZone: previous?.entryTimeZone ?? profile.timeZone,
      refs: refs,
      now: now,
      previous: previous,
    );
    if (!mounted) return;
    switch (built) {
      case Err(:final error):
        setState(() {
          _errors = error.fields;
          _saveError = error.fields.isEmpty
              ? error.message
              : 'Fix the highlighted fields.';
        });
        return;
      case Ok(value: final payload):
        setState(() {
          _errors = {};
          _saveError = null;
        });
        await _confirm(payload, profile.currencyExponent);
    }
  }

  Future<void> _confirm(TransactionPayload payload, int exponent) async {
    final ledger = ref.read(ledgerRepositoryProvider);
    final editing = _editing;
    final provenance = {for (final e in _suggestedBy.entries) e.key: e.value};
    String? failure;
    final confirmation = await showConfirmationSheet(
      context,
      title: editing == null
          ? 'Save ${typeLabel(payload.type.name).toLowerCase()}?'
          : 'Save changes?',
      rows: payloadRows(
        payload,
        nameLookup(ref),
        exponent: exponent,
        provenance: provenance,
      ),
      payload: payload.toJson(),
      note: payload.type == TxType.transfer
          ? 'Not counted as spending or income. The same amount leaves one account and enters the other.'
          : (payload.type == TxType.expense && payload.categoryId == null
                ? 'Saved as uncategorized; it will appear in your review queue.'
                : null),
      onConfirm: (c) async {
        final r = editing == null
            ? await ledger.confirmCreate(_txId, payload, c)
            : await ledger.confirmUpdate(editing, payload, c);
        if (r case Err(:final error)) failure = errorText(error);
        return r.isOk;
      },
    );
    if (!mounted) return;
    if (failure != null) {
      setState(() => _saveError = failure);
      return;
    }
    if (confirmation == null) return;
    await ref.read(localStoreProvider)?.deleteDraft(_draftId);
    if (!mounted) return;
    Navigator.of(context).pop(
      _Saved(
        _txId,
        payload,
        edit: editing != null,
        rememberable:
            payload.categorizationSource == CategorizationSource.manual &&
            payload.type != TxType.transfer,
      ),
    );
  }

  Future<void> _discard() async {
    _cancel?.cancel();
    Navigator.of(context).pop();
  }

  // ------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final accounts =
        (ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[])
            .map((b) => b.account)
            .toList();
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryRow>[];
    final sources =
        ref.watch(incomeSourcesProvider).value ?? const <IncomeSourceRow>[];
    if (profile == null || _loadingEdit) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.editTransactionId != null &&
        (_editing == null || _editing!.deletedAt != null)) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('This entry no longer exists.'),
      );
    }
    if (_editing?.type == 'opening') {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Opening balances are edited from the account screen (More › Accounts).',
        ),
      );
    }
    final today = localDateOf(ref.read(clockProvider)(), profile.timeZone);
    final title = _editing != null
        ? 'Edit ${typeLabel(_editing!.type).toLowerCase()}'
        : switch (_mode) {
            EntryMode.quick => 'Quick entry',
            EntryMode.category => 'Add by category',
            EntryMode.transfer => 'Transfer between accounts',
          };

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _discard,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (_editing == null) _modeSwitcher(),
            const SizedBox(height: 8),
            if (_mode == EntryMode.quick) ..._quickInput(),
            if (_mode != EntryMode.transfer) _typeSelector(),
            const SizedBox(height: 12),
            if (_mode == EntryMode.transfer || _type == TxType.transfer)
              ..._transferFields(accounts)
            else
              ..._categoryFields(accounts, categories, sources),
            const SizedBox(height: 12),
            AmountField(
              key: ValueKey('amount-${_suggestedBy.containsKey('amount')}'),
              controller: _amount,
              currency: profile.baseCurrency,
              errorText: _errors['amount'],
              suggested: _suggestedBy.containsKey('amount'),
              onChanged: (_) => _edit('amount', () {}),
            ),
            const SizedBox(height: 12),
            if (_type != TxType.transfer) ...[
              TextField(
                controller: _merchant,
                decoration: InputDecoration(
                  labelText: 'Merchant (optional)',
                  errorText: _errors['merchant'],
                ),
                onChanged: (_) => _edited.add('merchant'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _description,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                errorText: _errors['description'],
              ),
              onChanged: (_) => _edited.add('description'),
            ),
            const SizedBox(height: 12),
            DateField(
              label: 'Date',
              value: _date ?? today,
              onChanged: (d) => _edit('date', () {
                _date = d;
                _occurredAt = null;
              }),
            ),
            if (_saveError != null) ErrorBanner(_saveError!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _discard,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Review & save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeSwitcher() => SegmentedButton<EntryMode>(
    segments: const [
      ButtonSegment(
        value: EntryMode.quick,
        label: Text('Quick'),
        icon: Icon(Icons.bolt),
      ),
      ButtonSegment(
        value: EntryMode.category,
        label: Text('Category'),
        icon: Icon(Icons.category_outlined),
      ),
      ButtonSegment(
        value: EntryMode.transfer,
        label: Text('Transfer'),
        icon: Icon(Icons.swap_horiz),
      ),
    ],
    selected: {_mode},
    onSelectionChanged: (s) => setState(() {
      _mode = s.first;
      if (_mode == EntryMode.transfer) {
        _type = TxType.transfer;
      } else if (_mode == EntryMode.category &&
          (_type == null || _type == TxType.transfer)) {
        _type = TxType.expense;
      }
    }),
  );

  List<Widget> _quickInput() => [
    TextField(
      controller: _raw,
      maxLines: 2,
      maxLength: rawInputLimit,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'What happened?',
        hintText: 'e.g. lunch kfc 2500 cash',
      ),
      onChanged: _onRawChanged,
      onSubmitted: (_) => _askAi(),
    ),
    Row(
      children: [
        if (_aiLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Asking AI… you can keep editing.')),
          TextButton(onPressed: _cancelAi, child: const Text('Cancel AI')),
        ] else ...[
          const Expanded(child: SizedBox()),
          TextButton.icon(
            onPressed: _askAi,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Suggest with AI'),
          ),
        ],
      ],
    ),
    if (_aiMessage != null) ErrorBanner(_aiMessage!, info: true),
    if (_unapplied != null)
      Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('AI has suggestions for fields you changed'),
          trailing: TextButton(
            onPressed: () => setState(() {
              _apply(
                _unapplied!.draft,
                _unapplied!.suggested,
                'Suggested by AI',
                force: true,
              );
              _unapplied = null;
            }),
            child: const Text('Apply suggestion'),
          ),
        ),
      ),
    if (_questions.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final q in _questions)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 6, top: 2),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      semanticLabel: 'Question',
                    ),
                  ),
                  Expanded(child: Text(q)),
                ],
              ),
          ],
        ),
      ),
  ];

  Widget _typeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SegmentedButton<TxType>(
        emptySelectionAllowed: true,
        segments: [
          const ButtonSegment(value: TxType.expense, label: Text('Expense')),
          const ButtonSegment(value: TxType.income, label: Text('Income')),
          if (_mode == EntryMode.quick)
            const ButtonSegment(
              value: TxType.transfer,
              label: Text('Transfer'),
            ),
        ],
        selected: {?_type},
        onSelectionChanged: (s) => _edit('type', () {
          _type = s.isEmpty ? null : s.first;
          if (_categoryId != null) {
            final c =
                (ref.read(categoriesProvider).value ?? const <CategoryRow>[])
                    .where((c) => c.id == _categoryId)
                    .firstOrNull;
            if (c != null && c.type != _type?.name) _categoryId = null;
          }
        }),
      ),
      if (_suggestedBy['type'] != null)
        Text(
          _suggestedBy['type']!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      if (_errors['type'] != null)
        Text(
          _errors['type']!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );

  List<Widget> _categoryFields(
    List<AccountRow> accounts,
    List<CategoryRow> categories,
    List<IncomeSourceRow> sources,
  ) {
    final income = _type == TxType.income;
    return [
      if (_type != null)
        CategoryPicker(
          key: ValueKey('cat-$_type-$_categoryId'),
          label: income ? 'Income category' : 'Category',
          categories: categories,
          type: _type!.name,
          value: _categoryId,
          allowNone: !income,
          errorText: _errors['categoryId'],
          suggested: _suggestedBy.containsKey('categoryId'),
          onChanged: (v) => _edit('categoryId', () => _categoryId = v),
        ),
      const SizedBox(height: 12),
      AccountSelector(
        key: ValueKey('acc-$_accountId'),
        label: income ? 'Received into account' : 'Paid from account',
        accounts: accounts,
        value: _accountId,
        errorText: _errors['accountId'],
        suggested: _suggestedBy.containsKey('accountId'),
        onChanged: (v) => _edit('accountId', () => _accountId = v),
      ),
      if (income) ...[
        const SizedBox(height: 12),
        IncomeSourceSelector(
          key: ValueKey('src-$_sourceId'),
          sources: sources,
          value: _sourceId,
          errorText: _errors['incomeSourceId'],
          suggested: _suggestedBy.containsKey('incomeSourceId'),
          onChanged: (v) => _edit('incomeSourceId', () => _sourceId = v),
        ),
        if (sources.isEmpty)
          const Text(
            'Add an income source in More › Income sources (for example your employer or "Other income").',
          ),
      ],
    ];
  }

  List<Widget> _transferFields(List<AccountRow> accounts) => [
    const Text(
      'Move money between your own accounts, e.g. a withdrawal (Bank → Cash) or a deposit (Cash → Bank).',
    ),
    const SizedBox(height: 12),
    AccountSelector(
      key: ValueKey('from-$_accountId-$_destinationId'),
      label: 'From account',
      accounts: accounts,
      value: _accountId,
      exclude: _destinationId,
      errorText: _errors['accountId'],
      suggested: _suggestedBy.containsKey('accountId'),
      onChanged: (v) => _edit('accountId', () => _accountId = v),
    ),
    Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => _edit('destinationAccountId', () {
          final a = _accountId;
          _accountId = _destinationId;
          _destinationId = a;
          _edited.add('accountId');
        }),
        icon: const Icon(Icons.swap_vert),
        label: const Text('Swap accounts'),
      ),
    ),
    AccountSelector(
      key: ValueKey('to-$_destinationId-$_accountId'),
      label: 'To account',
      accounts: accounts,
      value: _destinationId,
      exclude: _accountId,
      errorText: _errors['destinationAccountId'],
      suggested: _suggestedBy.containsKey('destinationAccountId'),
      onChanged: (v) => _edit('destinationAccountId', () => _destinationId = v),
    ),
  ];
}
