import 'money.dart';
import 'result.dart';
import 'text.dart';
import 'time.dart';

/// Discriminated transaction payload (docs/04 "Transaction payload"). Both
/// entry paths (AI quick input and category entry) build this same value and
/// the same validator runs before confirmation.
enum TxType { income, expense, transfer, opening }

enum TxOrigin { manual, aiInput, opening }

enum CategorizationSource { manual, rule, ai }

class TransactionPayload {
  const TransactionPayload({
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.accountId,
    required this.destinationAccountId,
    required this.incomeSourceId,
    required this.categoryId,
    required this.merchant,
    required this.description,
    required this.occurredAt,
    required this.effectiveDate,
    required this.entryTimeZone,
    required this.origin,
    required this.categorizationSource,
    required this.proposalId,
    required this.openingDirection,
  });

  final TxType type;
  final int amountMinor;
  final String currency;
  final String accountId;
  final String? destinationAccountId;
  final String? incomeSourceId;
  final String? categoryId;
  final String? merchant;
  final String description;
  final DateTime occurredAt;
  final String effectiveDate;
  final String entryTimeZone;
  final TxOrigin origin;
  final CategorizationSource? categorizationSource;
  final String? proposalId;
  final String? openingDirection;

  /// Wire payload with every field present (explicit nulls), camelCase.
  Map<String, Object?> toJson() => {
    'type': type.name,
    'amountMinor': amountMinor,
    'currency': currency,
    'accountId': accountId,
    'destinationAccountId': destinationAccountId,
    'incomeSourceId': incomeSourceId,
    'categoryId': categoryId,
    'merchant': merchant,
    'description': description,
    'occurredAt': toInstant(occurredAt),
    'effectiveDate': effectiveDate,
    'entryTimeZone': entryTimeZone,
    'origin': origin.name,
    'categorizationSource': categorizationSource?.name,
    'proposalId': proposalId,
    'openingDirection': openingDirection,
  };

  static TransactionPayload fromJson(Map<String, Object?> j) =>
      TransactionPayload(
        type: TxType.values.byName(j['type'] as String),
        amountMinor: j['amountMinor'] as int,
        currency: j['currency'] as String,
        accountId: j['accountId'] as String,
        destinationAccountId: j['destinationAccountId'] as String?,
        incomeSourceId: j['incomeSourceId'] as String?,
        categoryId: j['categoryId'] as String?,
        merchant: j['merchant'] as String?,
        description: j['description'] as String,
        occurredAt: parseInstant(j['occurredAt'] as String),
        effectiveDate: j['effectiveDate'] as String,
        entryTimeZone: j['entryTimeZone'] as String,
        origin: TxOrigin.values.byName(j['origin'] as String),
        categorizationSource: j['categorizationSource'] == null
            ? null
            : CategorizationSource.values.byName(
                j['categorizationSource'] as String,
              ),
        proposalId: j['proposalId'] as String?,
        openingDirection: j['openingDirection'] as String?,
      );
}

/// Editable draft shared by both entry flows. Nullable until confirmed.
class TransactionDraft {
  const TransactionDraft({
    this.type,
    this.amountText = '',
    this.accountId,
    this.destinationAccountId,
    this.incomeSourceId,
    this.categoryId,
    this.merchant = '',
    this.description = '',
    this.effectiveDate,
    this.occurredAt,
    this.origin = TxOrigin.manual,
    this.categorizationSource,
    this.proposalId,
  });

  final TxType? type;
  final String amountText;
  final String? accountId;
  final String? destinationAccountId;
  final String? incomeSourceId;
  final String? categoryId;
  final String merchant;
  final String description;
  final String? effectiveDate;
  final DateTime? occurredAt;
  final TxOrigin origin;
  final CategorizationSource? categorizationSource;
  final String? proposalId;

  TransactionDraft copyWith({
    TxType? type,
    String? amountText,
    String? Function()? accountId,
    String? Function()? destinationAccountId,
    String? Function()? incomeSourceId,
    String? Function()? categoryId,
    String? merchant,
    String? description,
    String? Function()? effectiveDate,
    DateTime? Function()? occurredAt,
    TxOrigin? origin,
    CategorizationSource? Function()? categorizationSource,
    String? Function()? proposalId,
  }) => TransactionDraft(
    type: type ?? this.type,
    amountText: amountText ?? this.amountText,
    accountId: accountId != null ? accountId() : this.accountId,
    destinationAccountId: destinationAccountId != null
        ? destinationAccountId()
        : this.destinationAccountId,
    incomeSourceId: incomeSourceId != null
        ? incomeSourceId()
        : this.incomeSourceId,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    merchant: merchant ?? this.merchant,
    description: description ?? this.description,
    effectiveDate: effectiveDate != null ? effectiveDate() : this.effectiveDate,
    occurredAt: occurredAt != null ? occurredAt() : this.occurredAt,
    origin: origin ?? this.origin,
    categorizationSource: categorizationSource != null
        ? categorizationSource()
        : this.categorizationSource,
    proposalId: proposalId != null ? proposalId() : this.proposalId,
  );
}

/// Reference lookups needed to validate a draft; implemented by repositories.
abstract interface class ReferenceLookup {
  ({bool exists, bool archived, String? currency})? account(String id);
  ({bool exists, bool archived, String type})? category(String id);
  ({bool exists, bool archived})? incomeSource(String id);
}

/// Normalizes and validates a draft into a confirmed-ready payload.
/// [previous] allows retaining archived references on edit.
Result<TransactionPayload> buildPayload({
  required TransactionDraft draft,
  required String currency,
  required int exponent,
  required String timeZone,
  required ReferenceLookup refs,
  required DateTime now,
  TransactionPayload? previous,
}) {
  final errors = <String, String>{};
  final type = draft.type;
  if (type == null) errors['type'] = 'Choose expense, income or transfer.';
  if (type == TxType.opening) {
    errors['type'] = 'Opening balances are edited from the account screen.';
  }

  int? amount;
  switch (parseAmountToMinor(draft.amountText, exponent)) {
    case Ok(:final value):
      amount = value;
    case Err(:final error):
      errors.addAll(error.fields);
  }

  String? checkAccount(String field, String? id, String? previousId) {
    if (id == null) {
      errors[field] = field == 'destinationAccountId'
          ? 'Choose the receiving account.'
          : (type == TxType.income
                ? 'Choose the account that received it.'
                : 'Choose the account.');
      return null;
    }
    final a = refs.account(id);
    if (a == null || !a.exists) {
      errors[field] = 'Account not found.';
    } else if (a.archived && id != previousId) {
      errors[field] = 'Account is archived.';
    } else if (a.currency != currency) {
      errors[field] = 'Account currency differs.';
    }
    return id;
  }

  checkAccount('accountId', draft.accountId, previous?.accountId);
  String? destination;
  String? categoryId = draft.categoryId;
  String? sourceId = draft.incomeSourceId;
  if (type == TxType.transfer) {
    destination = checkAccount(
      'destinationAccountId',
      draft.destinationAccountId,
      previous?.destinationAccountId,
    );
    if (destination != null && destination == draft.accountId) {
      errors['destinationAccountId'] = 'Choose two different accounts.';
    }
    categoryId = null;
    sourceId = null;
  } else {
    if (categoryId != null) {
      final c = refs.category(categoryId);
      if (c == null || !c.exists) {
        errors['categoryId'] = 'Category not found.';
      } else if (c.archived && categoryId != previous?.categoryId) {
        errors['categoryId'] = 'Category is archived.';
      } else if (c.type != type?.name) {
        errors['categoryId'] = 'Category type does not match.';
      }
    }
    if (type == TxType.income) {
      if (categoryId == null) errors['categoryId'] = 'Income needs a category.';
      if (sourceId == null) {
        errors['incomeSourceId'] = 'Income needs an income source.';
      } else {
        final s = refs.incomeSource(sourceId);
        if (s == null || !s.exists) {
          errors['incomeSourceId'] = 'Income source not found.';
        } else if (s.archived && sourceId != previous?.incomeSourceId) {
          errors['incomeSourceId'] = 'Income source is archived.';
        }
      }
    } else {
      sourceId = null;
    }
  }

  String? merchant;
  switch (boundedText('merchant', draft.merchant, merchantLimit)) {
    case Ok(:final value):
      merchant = value.isEmpty ? null : value;
    case Err(:final error):
      errors.addAll(error.fields);
  }
  var description = '';
  switch (boundedText('description', draft.description, descriptionLimit)) {
    case Ok(:final value):
      description = value;
    case Err(:final error):
      errors.addAll(error.fields);
  }

  if (!isValidTimeZone(timeZone)) {
    errors['entryTimeZone'] = 'Unknown time zone.';
  }
  if (errors.isNotEmpty) return Err(AppError.validation(errors));

  final effectiveDate =
      draft.effectiveDate ?? localDateOf(draft.occurredAt ?? now, timeZone);
  // A chosen date resolves to local noon unless it matches the explicit instant's date.
  final occurredAt =
      draft.occurredAt != null &&
          localDateOf(draft.occurredAt!, timeZone) == effectiveDate
      ? draft.occurredAt!
      : (effectiveDate == localDateOf(now, timeZone)
            ? now
            : noonInZone(effectiveDate, timeZone));

  return Ok(
    TransactionPayload(
      type: type!,
      amountMinor: amount!,
      currency: currency,
      accountId: draft.accountId!,
      destinationAccountId: type == TxType.transfer ? destination : null,
      incomeSourceId: type == TxType.income ? sourceId : null,
      categoryId: type == TxType.transfer ? null : categoryId,
      merchant: merchant,
      description: description,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        occurredAt.millisecondsSinceEpoch,
        isUtc: true,
      ),
      effectiveDate: effectiveDate,
      entryTimeZone: timeZone,
      origin: draft.origin == TxOrigin.opening ? TxOrigin.manual : draft.origin,
      categorizationSource: type == TxType.transfer
          ? null
          : (categoryId == null
                ? null
                : (draft.categorizationSource ?? CategorizationSource.manual)),
      proposalId: draft.proposalId,
      openingDirection: null,
    ),
  );
}
