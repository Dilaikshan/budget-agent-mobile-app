// Drift column checks reference their own getter by design.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';

/// Drift schema (docs/04-DATA-MODEL.md). Replicated tables share sync metadata;
/// primary keys are (user_id, id); instants are epoch-millisecond INTEGERs.
/// Displayed balances are computed, never stored.

const syncStatuses = ['synced', 'pending', 'syncing', 'conflict', 'blocked'];

mixin SyncMeta on Table {
  TextColumn get userId => text()();
  TextColumn get id => text()();

  /// Last accepted remote revision (0 = never accepted).
  IntColumn get revision => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get localVersion => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text()
      .withDefault(const Constant('synced'))
      .check(syncStatus.isIn(syncStatuses))();
  IntColumn get localCreatedAt => integer()();
  IntColumn get localUpdatedAt => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

@DataClassName('ProfileRow')
class Profiles extends Table with SyncMeta {
  TextColumn get displayName => text()();
  TextColumn get baseCurrency => text()();
  IntColumn get currencyExponent =>
      integer().check(currencyExponent.isBetweenValues(0, 4))();
  TextColumn get timeZone => text()();
  BoolColumn get onboardingComplete => boolean()();
}

@DataClassName('SettingsRow')
class SettingsRecords extends Table with SyncMeta {
  TextColumn get theme =>
      text().check(theme.isIn(const ['system', 'light', 'dark']))();
  BoolColumn get aiEnabled => boolean()();
  BoolColumn get dailyReviewEnabled => boolean()();
  BoolColumn get learningEnabled => boolean()();
  BoolColumn get fallbackEnabled => boolean()();
  TextColumn get privacyPolicyVersion => text().nullable()();
  IntColumn get providerConsentAt => integer().nullable()();
  TextColumn get defaultExpenseAccountId => text().nullable()();
}

@DataClassName('AccountRow')
class Accounts extends Table with SyncMeta {
  TextColumn get name => text()();
  TextColumn get type =>
      text().check(type.isIn(const ['bank', 'cash', 'wallet', 'savings']))();
  TextColumn get currency => text()();
  BoolColumn get archived => boolean()();
  IntColumn get sortOrder => integer()();
}

@DataClassName('IncomeSourceRow')
class IncomeSources extends Table with SyncMeta {
  TextColumn get name => text()();
  TextColumn get type => text().check(
    type.isIn(const [
      'employer',
      'freelance',
      'business',
      'investment',
      'other',
    ]),
  )();
  TextColumn get defaultAccountId => text().nullable()();
  BoolColumn get archived => boolean()();
}

@DataClassName('CategoryRow')
class Categories extends Table with SyncMeta {
  TextColumn get name => text()();
  TextColumn get type => text().check(type.isIn(const ['income', 'expense']))();
  TextColumn get parentId => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isSystem => boolean()();
  BoolColumn get archived => boolean()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (user_id, parent_id) REFERENCES categories (user_id, id)',
  ];
}

@DataClassName('TransactionRow')
@TableIndex(name: 'tx_date_id', columns: {#effectiveDate, #id})
@TableIndex(name: 'tx_account_date', columns: {#accountId, #effectiveDate})
@TableIndex(
  name: 'tx_destination_date',
  columns: {#destinationAccountId, #effectiveDate},
)
@TableIndex(name: 'tx_category_date', columns: {#categoryId, #effectiveDate})
class Transactions extends Table with SyncMeta {
  TextColumn get type => text().check(
    type.isIn(const ['income', 'expense', 'transfer', 'opening']),
  )();
  IntColumn get amountMinor =>
      integer().check(amountMinor.isBetweenValues(0, 1000000000000))();
  TextColumn get currency => text()();
  TextColumn get accountId => text()();
  TextColumn get destinationAccountId => text().nullable()();
  TextColumn get incomeSourceId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get merchant => text().nullable()();
  TextColumn get description => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get effectiveDate => text()();
  TextColumn get entryTimeZone => text()();
  TextColumn get origin =>
      text().check(origin.isIn(const ['manual', 'aiInput', 'opening']))();
  TextColumn get categorizationSource => text().nullable()();
  TextColumn get proposalId => text().nullable()();
  TextColumn get openingDirection => text().nullable()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (user_id, account_id) REFERENCES accounts (user_id, id)',
    'FOREIGN KEY (user_id, destination_account_id) REFERENCES accounts (user_id, id)',
    'FOREIGN KEY (user_id, category_id) REFERENCES categories (user_id, id)',
    'FOREIGN KEY (user_id, income_source_id) REFERENCES income_sources (user_id, id)',
    "CHECK (type <> 'transfer' OR (destination_account_id IS NOT NULL AND destination_account_id <> account_id))",
    "CHECK (type <> 'income' OR (income_source_id IS NOT NULL AND category_id IS NOT NULL))",
  ];
}

@DataClassName('RuleRow')
class CategorizationRules extends Table with SyncMeta {
  TextColumn get matchKind =>
      text().check(matchKind.isIn(const ['merchantExact', 'keyword']))();
  TextColumn get normalizedPattern => text()();
  TextColumn get transactionType =>
      text().check(transactionType.isIn(const ['income', 'expense']))();
  TextColumn get categoryId => text()();
  TextColumn get suggestedAccountId => text().nullable()();
  TextColumn get suggestedIncomeSourceId => text().nullable()();
  IntColumn get priority => integer()();
  BoolColumn get enabled => boolean()();
  TextColumn get origin =>
      text().check(origin.isIn(const ['user', 'acceptedSuggestion']))();
  TextColumn get evidenceJson =>
      text().check(const CustomExpression<bool>('json_valid(evidence_json)'))();
}

@DataClassName('BudgetRow')
class Budgets extends Table with SyncMeta {
  TextColumn get month => text()();
  TextColumn get categoryId => text()();
  IntColumn get limitMinor =>
      integer().check(limitMinor.isBiggerThanValue(0))();
  TextColumn get currency => text()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (user_id, category_id) REFERENCES categories (user_id, id)',
  ];
}

/// Server-owned replicas: key columns for queries plus the full canonical record.
@DataClassName('InsightRow')
class AiInsights extends Table with SyncMeta {
  TextColumn get kind => text()();
  TextColumn get businessDate => text()();
  TextColumn get status => text()();
  IntColumn get sourceWatermark => integer()();
  TextColumn get recordJson =>
      text().check(const CustomExpression<bool>('json_valid(record_json)'))();
}

@DataClassName('ProposalRow')
class AiProposals extends Table with SyncMeta {
  TextColumn get kind => text()();
  TextColumn get status => text()();
  TextColumn get targetId => text().nullable()();
  IntColumn get targetRevision => integer().nullable()();
  IntColumn get expiresAt => integer()();
  TextColumn get recordJson =>
      text().check(const CustomExpression<bool>('json_valid(record_json)'))();
}

@DataClassName('ReviewStateRow')
class ReviewStates extends Table with SyncMeta {
  IntColumn get transactionRevision => integer()();
  TextColumn get state => text()();
  TextColumn get proposalId => text().nullable()();
}

@DataClassName('ActivityRow')
@TableIndex(name: 'activity_created', columns: {#createdAt, #id})
class AiActivities extends Table with SyncMeta {
  TextColumn get agentType => text()();
  TextColumn get outcome => text()();
  TextColumn get recordJson =>
      text().check(const CustomExpression<bool>('json_valid(record_json)'))();
}

@DataClassName('AgentRunRow')
class AgentRuns extends Table with SyncMeta {
  TextColumn get agentType => text()();
  TextColumn get status => text()();
  TextColumn get businessDate => text().nullable()();
  TextColumn get recordJson =>
      text().check(const CustomExpression<bool>('json_valid(record_json)'))();
}

const outboxStates = [
  'pending',
  'syncing',
  'acknowledged',
  'conflict',
  'blocked',
  'superseded',
];

/// Immutable confirmed operations awaiting delivery (docs/08 "Local write and outbox").
@DataClassName('OutboxRow')
@TableIndex(name: 'outbox_state_next', columns: {#state, #nextAttemptAt})
class OutboxOps extends Table {
  IntColumn get ordinal => integer().autoIncrement()();
  TextColumn get opId => text().unique()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  IntColumn get baseRevision => integer().nullable()();
  TextColumn get dependsOnOpId => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get confirmationJson => text().nullable()();
  TextColumn get requestHash => text()();
  IntColumn get localVersion => integer()();
  TextColumn get state => text().check(state.isIn(outboxStates))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAt => integer().nullable()();
  TextColumn get errorCode => text().nullable()();
  IntColumn get createdAt => integer()();
}

/// Last accepted remote canonical record; pending overlays never overwrite it.
@DataClassName('ShadowRow')
class RemoteShadows extends Table {
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get revision => integer()();
  TextColumn get canonicalJson => text().check(
    const CustomExpression<bool>('json_valid(canonical_json)'),
  )();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {userId, entityType, entityId};
}

@DataClassName('CursorRow')
class SyncCursors extends Table {
  TextColumn get userId => text()();
  IntColumn get lastAppliedSeq => integer().withDefault(const Constant(0))();
  IntColumn get lastLedgerSeq => integer().withDefault(const Constant(0))();
  IntColumn get pageWatermark => integer().nullable()();
  IntColumn get protocolVersion => integer().withDefault(const Constant(1))();
  IntColumn get lastSyncedAt => integer().nullable()();
  TextColumn get pausedReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('ConflictRow')
class SyncConflicts extends Table {
  TextColumn get opId => text()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get baseJson => text().nullable()();
  TextColumn get proposedJson => text().nullable()();
  TextColumn get serverJson => text().nullable()();
  IntColumn get serverRevision => integer().nullable()();
  IntColumn get detectedAt => integer()();
  IntColumn get resolvedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Quick-input drafts; raw input is local only and expires (docs/04).
@DataClassName('DraftRow')
class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get rawInput => text()();
  TextColumn get candidateJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get expiresAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
