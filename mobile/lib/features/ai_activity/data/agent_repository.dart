import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/local_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/time.dart';
import '../../../core/domain/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../transactions/domain/quick_parser.dart';

/// Result of AI-assisted parsing: always an editable proposal, never a save.
class ParseOutcome {
  const ParseOutcome({
    required this.draft,
    required this.suggested,
    required this.fieldConfidence,
    required this.questions,
    required this.source,
    this.proposalId,
    this.aiMessage,
  });

  final TransactionDraft draft;
  final Set<String> suggested;
  final Map<String, double> fieldConfidence;
  final List<String> questions;

  /// rule | history | gemini | openrouter | manual | offline
  final String source;
  final String? proposalId;

  /// Why AI did not help (offline, disabled, unavailable); input is preserved.
  final String? aiMessage;
}

class InsightView {
  InsightView(this.row)
    : record = (jsonDecode(row.recordJson) as Map).cast<String, Object?>();

  final InsightRow row;
  final Map<String, Object?> record;
  String get title => record['title'] as String? ?? '';
  String get summary => record['summary'] as String? ?? '';
  List<String> get evidenceIds =>
      ((record['evidenceTransactionIds'] as List?) ?? const []).cast<String>();
  Map<String, Object?> get facts =>
      ((record['facts'] as Map?) ?? const {}).cast<String, Object?>();
}

class ActivityView {
  ActivityView(this.row)
    : record = (jsonDecode(row.recordJson) as Map).cast<String, Object?>();

  final ActivityRow row;
  final Map<String, Object?> record;
  String get summary => record['summary'] as String? ?? '';
  String? get provider => record['provider'] as String?;
  String? get model => record['model'] as String?;
  String? get proposalId => record['proposalId'] as String?;
  List<String> get entityIds =>
      ((record['entityIds'] as List?) ?? const []).cast<String>();
  DateTime? get createdAt => row.createdAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(row.createdAt!, isUtc: true);
}

class ProposalView {
  ProposalView(this.row)
    : record = (jsonDecode(row.recordJson) as Map).cast<String, Object?>();

  final ProposalRow row;
  final Map<String, Object?> record;
  Map<String, Object?> get candidate =>
      ((record['candidateJson'] as Map?) ?? const {}).cast<String, Object?>();
  double get confidence => (record['confidence'] as num?)?.toDouble() ?? 0;
  List<String> get questions =>
      ((record['questions'] as List?) ?? const []).cast<String>();
  List<String> get evidenceIds =>
      ((record['evidenceIds'] as List?) ?? const []).cast<String>();
  bool isStaleAt(
    DateTime now, {
    int? currentTargetRevision,
    bool targetDeleted = false,
  }) =>
      row.status != 'pending' ||
      row.expiresAt < now.millisecondsSinceEpoch ||
      targetDeleted ||
      (row.targetRevision != null &&
          currentTargetRevision != null &&
          row.targetRevision != currentTargetRevision);
}

class AgentRepository {
  AgentRepository(this.store, this.api, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LocalStore store;
  final ApiClient? api;
  final Uuid _uuid;
  AppDatabase get _db => store.db;

  Future<QuickRefs> _quickRefs() async {
    final accounts =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  a.userId.equals(store.uid) &
                  a.deletedAt.isNull() &
                  a.archived.equals(false),
            ))
            .get();
    final categories =
        await (_db.select(_db.categories)..where(
              (c) =>
                  c.userId.equals(store.uid) &
                  c.deletedAt.isNull() &
                  c.archived.equals(false),
            ))
            .get();
    final sources =
        await (_db.select(_db.incomeSources)..where(
              (s) =>
                  s.userId.equals(store.uid) &
                  s.deletedAt.isNull() &
                  s.archived.equals(false),
            ))
            .get();
    final rules =
        await (_db.select(_db.categorizationRules)..where(
              (r) =>
                  r.userId.equals(store.uid) &
                  r.deletedAt.isNull() &
                  r.enabled.equals(true),
            ))
            .get();
    return QuickRefs(
      accounts: [
        for (final a in accounts) (id: a.id, name: a.name, type: a.type),
      ],
      categories: [
        for (final c in categories) (id: c.id, name: c.name, type: c.type),
      ],
      sources: [
        for (final s in sources) (id: s.id, name: s.name, type: s.type),
      ],
      rules: [
        for (final r in rules)
          (
            pattern: r.normalizedPattern,
            kind: r.matchKind,
            type: r.transactionType,
            categoryId: r.categoryId,
            priority: r.priority,
          ),
      ],
    );
  }

  /// Instant local candidate (works offline).
  Future<QuickParse> localParse(String input, int exponent) async =>
      quickParse(input, await _quickRefs(), exponent: exponent);

  /// Online enhancement. Never throws: failures return the local candidate
  /// with an explanation so manual completion is always possible.
  Future<ParseOutcome> parse({
    required String draftId,
    required String rawInput,
    required ProfileRow profile,
    required SettingsRow? settings,
    required DateTime now,
    CancelToken? cancel,
  }) async {
    final local = await localParse(rawInput, profile.currencyExponent);
    ParseOutcome offline(String message) => ParseOutcome(
      draft: local.draft,
      suggested: local.suggested,
      fieldConfidence: const {},
      questions: local.questions,
      source: 'offline',
      aiMessage: message,
    );

    if (api == null) return offline('Offline suggestions only.');
    if (settings == null || !settings.aiEnabled) {
      return offline('AI is off — using offline suggestions.');
    }
    if (settings.providerConsentAt == null) {
      return offline(
        'AI needs your consent in Settings — using offline suggestions.',
      );
    }
    try {
      final data = await api!.parseTransaction(
        {
          'draftId': draftId,
          'rawInput': rawInput,
          'referenceNow': toInstant(now),
          'timeZone': profile.timeZone,
          'currency': profile.baseCurrency,
        },
        idempotencyKey: _uuid.v4(),
        cancel: cancel,
      );
      return await _fromResponse(data, local, profile.currencyExponent);
    } on ApiFailure catch (f) {
      return offline(f.toAppError().message);
    } on DioException {
      return offline('AI unavailable — enter details.');
    }
  }

  Future<ParseOutcome> _fromResponse(
    Map<String, Object?> data,
    QuickParse local,
    int exponent,
  ) async {
    final c = (data['candidate'] as Map).cast<String, Object?>();
    // Server IDs must exist locally; anything unknown stays empty for manual choice.
    final refs = await _quickRefs();
    String? known(
      Object? id,
      List<({String id, String name, String type})> list,
    ) => id is String && list.any((x) => x.id == id) ? id : null;
    final intent = c['intent'] as String?;
    final type = switch (intent) {
      'income' => TxType.income,
      'expense' => TxType.expense,
      'transfer' => TxType.transfer,
      _ => null,
    };
    final amount = c['amountMinor'] as int?;
    final fc = ((data['fieldConfidence'] as Map?) ?? const {}).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    final draft = TransactionDraft(
      type: type ?? local.draft.type,
      amountText: amount != null
          ? minorToInput(amount, exponent)
          : local.draft.amountText,
      accountId: known(c['accountId'], refs.accounts) ?? local.draft.accountId,
      destinationAccountId:
          known(c['destinationAccountId'], refs.accounts) ??
          local.draft.destinationAccountId,
      categoryId:
          known(c['categoryId'], refs.categories) ?? local.draft.categoryId,
      incomeSourceId:
          known(c['incomeSourceId'], refs.sources) ??
          local.draft.incomeSourceId,
      merchant: (c['merchant'] as String?) ?? local.draft.merchant,
      description: (c['description'] as String?) ?? local.draft.description,
      effectiveDate: c['effectiveDate'] as String?,
      occurredAt: c['occurredAt'] == null
          ? null
          : parseInstant(c['occurredAt'] as String),
      origin: TxOrigin.aiInput,
      categorizationSource: c['categoryId'] == null
          ? null
          : (data['source'] == 'rule' || data['source'] == 'history'
                ? CategorizationSource.rule
                : CategorizationSource.ai),
      proposalId: data['proposalId'] as String?,
    );
    return ParseOutcome(
      draft: draft,
      suggested: {
        if (draft.type != null) 'type',
        if (amount != null) 'amount',
        if (draft.accountId != null) 'accountId',
        if (draft.destinationAccountId != null) 'destinationAccountId',
        if (draft.categoryId != null) 'categoryId',
        if (draft.incomeSourceId != null) 'incomeSourceId',
      },
      fieldConfidence: fc,
      questions: ((data['questions'] as List?) ?? const []).cast<String>(),
      source: data['source'] as String? ?? 'manual',
      proposalId: data['proposalId'] as String?,
    );
  }

  /// Ask for a category suggestion for a saved income/expense; the result arrives as a proposal.
  Future<Result<void>> requestClassification(TransactionRow tx) async {
    if (api == null) {
      return const Err(
        AppError(ErrorKind.unavailable, 'Offline — try again later.'),
      );
    }
    if (tx.revision == 0) {
      return const Err(
        AppError(
          ErrorKind.unavailable,
          'Waiting for this entry to sync first.',
        ),
      );
    }
    try {
      await api!.classifyTransaction(
        tx.id,
        tx.revision,
        idempotencyKey: _uuid.v4(),
      );
      return const Ok(null);
    } on ApiFailure catch (f) {
      return Err(f.toAppError());
    }
  }

  Stream<List<InsightView>> watchInsights({bool includeDismissed = false}) =>
      (_db.select(_db.aiInsights)
            ..where(
              (i) =>
                  i.userId.equals(store.uid) &
                  i.deletedAt.isNull() &
                  (includeDismissed
                      ? const Constant(true)
                      : i.status.equals('active')),
            )
            ..orderBy([
              (i) => OrderingTerm.desc(i.businessDate),
              (i) => OrderingTerm.asc(i.kind),
            ]))
          .watch()
          .map((rows) => rows.map(InsightView.new).toList());

  /// Staleness: pending local ledger changes or newer ledger sequence (docs/04).
  Stream<({int lastLedgerSeq, int pendingLedgerOps})> watchFreshness() {
    final count = _db.outboxOps.opId.count();
    final pending =
        (_db.selectOnly(_db.outboxOps)
              ..addColumns([count])
              ..where(
                _db.outboxOps.userId.equals(store.uid) &
                    _db.outboxOps.entityType.isIn(const [
                      'transaction',
                      'account',
                    ]) &
                    _db.outboxOps.state.isIn(const [
                      'pending',
                      'syncing',
                      'conflict',
                      'blocked',
                    ]),
              ))
            .map((r) => r.read(count) ?? 0)
            .watchSingle();
    return store.watchCursor().asyncExpand(
      (c) => pending.map(
        (p) => (lastLedgerSeq: c?.lastLedgerSeq ?? 0, pendingLedgerOps: p),
      ),
    );
  }

  Stream<List<ActivityView>> watchActivity({String? outcome}) =>
      (_db.select(_db.aiActivities)
            ..where(
              (a) =>
                  a.userId.equals(store.uid) &
                  a.deletedAt.isNull() &
                  (outcome == null
                      ? const Constant(true)
                      : a.outcome.equals(outcome)),
            )
            ..orderBy([
              (a) => OrderingTerm.desc(a.createdAt),
              (a) => OrderingTerm.desc(a.id),
            ])
            ..limit(200))
          .watch()
          .map((rows) => rows.map(ActivityView.new).toList());

  Stream<List<ProposalView>> watchPendingProposals() =>
      (_db.select(_db.aiProposals)
            ..where(
              (p) =>
                  p.userId.equals(store.uid) &
                  p.deletedAt.isNull() &
                  p.status.equals('pending'),
            )
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch()
          .map((rows) => rows.map(ProposalView.new).toList());

  Future<ProposalView?> proposal(String id) async {
    final r =
        await (_db.select(_db.aiProposals)
              ..where((p) => p.userId.equals(store.uid) & p.id.equals(id)))
            .getSingleOrNull();
    return r == null ? null : ProposalView(r);
  }

  /// Daily-review card count: entries needing review.
  Stream<int> watchReviewCount() {
    final count = _db.reviewStates.id.count();
    return (_db.selectOnly(_db.reviewStates)
          ..addColumns([count])
          ..where(
            _db.reviewStates.userId.equals(store.uid) &
                _db.reviewStates.deletedAt.isNull() &
                _db.reviewStates.state.equals('needsReview'),
          ))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  Future<Result<void>> dismissInsight(String id) => store.dismissInsight(id);
  Future<Result<void>> rejectProposal(String id) => store.rejectProposal(id);
}
