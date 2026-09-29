import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../home/presentation/shared.dart';
import '../data/category_repository.dart';

Future<String?> _askName(
  BuildContext context,
  String title, {
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
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
}

/// Categories say what money is for; two levels, same type as the parent.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: whenData(
          categories,
          (all) => TabBarView(
            children: [
              for (final type in const ['expense', 'income'])
                _CategoryTree(type: type, all: all),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTree extends ConsumerWidget {
  const _CategoryTree({required this.type, required this.all});
  final String type;
  final List<CategoryRow> all;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roots = all
        .where((c) => c.type == type && c.parentId == null)
        .toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'A category\'s type and parent cannot change after it is created, so past reports stay correct. '
            'To reorganise, archive it and create a new one. Archived categories keep their history.',
          ),
        ),
        for (final root in roots) ...[
          _tile(context, ref, root, indent: false),
          for (final child in all.where((c) => c.parentId == root.id))
            _tile(context, ref, child, indent: true),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => _create(context, ref, parent: null),
            icon: const Icon(Icons.add),
            label: Text(
              'Add ${type == 'expense' ? 'expense' : 'income'} category',
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    CategoryRow c, {
    required bool indent,
  }) => ListTile(
    contentPadding: EdgeInsets.only(left: indent ? 48 : 16, right: 8),
    title: Text(c.archived ? '${c.name} (archived)' : c.name),
    leading: SyncBadge(c.syncStatus),
    trailing: PopupMenuButton<String>(
      tooltip: 'Category actions',
      onSelected: (v) => switch (v) {
        'child' => _create(context, ref, parent: c),
        'rename' => _rename(context, ref, c),
        _ => _save(context, ref, c, archived: !c.archived),
      },
      itemBuilder: (_) => [
        if (!indent && !c.archived)
          const PopupMenuItem(value: 'child', child: Text('Add sub-category')),
        const PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(
          value: 'archive',
          child: Text(c.archived ? 'Unarchive' : 'Archive'),
        ),
      ],
    ),
  );

  Future<void> _create(
    BuildContext context,
    WidgetRef ref, {
    CategoryRow? parent,
  }) async {
    final name = await _askName(
      context,
      parent == null ? 'New category' : 'New sub-category of ${parent.name}',
    );
    if (name == null || !context.mounted) return;
    final repo = ref.read(categoryRepositoryProvider);
    final payload = CategoryRepository.payload(
      name: name,
      type: type,
      parentId: parent?.id,
    );
    await showConfirmationSheet(
      context,
      title: 'Create category',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['name'] as String, emphasis: true),
        ConfirmRow('Type', typeLabel(type)),
        ConfirmRow('Parent', parent?.name ?? 'None (top level)'),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => repo.create(payload, c),
        success: 'Category created',
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    CategoryRow c,
  ) async {
    final name = await _askName(context, 'Rename category', initial: c.name);
    if (name == null || !context.mounted) return;
    await _save(context, ref, c, name: name);
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    CategoryRow c, {
    String? name,
    bool? archived,
  }) async {
    final repo = ref.read(categoryRepositoryProvider);
    final payload = {
      ...repo.payloadOf(c),
      if (name != null)
        'name': CategoryRepository.payload(name: name, type: c.type)['name'],
      'archived': ?archived,
    };
    await showConfirmationSheet(
      context,
      title: 'Save category',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['name'] as String, emphasis: true),
        ConfirmRow(
          'Status',
          payload['archived'] == true ? 'Archived (history kept)' : 'Active',
        ),
      ],
      onConfirm: (conf) => confirmResult(
        context,
        () => repo.update(c, payload, conf),
        success: 'Saved',
      ),
    );
  }
}

const _sourceTypes = [
  'employer',
  'freelance',
  'business',
  'investment',
  'other',
];

/// Income sources say where income came from; they never hold balances.
class IncomeSourcesScreen extends ConsumerWidget {
  const IncomeSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(incomeSourcesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Income sources')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-source',
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add source'),
      ),
      body: whenData(
        sources,
        (list) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'An income source is who paid you (an employer or client). Money itself lives in accounts; '
                'a source\'s default account is only a suggestion.',
              ),
            ),
            for (final s in list)
              ListTile(
                leading: SyncBadge(s.syncStatus),
                title: Text(s.archived ? '${s.name} (archived)' : s.name),
                subtitle: Text(typeLabel(s.type)),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Source actions',
                  onSelected: (v) => v == 'edit'
                      ? _edit(context, ref, s)
                      : _save(context, ref, s, {
                          ...ref
                              .read(incomeSourceRepositoryProvider)
                              .payloadOf(s),
                          'archived': !s.archived,
                        }),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(s.archived ? 'Unarchive' : 'Archive'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    IncomeSourceRow? current,
  ) async {
    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (_) => _SourceDialog(current: current),
    );
    if (result == null || !context.mounted) return;
    await _save(context, ref, current, result);
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    IncomeSourceRow? current,
    Map<String, Object?> payload,
  ) async {
    final repo = ref.read(incomeSourceRepositoryProvider);
    final accounts = await ref.read(activeAccountsProvider.future);
    if (!context.mounted) return;
    final defaultName =
        accounts
            .where((a) => a.id == payload['defaultAccountId'])
            .firstOrNull
            ?.name ??
        'None';
    await showConfirmationSheet(
      context,
      title: current == null ? 'Create income source' : 'Save income source',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['name'] as String, emphasis: true),
        ConfirmRow('Type', typeLabel(payload['type'] as String)),
        ConfirmRow('Suggested account', defaultName),
        ConfirmRow(
          'Status',
          payload['archived'] == true ? 'Archived' : 'Active',
        ),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => current == null
            ? repo.create(payload, c)
            : repo.update(current, payload, c),
        success: 'Saved',
      ),
    );
  }
}

class _SourceDialog extends ConsumerStatefulWidget {
  const _SourceDialog({this.current});
  final IncomeSourceRow? current;

  @override
  ConsumerState<_SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends ConsumerState<_SourceDialog> {
  late final _name = TextEditingController(text: widget.current?.name ?? '');
  late String _type = widget.current?.type ?? 'employer';
  late String? _account = widget.current?.defaultAccountId;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(activeAccountsProvider).value ?? const [];
    return AlertDialog(
      title: Text(
        widget.current == null ? 'New income source' : 'Edit income source',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: 'Type',
                helperText: widget.current == null
                    ? null
                    : 'Type cannot change',
              ),
              items: [
                for (final t in _sourceTypes)
                  DropdownMenuItem(value: t, child: Text(typeLabel(t))),
              ],
              onChanged: widget.current == null
                  ? (v) => setState(() => _type = v ?? _type)
                  : null,
            ),
            const SizedBox(height: 12),
            AccountSelector(
              label: 'Suggested account (optional)',
              accounts: accounts,
              value: _account,
              onChanged: (v) => setState(() => _account = v),
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
          onPressed: () => Navigator.pop(
            context,
            IncomeSourceRepository.payload(
              name: _name.text,
              type: _type,
              defaultAccountId: _account,
              archived: widget.current?.archived ?? false,
            ),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }
}

/// Learned merchant/keyword → category rules; only prefill suggestions.
class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    String catName(String id) =>
        categories.where((c) => c.id == id).firstOrNull?.name ??
        'Unknown category';
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: whenData(rules, (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.rule,
            title: 'No rules yet',
            message: 'After you correct a category, you can choose "Remember this mapping". Rules only suggest; you still confirm every entry.',
          );
        }
        return ListView(
          children: [
            for (final r in list)
              ListTile(
                leading: SyncBadge(r.syncStatus),
                title: Text(
                  '"${r.normalizedPattern}" → ${catName(r.categoryId)}',
                ),
                subtitle: Text(
                  '${r.matchKind == 'merchantExact' ? 'Merchant' : 'Keyword'} · ${typeLabel(r.transactionType)} · priority ${r.priority}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: r.enabled,
                      onChanged: (v) => _save(context, ref, r, {
                        ...ref.read(ruleRepositoryProvider).payloadOf(r),
                        'enabled': v,
                      }, catName),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Rule actions',
                      onSelected: (v) => v == 'edit'
                          ? _edit(context, ref, r, categories, catName)
                          : _delete(context, ref, r),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    RuleRow r,
    List<CategoryRow> categories,
    String Function(String) catName,
  ) async {
    String categoryId = r.categoryId;
    final priority = TextEditingController(text: '${r.priority}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryPicker(
                label: 'Category',
                categories: categories,
                type: r.transactionType,
                value: categoryId,
                onChanged: (v) => setState(() => categoryId = v ?? categoryId),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priority,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Priority (0–1000)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final p = int.tryParse(priority.text.trim());
    if (p == null || p < 0 || p > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Priority must be a whole number from 0 to 1000.'),
        ),
      );
      return;
    }
    await _save(context, ref, r, {
      ...ref.read(ruleRepositoryProvider).payloadOf(r),
      'categoryId': categoryId,
      'priority': p,
    }, catName);
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    RuleRow r,
    Map<String, Object?> payload,
    String Function(String) catName,
  ) async {
    final repo = ref.read(ruleRepositoryProvider);
    await showConfirmationSheet(
      context,
      title: 'Save rule',
      payload: payload,
      rows: [
        ConfirmRow(
          'Pattern',
          payload['normalizedPattern'] as String,
          emphasis: true,
        ),
        ConfirmRow('Category', catName(payload['categoryId'] as String)),
        ConfirmRow('Priority', '${payload['priority']}'),
        ConfirmRow('Enabled', payload['enabled'] == true ? 'Yes' : 'No'),
      ],
      onConfirm: (c) => confirmResult(
        context,
        () => repo.update(r, payload, c),
        success: 'Rule saved',
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, RuleRow r) async {
    final repo = ref.read(ruleRepositoryProvider);
    await showConfirmationSheet(
      context,
      title: 'Delete rule',
      destructive: true,
      saveLabel: 'Delete',
      payload: {'delete': 'categorizationRule', 'id': r.id},
      rows: [ConfirmRow('Pattern', r.normalizedPattern, emphasis: true)],
      note: 'Past entries are not changed.',
      onConfirm: (c) => confirmResult(
        context,
        () => repo.delete(r, c),
        success: 'Rule deleted',
      ),
    );
  }
}
