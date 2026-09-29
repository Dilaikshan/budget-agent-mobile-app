import 'package:flutter/material.dart';

import '../data/local_store.dart';

/// One labelled value in a confirmation; [provenance] marks AI/rule-supplied fields.
class ConfirmRow {
  const ConfirmRow(
    this.label,
    this.value, {
    this.provenance,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? provenance;
  final bool emphasis;
}

/// Shared confirmation step for every financial create/edit/delete, transfer
/// and opening change (docs/09 "Entry flows"). It shows the exact values and
/// returns a [Confirmation] bound to [payload]; confidence never skips it.
/// Save is disabled while in flight so a double tap produces one operation.
Future<Confirmation?> showConfirmationSheet(
  BuildContext context, {
  required String title,
  required List<ConfirmRow> rows,
  required Object? payload,
  String saveLabel = 'Save',
  String? note,
  bool destructive = false,
  Future<bool> Function(Confirmation confirmation)? onConfirm,
}) {
  return showModalBottomSheet<Confirmation>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ConfirmationSheet(
      title: title,
      rows: rows,
      payload: payload,
      saveLabel: saveLabel,
      note: note,
      destructive: destructive,
      onConfirm: onConfirm,
    ),
  );
}

class _ConfirmationSheet extends StatefulWidget {
  const _ConfirmationSheet({
    required this.title,
    required this.rows,
    required this.payload,
    required this.saveLabel,
    this.note,
    required this.destructive,
    this.onConfirm,
  });

  final String title;
  final List<ConfirmRow> rows;
  final Object? payload;
  final String saveLabel;
  final String? note;
  final bool destructive;
  final Future<bool> Function(Confirmation confirmation)? onConfirm;

  @override
  State<_ConfirmationSheet> createState() => _ConfirmationSheetState();
}

class _ConfirmationSheetState extends State<_ConfirmationSheet> {
  bool _busy = false;

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final confirmation = Confirmation.ofDisplayed(
      widget.payload,
      DateTime.now(),
    );
    final ok =
        widget.onConfirm == null || await widget.onConfirm!(confirmation);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(confirmation);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final r in widget.rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            r.label,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.value,
                                style: r.emphasis
                                    ? Theme.of(context).textTheme.titleMedium
                                    : null,
                              ),
                              if (r.provenance != null)
                                Text(
                                  r.provenance!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: scheme.tertiary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.note != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.note!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Back to edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: widget.destructive
                      ? FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                        )
                      : null,
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.saveLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
