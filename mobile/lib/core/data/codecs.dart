import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/time.dart';

/// Mapping between canonical records / client payloads (camelCase JSON with
/// RFC3339 instants) and Drift rows (docs/04 "Primitive storage mapping").

/// Entity types replicated to the device, including server-owned ones.
const clientWritableTypes = {
  'profile',
  'appSettings',
  'account',
  'incomeSource',
  'category',
  'transaction',
  'categorizationRule',
  'budget',
};
const serverOwnedTypes = {
  'aiInsight',
  'aiProposal',
  'reviewState',
  'aiActivity',
  'agentRun',
};
const replicatedTypes = {...clientWritableTypes, ...serverOwnedTypes};

class RowMeta {
  const RowMeta({
    required this.revision,
    required this.createdAt,
    required this.serverUpdatedAt,
    required this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
  });

  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
}

int? _ms(Object? instant) => instant == null
    ? null
    : parseInstant(instant as String).millisecondsSinceEpoch;
String? _iso(int? ms) => ms == null
    ? null
    : toInstant(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));

/// Server metadata from a canonical record.
RowMeta metaFromRecord(
  Map<String, Object?> r, {
  required int localVersion,
  required int now,
  int? localCreatedAt,
}) => RowMeta(
  revision: r['revision'] as int,
  createdAt: _ms(r['createdAt']),
  serverUpdatedAt: _ms(r['serverUpdatedAt']),
  deletedAt: _ms(r['deletedAt']),
  localVersion: localVersion,
  syncStatus: 'synced',
  localCreatedAt: localCreatedAt ?? now,
  localUpdatedAt: now,
);

/// Builds an upsert companion for [entityType] from payload/record fields.
Insertable<Object> companionFor(
  String entityType,
  String uid,
  String id,
  Map<String, Object?> f,
  RowMeta m,
) {
  final meta = (
    userId: Value(uid),
    id: Value(id),
    revision: Value(m.revision),
    createdAt: Value(m.createdAt),
    serverUpdatedAt: Value(m.serverUpdatedAt),
    deletedAt: Value(m.deletedAt),
    localVersion: Value(m.localVersion),
    syncStatus: Value(m.syncStatus),
    localCreatedAt: Value(m.localCreatedAt),
    localUpdatedAt: Value(m.localUpdatedAt),
  );
  switch (entityType) {
    case 'profile':
      return ProfilesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        displayName: Value(f['displayName'] as String),
        baseCurrency: Value(f['baseCurrency'] as String),
        currencyExponent: Value(f['currencyExponent'] as int),
        timeZone: Value(f['timeZone'] as String),
        onboardingComplete: Value(f['onboardingComplete'] as bool),
      );
    case 'appSettings':
      return SettingsRecordsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        theme: Value(f['theme'] as String),
        aiEnabled: Value(f['aiEnabled'] as bool),
        dailyReviewEnabled: Value(f['dailyReviewEnabled'] as bool),
        learningEnabled: Value(f['learningEnabled'] as bool),
        fallbackEnabled: Value(f['fallbackEnabled'] as bool),
        privacyPolicyVersion: Value(f['privacyPolicyVersion'] as String?),
        providerConsentAt: Value(_ms(f['providerConsentAt'])),
        defaultExpenseAccountId: Value(f['defaultExpenseAccountId'] as String?),
      );
    case 'account':
      return AccountsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        name: Value(f['name'] as String),
        type: Value(f['type'] as String),
        currency: Value(f['currency'] as String),
        archived: Value(f['archived'] as bool),
        sortOrder: Value(f['sortOrder'] as int),
      );
    case 'incomeSource':
      return IncomeSourcesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        name: Value(f['name'] as String),
        type: Value(f['type'] as String),
        defaultAccountId: Value(f['defaultAccountId'] as String?),
        archived: Value(f['archived'] as bool),
      );
    case 'category':
      return CategoriesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        name: Value(f['name'] as String),
        type: Value(f['type'] as String),
        parentId: Value(f['parentId'] as String?),
        icon: Value(f['icon'] as String?),
        sortOrder: Value(f['sortOrder'] as int),
        isSystem: Value(f['isSystem'] as bool),
        archived: Value(f['archived'] as bool),
      );
    case 'transaction':
      return TransactionsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        type: Value(f['type'] as String),
        amountMinor: Value(f['amountMinor'] as int),
        currency: Value(f['currency'] as String),
        accountId: Value(f['accountId'] as String),
        destinationAccountId: Value(f['destinationAccountId'] as String?),
        incomeSourceId: Value(f['incomeSourceId'] as String?),
        categoryId: Value(f['categoryId'] as String?),
        merchant: Value(f['merchant'] as String?),
        description: Value(f['description'] as String),
        occurredAt: Value(_ms(f['occurredAt'])!),
        effectiveDate: Value(f['effectiveDate'] as String),
        entryTimeZone: Value(f['entryTimeZone'] as String),
        origin: Value(f['origin'] as String),
        categorizationSource: Value(f['categorizationSource'] as String?),
        proposalId: Value(f['proposalId'] as String?),
        openingDirection: Value(f['openingDirection'] as String?),
      );
    case 'categorizationRule':
      return CategorizationRulesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        matchKind: Value(f['matchKind'] as String),
        normalizedPattern: Value(f['normalizedPattern'] as String),
        transactionType: Value(f['transactionType'] as String),
        categoryId: Value(f['categoryId'] as String),
        suggestedAccountId: Value(f['suggestedAccountId'] as String?),
        suggestedIncomeSourceId: Value(f['suggestedIncomeSourceId'] as String?),
        priority: Value(f['priority'] as int),
        enabled: Value(f['enabled'] as bool),
        origin: Value(f['origin'] as String),
        evidenceJson: Value(
          jsonEncode(f['evidenceTransactionIds'] ?? const []),
        ),
      );
    case 'budget':
      return BudgetsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        month: Value(f['month'] as String),
        categoryId: Value(f['categoryId'] as String),
        limitMinor: Value(f['limitMinor'] as int),
        currency: Value(f['currency'] as String),
      );
    case 'aiInsight':
      return AiInsightsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        kind: Value(f['kind'] as String),
        businessDate: Value(f['businessDate'] as String),
        status: Value(f['status'] as String),
        sourceWatermark: Value(f['sourceWatermark'] as int),
        recordJson: Value(jsonEncode(f)),
      );
    case 'aiProposal':
      return AiProposalsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        kind: Value(f['kind'] as String),
        status: Value(f['status'] as String),
        targetId: Value(f['targetId'] as String?),
        targetRevision: Value(f['targetRevision'] as int?),
        expiresAt: Value(_ms(f['expiresAt'])!),
        recordJson: Value(jsonEncode(f)),
      );
    case 'reviewState':
      return ReviewStatesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        transactionRevision: Value(f['transactionRevision'] as int),
        state: Value(f['state'] as String),
        proposalId: Value(f['proposalId'] as String?),
      );
    case 'aiActivity':
      return AiActivitiesCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        agentType: Value(f['agentType'] as String),
        outcome: Value(f['outcome'] as String),
        recordJson: Value(jsonEncode(f)),
      );
    case 'agentRun':
      return AgentRunsCompanion(
        userId: meta.userId,
        id: meta.id,
        revision: meta.revision,
        createdAt: meta.createdAt,
        serverUpdatedAt: meta.serverUpdatedAt,
        deletedAt: meta.deletedAt,
        localVersion: meta.localVersion,
        syncStatus: meta.syncStatus,
        localCreatedAt: meta.localCreatedAt,
        localUpdatedAt: meta.localUpdatedAt,
        agentType: Value(f['agentType'] as String),
        status: Value(f['status'] as String),
        businessDate: Value(f['businessDate'] as String?),
        recordJson: Value(jsonEncode(f)),
      );
  }
  throw ArgumentError('Unsupported entity type $entityType');
}

TableInfo<Table, Object?> tableFor(AppDatabase db, String entityType) =>
    switch (entityType) {
      'profile' => db.profiles,
      'appSettings' => db.settingsRecords,
      'account' => db.accounts,
      'incomeSource' => db.incomeSources,
      'category' => db.categories,
      'transaction' => db.transactions,
      'categorizationRule' => db.categorizationRules,
      'budget' => db.budgets,
      'aiInsight' => db.aiInsights,
      'aiProposal' => db.aiProposals,
      'reviewState' => db.reviewStates,
      'aiActivity' => db.aiActivities,
      'agentRun' => db.agentRuns,
      _ => throw ArgumentError('Unsupported entity type $entityType'),
    };

/// Client payload fields for writable types, in wire form (explicit nulls).
Map<String, Object?> payloadFromRow(String entityType, Object row) =>
    switch (row) {
      ProfileRow r => {
        'displayName': r.displayName,
        'baseCurrency': r.baseCurrency,
        'currencyExponent': r.currencyExponent,
        'timeZone': r.timeZone,
        'onboardingComplete': r.onboardingComplete,
      },
      SettingsRow r => {
        'theme': r.theme,
        'aiEnabled': r.aiEnabled,
        'dailyReviewEnabled': r.dailyReviewEnabled,
        'learningEnabled': r.learningEnabled,
        'fallbackEnabled': r.fallbackEnabled,
        'privacyPolicyVersion': r.privacyPolicyVersion,
        'providerConsentAt': _iso(r.providerConsentAt),
        'defaultExpenseAccountId': r.defaultExpenseAccountId,
      },
      AccountRow r => {
        'name': r.name,
        'type': r.type,
        'currency': r.currency,
        'archived': r.archived,
        'sortOrder': r.sortOrder,
      },
      IncomeSourceRow r => {
        'name': r.name,
        'type': r.type,
        'defaultAccountId': r.defaultAccountId,
        'archived': r.archived,
      },
      CategoryRow r => {
        'name': r.name,
        'type': r.type,
        'parentId': r.parentId,
        'icon': r.icon,
        'sortOrder': r.sortOrder,
        'isSystem': r.isSystem,
        'archived': r.archived,
      },
      TransactionRow r => {
        'type': r.type,
        'amountMinor': r.amountMinor,
        'currency': r.currency,
        'accountId': r.accountId,
        'destinationAccountId': r.destinationAccountId,
        'incomeSourceId': r.incomeSourceId,
        'categoryId': r.categoryId,
        'merchant': r.merchant,
        'description': r.description,
        'occurredAt': _iso(r.occurredAt),
        'effectiveDate': r.effectiveDate,
        'entryTimeZone': r.entryTimeZone,
        'origin': r.origin,
        'categorizationSource': r.categorizationSource,
        'proposalId': r.proposalId,
        'openingDirection': r.openingDirection,
      },
      RuleRow r => {
        'matchKind': r.matchKind,
        'normalizedPattern': r.normalizedPattern,
        'transactionType': r.transactionType,
        'categoryId': r.categoryId,
        'suggestedAccountId': r.suggestedAccountId,
        'suggestedIncomeSourceId': r.suggestedIncomeSourceId,
        'priority': r.priority,
        'enabled': r.enabled,
        'origin': r.origin,
        'evidenceTransactionIds': (jsonDecode(r.evidenceJson) as List)
            .cast<String>(),
      },
      BudgetRow r => {
        'month': r.month,
        'categoryId': r.categoryId,
        'limitMinor': r.limitMinor,
        'currency': r.currency,
      },
      _ => throw ArgumentError('Not a client-writable row: $entityType'),
    };
