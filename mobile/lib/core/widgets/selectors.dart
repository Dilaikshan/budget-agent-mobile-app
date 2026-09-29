import 'package:flutter/material.dart';

import '../database/app_database.dart';

/// Reusable selectors (docs/09 "Reusable components"). Archived entries are
/// hidden from new selections but a currently selected archived value stays visible.

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.label,
    required this.accounts,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.suggested = false,
    this.exclude,
  });

  final String label;
  final List<AccountRow> accounts;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool suggested;
  final String? exclude;

  @override
  Widget build(BuildContext context) {
    final items = accounts
        .where(
          (a) =>
              a.deletedAt == null &&
              (!a.archived || a.id == value) &&
              a.id != exclude,
        )
        .toList();
    return DropdownButtonFormField<String>(
      initialValue: items.any((a) => a.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        helperText: suggested ? 'Suggested — check before saving' : null,
      ),
      items: [
        for (final a in items)
          DropdownMenuItem(
            value: a.id,
            child: Text(
              a.archived ? '${a.name} (archived)' : a.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.label,
    required this.categories,
    required this.type,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.suggested = false,
    this.allowNone = false,
  });

  final String label;
  final List<CategoryRow> categories;
  final String type;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool suggested;

  /// Expense may be saved uncategorized; it then appears in the review queue.
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    final roots = categories
        .where(
          (c) =>
              c.type == type &&
              c.parentId == null &&
              c.deletedAt == null &&
              (!c.archived || c.id == value),
        )
        .toList();
    final entries = <DropdownMenuItem<String?>>[
      if (allowNone)
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Uncategorized'),
        ),
    ];
    for (final r in roots) {
      entries.add(
        DropdownMenuItem(
          value: r.id,
          child: Text(r.name, overflow: TextOverflow.ellipsis),
        ),
      );
      for (final c in categories.where(
        (c) =>
            c.parentId == r.id &&
            c.deletedAt == null &&
            (!c.archived || c.id == value),
      )) {
        entries.add(
          DropdownMenuItem(
            value: c.id,
            child: Text('   ${c.name}', overflow: TextOverflow.ellipsis),
          ),
        );
      }
    }
    final valid = entries.any((e) => e.value == value);
    return DropdownButtonFormField<String?>(
      initialValue: valid ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        helperText: suggested ? 'Suggested — check before saving' : null,
      ),
      items: entries,
      onChanged: onChanged,
    );
  }
}

class IncomeSourceSelector extends StatelessWidget {
  const IncomeSourceSelector({
    super.key,
    required this.sources,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.suggested = false,
  });

  final List<IncomeSourceRow> sources;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool suggested;

  @override
  Widget build(BuildContext context) {
    final items = sources
        .where((s) => s.deletedAt == null && (!s.archived || s.id == value))
        .toList();
    return DropdownButtonFormField<String>(
      initialValue: items.any((s) => s.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Income source',
        errorText: errorText,
        helperText: suggested
            ? 'Suggested — check before saving'
            : 'Where the income came from',
      ),
      items: [
        for (final s in items)
          DropdownMenuItem(
            value: s.id,
            child: Text(s.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Decimal amount input; parsing happens in the shared domain validator.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.currency,
    this.errorText,
    this.label = 'Amount',
    this.allowNegative = false,
    this.suggested = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final String? errorText;
  final String label;
  final bool allowNegative;
  final bool suggested;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(
      decimal: true,
      signed: allowNegative,
    ),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      prefixText: '$currency ',
      errorText: errorText,
      helperText: suggested ? 'Suggested — check before saving' : null,
    ),
  );
}

/// Picks a local calendar date (YYYY-MM-DD).
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final p = value.split('-').map(int.parse).toList();
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(p[0], p[1], p[2]),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        onChanged(
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
        );
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      child: Text(value),
    ),
  );
}
