import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../application/transaction_actions.dart';

/// Sync queue, conflicts and blocked changes (docs/08, docs/09 "Conflict").
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingOpsProvider).value ?? 0;
    final cursor = ref.watch(cursorProvider).value;
    final status = ref.watch(syncControllerProvider);
    final conflicts =
        ref.watch(conflictsProvider).value ?? const <ConflictRow>[];
    final blocked = ref.watch(blockedOpsProvider).value ?? const <OutboxRow>[];
    final lastSynced = cursor?.lastSyncedAt == null
        ? 'Never'
        : DateTime.fromMillisecondsSinceEpoch(cursor!.lastSyncedAt!)
              .toString()
              .substring(0, 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_upload_outlined),
            title: Text(
              '$pending change${pending == 1 ? '' : 's'} waiting to sync',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_done_outlined),
            title: Text('Last synced: $lastSynced'),
          ),
          if (cursor?.pausedReason != null)
            ErrorBanner(
              'Sync paused: ${ApiFailure(0, cursor!.pausedReason!).toAppError().message}',
            ),
          if (status.message != null) ErrorBanner(status.message!, info: true),
          const Text(
            'Your entries are saved on this device first. Syncing copies them to your account.',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: status.running
                ? null
                : () => ref.read(syncControllerProvider.notifier).syncNow(),
            icon: status.running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: const Text('Sync now'),
          ),
          const SizedBox(height: 24),
          Text('Conflicts', style: Theme.of(context).textTheme.titleMedium),
          if (conflicts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No conflicts.'),
            ),
          for (final c in conflicts) _ConflictCard(conflict: c),
          const SizedBox(height: 24),
          Text(
            'Changes that could not sync',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (blocked.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nothing blocked.'),
            ),
          for (final o in blocked) _BlockedCard(op: o),
        ],
      ),
    );
  }
}

Map<String, Object?>? _decode(String? json) =>
    json == null ? null : (jsonDecode(json) as Map).cast<String, Object?>();

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict});

  final ConflictRow conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exponent = ref.watch(profileProvider).value?.currencyExponent ?? 2;
    final currency = ref.watch(profileProvider).value?.baseCurrency ?? '';
    final names = nameLookup(ref);
    final base = _decode(conflict.baseJson);
    final mine = _decode(conflict.proposedJson);
    final remote = _decode(conflict.serverJson);

    String show(String field, Map<String, Object?>? m) {
      if (m == null) return '—';
      if (field == 'deletedAt') {
        return m['deletedAt'] == null ? 'No' : 'Deleted';
      }
      final v = m[field];
      if (v == null) return '—';
      return switch (field) {
        'amountMinor' || 'limitMinor' => formatMinor(
          v as int,
          currency: currency,
          exponent: exponent,
        ),
        'accountId' || 'destinationAccountId' => names.account(v as String),
        'categoryId' => names.category(v as String),
        'incomeSourceId' => names.source(v as String),
        _ => '$v',
      };
    }

    final fields = <String>{...?mine?.keys, ...?remote?.keys}
        .where(
          (f) => !const {
            'id',
            'schemaVersion',
            'revision',
            'createdAt',
            'serverUpdatedAt',
            'currency',
            'entryTimeZone',
            'occurredAt',
            'origin',
          }.contains(f),
        )
        .where((f) => show(f, mine) != show(f, remote))
        .toList();
    final remoteDeleted = remote == null || remote['deletedAt'] != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${conflict.entityType} changed on another device',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Text(''),
                    Text(
                      'Original',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Saved on this device',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Accepted from another device',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                for (final f in fields)
                  TableRow(
                    children: [
                      Text(f),
                      Text(show(f, base)),
                      Text(show(f, mine)),
                      Text(show(f, remote)),
                    ],
                  ),
              ],
            ),
            if (remoteDeleted)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'The entry was deleted on another device. Restoring is not supported; create a new entry if still needed.',
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(localStoreProvider)!
                        .keepRemote(conflict.opId);
                    if (context.mounted) {
                      showMessage(
                        context,
                        'Kept the version from your other device.',
                      );
                    }
                  },
                  child: const Text('Keep remote'),
                ),
                if (!remoteDeleted && mine != null)
                  FilledButton(
                    onPressed: () async {
                      String? failure;
                      await showConfirmationSheet(
                        context,
                        title: 'Apply my changes?',
                        rows: [
                          for (final f in fields)
                            ConfirmRow(
                              f,
                              '${show(f, remote)} → ${show(f, mine)}',
                            ),
                        ],
                        payload: mine,
                        note: 'This replaces the version accepted from your other device.',
                        onConfirm: (c) async {
                          final r = await ref
                              .read(localStoreProvider)!
                              .applyMine(conflict.opId, mine, c);
                          if (r case Err(:final error)) failure = error.message;
                          return r.isOk;
                        },
                      );
                      if (failure != null && context.mounted) {
                        showMessage(context, failure!);
                      }
                    },
                    child: const Text('Review and apply mine'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedCard extends ConsumerWidget {
  const _BlockedCard({required this.op});

  final OutboxRow op;

  String _explain(String? code) => switch (code) {
    'MISSING_REFERENCE' => 'It refers to an account, category or source that does not exist on the server.',
    'ARCHIVED_REFERENCE' => 'It uses an archived account, category or source.',
    'STALE_PROPOSAL' => 'The AI suggestion it used is out of date.',
    'VALIDATION_ERROR' => 'The server rejected the details as invalid.',
    'DEPENDENCY_FAILED' || 'DEPENDENCY_CONFLICT' || 'DEPENDENCY_UNRESOLVED' =>
      'An earlier change to the same record did not sync.',
    'IDEMPOTENCY_KEY_REUSED' => 'The change conflicts with an earlier upload.',
    _ => 'The server did not accept this change.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: ListTile(
      leading: const Icon(Icons.block, semanticLabel: 'Blocked'),
      title: Text('${op.action} ${op.entityType}'),
      subtitle: Text(_explain(op.errorCode)),
      trailing: TextButton(
        onPressed: () async {
          await ref.read(localStoreProvider)!.discardBlocked(op.opId);
          if (context.mounted) {
            showMessage(
              context,
              'Discarded; the accepted version is restored.',
            );
          }
        },
        child: const Text('Discard my change'),
      ),
    ),
  );
}
