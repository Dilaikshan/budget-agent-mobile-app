import 'dart:async';
import 'dart:math';

import '../data/local_store.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';

/// Pull → push → pull cycle (docs/08 "Pull, push, pull"), serialized per UID.
/// Local saves never wait for this; failures leave the outbox intact.
class SyncSummary {
  const SyncSummary({
    this.pulled = 0,
    this.accepted = 0,
    this.conflicts = 0,
    this.rejected = 0,
    this.deferred = 0,
    this.pausedReason,
  });

  final int pulled;
  final int accepted;
  final int conflicts;
  final int rejected;
  final int deferred;
  final String? pausedReason;

  SyncSummary operator +(SyncSummary o) => SyncSummary(
    pulled: pulled + o.pulled,
    accepted: accepted + o.accepted,
    conflicts: conflicts + o.conflicts,
    rejected: rejected + o.rejected,
    deferred: deferred + o.deferred,
    pausedReason: o.pausedReason ?? pausedReason,
  );
}

class SyncEngine {
  SyncEngine(this.store, this.api, {Random? random})
    : _random = random ?? Random();

  final LocalStore store;
  final SyncApi api;
  final Random _random;
  Future<SyncSummary>? _inFlight;
  bool _startedUp = false;

  static const _batchSize = 20;
  static const _maxBatchesPerCycle = 5;

  /// Serializes cycles: a caller during an active cycle shares its result.
  Future<SyncSummary> syncOnce() =>
      _inFlight ??= _cycle().whenComplete(() => _inFlight = null);

  Future<SyncSummary> _cycle() async {
    if (!_startedUp) {
      await store.resetInterrupted();
      _startedUp = true;
    }
    try {
      var summary = await _pull();
      if (summary.pausedReason != null) return summary;
      for (var i = 0; i < _maxBatchesPerCycle; i++) {
        final pushed = await _push(_batchSize);
        summary += pushed;
        if (pushed.pausedReason != null ||
            pushed.accepted + pushed.conflicts + pushed.rejected == 0) {
          break;
        }
      }
      // Pull again to receive server-generated review/activity changes.
      return summary + await _pull();
    } on ApiFailure catch (f) {
      if (f.isAuth) {
        await store.pauseSync(f.code);
        return SyncSummary(pausedReason: f.code);
      }
      return const SyncSummary(deferred: 1);
    }
  }

  Future<SyncSummary> _pull() async {
    var cursor = await store.cursor();
    var after = cursor.lastAppliedSeq;
    int? watermark = cursor.pageWatermark;
    var pulled = 0;
    for (;;) {
      final page = await api.changes(afterSeq: after, watermark: watermark);
      final changes = (page['changes'] as List)
          .cast<Map>()
          .map((m) => m.cast<String, Object?>())
          .toList();
      final hasMore = page['hasMore'] as bool;
      try {
        await store.applyPage(
          changes,
          nextAfterSeq: page['nextAfterSeq'] as int,
          watermark: page['watermark'] as int,
          hasMore: hasMore,
        );
      } on UnsupportedSchemaException {
        // Never skip or advance past a record this version cannot understand.
        await store.pauseSync('UPGRADE_REQUIRED');
        return SyncSummary(pulled: pulled, pausedReason: 'UPGRADE_REQUIRED');
      }
      pulled += changes.length;
      after = page['nextAfterSeq'] as int;
      watermark = page['watermark'] as int;
      if (!hasMore) break;
    }
    cursor = await store.cursor();
    return SyncSummary(pulled: pulled);
  }

  Future<SyncSummary> _push(int size) async {
    final ops = await store.readyOperations(size);
    if (ops.isEmpty) return const SyncSummary();
    await store.markState(ops.map((o) => o.opId), 'syncing');
    List<Map<String, Object?>> results;
    try {
      results = await api.push(ops.map(LocalStore.operationJson).toList());
    } on ApiFailure catch (f) {
      if (f.status == 413 && ops.length > 1) {
        await store.markState(ops.map((o) => o.opId), 'pending');
        return _push((ops.length / 2).floor());
      }
      if (f.status == 422 && ops.length > 1) {
        // A malformed operation fails the whole batch; isolate it one by one.
        await store.markState(ops.map((o) => o.opId), 'pending');
        var s = const SyncSummary();
        for (var i = 0; i < ops.length; i++) {
          s += await _push(1);
        }
        return s;
      }
      if (f.status == 422) {
        await store.recordRejected(ops.single, f.code);
        return const SyncSummary(rejected: 1);
      }
      await _deferAll(ops, f);
      if (f.isAuth) {
        await store.pauseSync(f.code);
        return SyncSummary(pausedReason: f.code);
      }
      return SyncSummary(deferred: ops.length);
    }

    var s = const SyncSummary();
    final byId = {for (final o in ops) o.opId: o};
    for (final r in results) {
      final op = byId.remove(r['opId']);
      if (op == null) continue;
      switch (r['status']) {
        case 'accepted':
          await store.acknowledgeAccepted(
            op,
            (r['changes'] as List)
                .cast<Map>()
                .map((m) => m.cast<String, Object?>())
                .toList(),
          );
          s += const SyncSummary(accepted: 1);
        case 'conflict':
          await store.recordConflict(
            op,
            (r['current'] as Map?)?.cast<String, Object?>(),
          );
          s += const SyncSummary(conflicts: 1);
        default:
          if (r['retryable'] == true) {
            await _defer([op], null);
            s += const SyncSummary(deferred: 1);
          } else {
            await store.recordRejected(op, r['code'] as String? ?? 'REJECTED');
            s += const SyncSummary(rejected: 1);
          }
      }
    }
    // Operations missing from the response stay pending for the next cycle.
    if (byId.isNotEmpty) await store.markState(byId.keys, 'pending');
    return s;
  }

  Future<void> _deferAll(List<OutboxRow> ops, ApiFailure f) =>
      _defer(ops, f.retryAfter);

  /// Full-jitter exponential backoff from 1 s, capped at 5 min; Retry-After ≤ 1 h wins.
  Future<void> _defer(List<OutboxRow> ops, Duration? retryAfter) async {
    final now = store.clock().millisecondsSinceEpoch;
    for (final o in ops) {
      final capMs = min(300000, 1000 * pow(2, min(o.attempts, 9)).toInt());
      final delay = retryAfter != null
          ? min(retryAfter.inMilliseconds, 3600000)
          : _random.nextInt(capMs + 1);
      await store.markState(
        [o.opId],
        'pending',
        nextAttemptAt: now + delay,
        countAttempt: true,
      );
    }
  }
}
