import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../domain/money.dart';

/// Amount with currency, sign and a semantic label; colour is never the only cue.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.minor, {
    super.key,
    required this.currency,
    required this.exponent,
    this.kind,
    this.style,
  });

  final int minor;
  final String currency;
  final int exponent;

  /// 'income' | 'expense' | 'transfer' | 'opening' | null (balance)
  final String? kind;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = formatMinor(minor, currency: currency, exponent: exponent);
    final (prefix, color) = switch (kind) {
      'income' => ('+', AppTheme.income),
      'expense' => ('−', AppTheme.expense),
      _ => ('', null),
    };
    final shown = kind == 'income' || kind == 'expense'
        ? '$prefix${formatMinor(minor.abs(), currency: currency, exponent: exponent)}'
        : text;
    final label = switch (kind) {
      'income' => 'Income $text',
      'expense' => 'Expense $text',
      'transfer' => 'Transfer $text',
      _ => text,
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Text(
        shown,
        style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Pending / conflict / blocked marker used near totals and rows.
class SyncBadge extends StatelessWidget {
  const SyncBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'synced') return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (status) {
      'conflict' => (Icons.call_split, 'Conflict', scheme.error),
      'blocked' => (Icons.block, 'Needs attention', scheme.error),
      _ => (Icons.cloud_upload_outlined, 'Pending sync', scheme.outline),
    };
    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ),
    ),
  );
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key, this.onRetry, this.info = false});

  final String message;
  final VoidCallback? onRetry;
  final bool info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: info ? scheme.secondaryContainer : scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              info ? Icons.info_outline : Icons.error_outline,
              color: info
                  ? scheme.onSecondaryContainer
                  : scheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: info
                      ? scheme.onSecondaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
