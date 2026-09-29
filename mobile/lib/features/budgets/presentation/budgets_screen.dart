import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/time.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../home/presentation/shared.dart';
import '../data/budget_repository.dart';

/// Monthly category limits: no rollover, no predictions, no balance effect.
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  String? _month;

  String _shift(String month, int by) {
    final p = month.split('-').map(int.parse).toList();
    final d = DateTime.utc(p[0], p[1] + by, 1);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final month = _month ?? monthOf(ref.watch(todayProvider));
    final money = ref.watch(moneyProvider);
    final budgets = ref.watch(budgetMonthProvider(month));
    // Keep categories loaded for the add/edit dialog.
    ref.watch(categoriesProvider);
    String fmt(int m) =>
        formatMinor(m, currency: money.currency, exponent: money.exponent);
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-budget',
        onPressed: () => _edit(month, null),
        icon: const Icon(Icons.add),
        label: const Text('Add budget'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _month = _shift(month, -1)),
              ),
              Text(month, style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _month = _shift(month, 1)),
              ),
            ],
          ),
          Expanded(
            child: whenData(budgets, (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.pie_chart_outline,
                  title: 'No budgets this month',
                  message: 'Set a monthly limit for an expense category. Budgets do not roll over and never change account balances.',
                );
              }
              return ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  for (final b in list)
                    ListTile(
                      title: Text(b.categoryName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Semantics(
                            label:
                                'Spent ${fmt(b.spentMinor)} of ${fmt(b.budget.limitMinor)}',
                            child: LinearProgressIndicator(
                              value: (b.spentMinor / b.budget.limitMinor)
                                  .clamp(0, 1)
                                  .toDouble(),
                              color: b.remainingMinor < 0
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.remainingMinor < 0
                                ? 'Over budget: spent ${fmt(b.spentMinor)} of ${fmt(b.budget.limitMinor)}, ${fmt(-b.remainingMinor)} over'
                                : 'Spent ${fmt(b.spentMinor)} of ${fmt(b.budget.limitMinor)}, ${fmt(b.remainingMinor)} left',
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Budget actions',
                        onSelected: (v) =>
                            v == 'edit' ? _edit(month, b.budget) : _delete(b),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'A parent category includes its sub-categories once. Transfers and opening balances never count.',
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(String month, BudgetRow? current) async {
    final money = ref.read(moneyProvider);
    final categories = ref.read(categoriesProvider).value ?? const [];
    final result = await showDialog<({String categoryId, String amount})>(
      context: context,
      builder: (_) => _BudgetDialog(
        categories: categories,
        currency: money.currency,
        current: current,
        exponent: money.exponent,
      ),
    );
    if (result == null || !mounted) return;
    final limit = parseAmountToMinor(result.amount, money.exponent);
    if (limit case Err(:final error)) {
      showResult(context, Err<void>(error));
      return;
    }
    final repo = ref.read(budgetRepositoryProvider);
    final payload = BudgetRepository.payload(
      month: current?.month ?? month,
      categoryId: result.categoryId,
      limitMinor: limit.valueOrNull!,
      currency: money.currency,
    );
    // Surface overlap/duplicate problems before asking for confirmation.
    final check = await repo.validate(payload, excludingId: current?.id);
    if (!mounted) return;
    if (check case Err(:final error)) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Budget not allowed'),
          content: Text(error.fields.values.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final catName =
        categories.where((c) => c.id == result.categoryId).firstOrNull?.name ??
        '';
    await showConfirmationSheet(
      context,
      title: current == null ? 'Create budget' : 'Save budget',
      payload: payload,
      rows: [
        ConfirmRow('Month', payload['month'] as String),
        ConfirmRow('Category', catName, emphasis: true),
        ConfirmRow(
          'Limit',
          formatMinor(
            limit.valueOrNull!,
            currency: money.currency,
            exponent: money.exponent,
          ),
          emphasis: true,
        ),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => current == null
            ? repo.create(payload, c)
            : repo.update(current, payload, c),
        success: 'Budget saved',
      ),
    );
  }

  Future<void> _delete(BudgetProgress b) async {
    final repo = ref.read(budgetRepositoryProvider);
    await showConfirmationSheet(
      context,
      title: 'Delete budget',
      destructive: true,
      saveLabel: 'Delete',
      payload: {'delete': 'budget', 'id': b.budget.id},
      rows: [
        ConfirmRow('Category', b.categoryName, emphasis: true),
        ConfirmRow('Month', b.budget.month),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => repo.delete(b.budget, c),
        success: 'Budget deleted',
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.categories,
    required this.currency,
    required this.exponent,
    this.current,
  });
  final List<CategoryRow> categories;
  final String currency;
  final int exponent;
  final BudgetRow? current;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late String? _category = widget.current?.categoryId;
  late final _amount = TextEditingController(
    text: widget.current == null
        ? ''
        : minorToInput(widget.current!.limitMinor, widget.exponent),
  );
  String? _error;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.current == null ? 'New budget' : 'Edit budget'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryPicker(
            label: 'Expense category',
            categories: widget.categories,
            type: 'expense',
            value: _category,
            errorText: _error,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 12),
          AmountField(
            controller: _amount,
            currency: widget.currency,
            label: 'Monthly limit',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_category == null) {
            setState(() => _error = 'Choose a category.');
            return;
          }
          Navigator.pop(context, (
            categoryId: _category!,
            amount: _amount.text,
          ));
        },
        child: const Text('Next'),
      ),
    ],
  );
}
