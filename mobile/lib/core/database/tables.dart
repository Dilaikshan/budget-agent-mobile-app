import 'package:drift/drift.dart';

// User profile singleton table
class UserProfiles extends Table {
  TextColumn get id => text()(); // 'profile'
  TextColumn get displayName => text()();
  TextColumn get baseCurrency => text().withDefault(const Constant('LKR'))();
  IntColumn get currencyExponent => integer().withDefault(const Constant(2))();
  TextColumn get timeZone => text().withDefault(const Constant('Asia/Colombo'))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Accounts table
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // bank | cash | wallet | savings
  TextColumn get currency => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Income sources
class IncomeSources extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // employer | freelance | business | investment | other
  TextColumn get defaultAccountId => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Categories
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income | expense
  TextColumn get parentId => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Confirmed Transactions (Discriminated union in Drift)
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // expense | income | transfer | opening
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get accountId => text()();
  TextColumn get destinationAccountId => text().nullable()();
  TextColumn get incomeSourceId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get merchant => text().nullable()();
  TextColumn get description => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get effectiveDate => text()(); // YYYY-MM-DD
  TextColumn get entryTimeZone => text()();
  TextColumn get origin => text()(); // manual | aiInput | opening
  TextColumn get categorizationSource => text().nullable()(); // manual | rule | ai
  TextColumn get proposalId => text().nullable()();
  TextColumn get openingDirection => text().nullable()(); // credit | debit
  IntColumn get localVersion => integer().withDefault(const Constant(1))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Categorization Rules
class CategorizationRules extends Table {
  TextColumn get id => text()();
  TextColumn get matchKind => text()(); // merchantExact | keyword
  TextColumn get normalizedPattern => text()();
  TextColumn get transactionType => text()(); // income | expense
  TextColumn get categoryId => text()();
  TextColumn get suggestedAccountId => text().nullable()();
  TextColumn get suggestedIncomeSourceId => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(10))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get origin => text()(); // user | acceptedSuggestion

  @override
  Set<Column> get primaryKey => {id};
}

// Monthly category budgets
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get month => text()(); // YYYY-MM
  TextColumn get categoryId => text()();
  IntColumn get limitMinor => integer()();
  TextColumn get currency => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// Outbox Operations for atomic offline sync
class OutboxOperations extends Table {
  TextColumn get opId => text()(); // UUID PK
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  IntColumn get baseRevision => integer().nullable()();
  TextColumn get dependsOnOpId => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get requestHash => text()();
  TextColumn get confirmationJson => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {opId};
}

// Sync cursor state
class SyncCursors extends Table {
  TextColumn get id => text()(); // 'cursor'
  IntColumn get lastAppliedSeq => integer().withDefault(const Constant(0))();
  IntColumn get lastLedgerSeq => integer().withDefault(const Constant(0))();
  IntColumn get pageWatermark => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
