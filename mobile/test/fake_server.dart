import 'package:budget_agent/core/domain/canonical_json.dart';
import 'package:budget_agent/core/network/api_client.dart';

/// Minimal in-memory implementation of the server sync protocol (receipts
/// before CAS, dependency revision resolution, immutable change log) used to
/// exercise the client state machine. The real server is tested in backend/.
class FakeServer implements SyncApi {
  final Map<String, Map<String, Object?>> _records = {};
  final Map<
    String,
    ({String hash, int seq, List<Map<String, Object?>> changes})
  >
  _receipts = {};
  final List<Map<String, Object?>> _changes = [];
  int seq = 0;
  int pageLimit = 100;
  bool dropNextResponse = false;
  String? rejectNext;
  ApiFailure? failWith;

  int get receiptCount => _receipts.length;
  List<Map<String, Object?>> recordsOf(String type) => _records.entries
      .where((e) => e.key.startsWith('$type/'))
      .map((e) => e.value)
      .toList();

  String _now() => '2026-09-09T08:00:00.000Z';

  Map<String, Object?> _record(
    String id,
    Map<String, Object?> payload,
    Map<String, Object?>? prev, {
    bool deleted = false,
  }) => {
    ...?prev,
    ...payload,
    'id': id,
    'schemaVersion': 1,
    'revision': ((prev?['revision'] as int?) ?? 0) + 1,
    'createdAt': prev?['createdAt'] ?? _now(),
    'serverUpdatedAt': _now(),
    'deletedAt': deleted ? _now() : null,
  };

  List<Map<String, Object?>> _publish(List<Map<String, Object?>> mutations) {
    seq++;
    for (final m in mutations) {
      _records['${m['entityType']}/${m['id']}'] =
          m['record'] as Map<String, Object?>;
    }
    _changes.add({
      'seq': seq,
      'ledgerChanged': true,
      'mutations': mutations,
      'committedAt': _now(),
    });
    return mutations;
  }

  void remoteEdit(String type, String id, Map<String, Object?> patch) {
    final prev = _records['$type/$id']!;
    _publish([
      {
        'entityType': type,
        'id': id,
        'revision': (prev['revision'] as int) + 1,
        'record': _record(id, patch, prev),
      },
    ]);
  }

  void injectChange(Map<String, Object?> mutation) => _publish([mutation]);

  @override
  Future<List<Map<String, Object?>>> push(
    List<Map<String, Object?>> operations,
  ) async {
    if (failWith != null) throw failWith!;
    final results = <Map<String, Object?>>[];
    for (final op in operations) {
      results.add(_process(op));
    }
    if (dropNextResponse) {
      dropNextResponse = false;
      throw ApiFailure(0, 'NETWORK', retryable: true);
    }
    return results;
  }

  Map<String, Object?> _process(Map<String, Object?> op) {
    final opId = op['opId'] as String;
    final hash = canonicalHash(op);
    final receipt = _receipts[opId];
    if (receipt != null) {
      if (receipt.hash != hash) {
        return {
          'opId': opId,
          'status': 'rejected',
          'code': 'IDEMPOTENCY_KEY_REUSED',
          'retryable': false,
        };
      }
      return {
        'opId': opId,
        'status': 'accepted',
        'changes': receipt.changes,
        'seq': receipt.seq,
        'replayed': true,
      };
    }
    if (rejectNext != null) {
      final code = rejectNext!;
      rejectNext = null;
      return {
        'opId': opId,
        'status': 'rejected',
        'code': code,
        'retryable': false,
      };
    }
    final type = op['entityType'] as String;
    final id = op['entityId'] as String;
    final action = op['action'] as String;
    final current = _records['$type/$id'];
    int expected;
    if (op['dependsOnOpId'] != null) {
      final pred = _receipts[op['dependsOnOpId']];
      final entry = pred?.changes
          .where((c) => c['entityType'] == type && c['id'] == id)
          .firstOrNull;
      if (entry == null) {
        return {
          'opId': opId,
          'status': 'rejected',
          'code': 'DEPENDENCY_FAILED',
          'retryable': false,
        };
      }
      expected = entry['revision'] as int;
    } else {
      expected = op['baseRevision'] as int;
    }
    if (action == 'create' || action == 'createAccountWithOpening') {
      if (current != null) {
        return {
          'opId': opId,
          'status': 'conflict',
          'code': 'REVISION_CONFLICT',
          'current': current,
        };
      }
    } else if (current == null ||
        current['deletedAt'] != null ||
        current['revision'] != expected) {
      return {
        'opId': opId,
        'status': 'conflict',
        'code': 'REVISION_CONFLICT',
        'current': current,
      };
    }
    final payload = (op['payload'] as Map?)?.cast<String, Object?>();
    List<Map<String, Object?>> mutations;
    if (action == 'createAccountWithOpening') {
      final account = (payload!['account'] as Map).cast<String, Object?>();
      final opening = (payload['opening'] as Map).cast<String, Object?>();
      final signed = opening['signedOpeningMinor'] as int;
      final openingId = openingTransactionId(id);
      final a = _record(id, account, null);
      final t = _record(openingId, {
        'type': 'opening',
        'amountMinor': signed.abs(),
        'currency': account['currency'],
        'accountId': id,
        'destinationAccountId': null,
        'incomeSourceId': null,
        'categoryId': null,
        'merchant': null,
        'description': 'Opening balance',
        'occurredAt': opening['occurredAt'],
        'effectiveDate': opening['effectiveDate'],
        'entryTimeZone': opening['entryTimeZone'],
        'origin': 'opening',
        'categorizationSource': null,
        'proposalId': null,
        'openingDirection': signed < 0 ? 'debit' : 'credit',
      }, null);
      mutations = [
        {'entityType': 'account', 'id': id, 'revision': 1, 'record': a},
        {
          'entityType': 'transaction',
          'id': openingId,
          'revision': 1,
          'record': t,
        },
      ];
    } else {
      final rec = action == 'delete'
          ? _record(id, const {}, current, deleted: true)
          : _record(id, payload!, current);
      mutations = [
        {
          'entityType': type,
          'id': id,
          'revision': rec['revision'],
          'record': rec,
        },
      ];
    }
    _publish(mutations);
    _receipts[opId] = (hash: hash, seq: seq, changes: mutations);
    return {
      'opId': opId,
      'status': 'accepted',
      'changes': mutations,
      'seq': seq,
      'replayed': false,
    };
  }

  @override
  Future<Map<String, Object?>> changes({
    required int afterSeq,
    int? watermark,
    int limit = 100,
  }) async {
    if (failWith != null) throw failWith!;
    final w = watermark ?? seq;
    final page = _changes
        .where((c) => (c['seq'] as int) > afterSeq && (c['seq'] as int) <= w)
        .take(pageLimit < limit ? pageLimit : limit)
        .toList();
    final next = page.isEmpty ? w : page.last['seq'] as int;
    return {
      'changes': page,
      'nextAfterSeq': next,
      'watermark': w,
      'hasMore': next < w,
    };
  }
}
