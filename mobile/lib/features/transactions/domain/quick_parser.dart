import '../../../core/domain/money.dart';
import '../../../core/domain/text.dart';
import '../../../core/domain/transaction.dart';

/// Offline, rules-first quick-input parser (docs/06 "Rules before models",
/// docs/09 "Offline suggestions"). Explicit text only; never guesses cash,
/// never invents references; ambiguity leaves fields empty.
class QuickRefs {
  const QuickRefs({
    required this.accounts,
    required this.categories,
    required this.sources,
    required this.rules,
  });

  final List<({String id, String name, String type})> accounts;
  final List<({String id, String name, String type})> categories;
  final List<({String id, String name, String type})> sources;
  final List<
    ({
      String pattern,
      String kind,
      String type,
      String categoryId,
      int priority,
    })
  >
  rules;
}

class QuickParse {
  const QuickParse(this.draft, this.suggested, this.questions);

  final TransactionDraft draft;

  /// Fields filled by rules (shown as "Suggested").
  final Set<String> suggested;
  final List<String> questions;
}

const _transferWords = {
  'withdraw',
  'withdrew',
  'withdrawal',
  'atm',
  'transfer',
  'transferred',
  'moved',
};
const _withdrawWords = {'withdraw', 'withdrew', 'withdrawal', 'atm'};
const _incomeWords = {
  'salary',
  'freelance',
  'received',
  'income',
  'bonus',
  'dividend',
  'earned',
  'credited',
};
const _expenseWords = {'paid', 'pay', 'bought', 'spent', 'bill', 'purchase'};
const _stop = {
  'bank',
  'account',
  'acc',
  'savings',
  'saving',
  'current',
  'wallet',
  'the',
  'my',
  'of',
  'plc',
  'ltd',
  'and',
};
const _keywordCategories = <String, List<String>>{
  'lunch': ['Restaurant', 'Food'],
  'dinner': ['Restaurant', 'Food'],
  'breakfast': ['Restaurant', 'Food'],
  'coffee': ['Restaurant', 'Food'],
  'kfc': ['Restaurant', 'Food'],
  'groceries': ['Groceries', 'Food'],
  'grocery': ['Groceries', 'Food'],
  'keells': ['Groceries', 'Food'],
  'cargills': ['Groceries', 'Food'],
  'bus': ['Transport'],
  'taxi': ['Taxi', 'Transport'],
  'uber': ['Taxi', 'Transport'],
  'pickme': ['Taxi', 'Transport'],
  'fuel': ['Fuel', 'Transport'],
  'petrol': ['Fuel', 'Transport'],
  'dialog': ['Phone', 'Bills'],
  'mobitel': ['Phone', 'Bills'],
  'electricity': ['Electricity', 'Bills'],
  'water': ['Water', 'Bills'],
  'salary': ['Salary'],
  'freelance': ['Freelance'],
};
const _merchants = {
  'kfc': 'KFC',
  'keells': 'Keells',
  'cargills': 'Cargills',
  'uber': 'Uber',
  'pickme': 'PickMe',
  'dialog': 'Dialog',
  'mobitel': 'Mobitel',
};

List<String> _words(String s) => RegExp(
  r'[\p{L}\p{N}]+',
  unicode: true,
).allMatches(s).map((m) => m.group(0)!).toList();

QuickParse quickParse(String input, QuickRefs refs, {required int exponent}) {
  final normalized = normalizeText(input).toLowerCase();
  final tokens = _words(normalized);
  final suggested = <String>{};
  final questions = <String>[];

  // Amount: exactly one numeric token, parsed exactly.
  final spaced = normalized
      .replaceAllMapped(RegExp(r'(\d)([a-z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAllMapped(RegExp(r'([a-z])(\d)'), (m) => '${m[1]} ${m[2]}');
  final numeric = spaced
      .split(' ')
      .map((t) => t.replaceAll(RegExp(r'[.,]+$'), ''))
      .where((t) => RegExp(r'^[0-9][0-9.,]*$').hasMatch(t))
      .toList();
  var amountText = '';
  if (numeric.length == 1 &&
      parseAmountToMinor(numeric.single, exponent).isOk) {
    amountText = numeric.single.replaceAll(',', '');
    suggested.add('amount');
  } else {
    questions.add(
      numeric.isEmpty
          ? 'What was the amount?'
          : 'Which amount? Use digits with a "." decimal point.',
    );
  }

  bool has(Set<String> set) => tokens.any(set.contains);
  final transferish = has(_transferWords);
  final incomeish = has(_incomeWords);
  final keyword = tokens.where(_keywordCategories.containsKey).firstOrNull;
  TxType? type;
  if (transferish && !incomeish) {
    type = TxType.transfer;
  } else if (incomeish && !transferish) {
    type = TxType.income;
  } else if (!transferish &&
      !incomeish &&
      (has(_expenseWords) || keyword != null)) {
    type = TxType.expense;
  }
  if (type != null) {
    suggested.add('type');
  } else {
    questions.add(
      tokens.contains('deposit')
          ? 'Is this income or a transfer between your accounts?'
          : 'Expense, income or transfer?',
    );
  }

  // Accounts mentioned by significant name tokens (or "cash" for a single cash account).
  final byToken = <String, Set<String>>{};
  for (final a in refs.accounts) {
    for (final t in _words(
      a.name.toLowerCase(),
    ).where((w) => w.length >= 3 && !_stop.contains(w))) {
      byToken.putIfAbsent(t, () => {}).add(a.id);
    }
  }
  final cash = refs.accounts.where((a) => a.type == 'cash').toList();
  if (cash.length == 1) {
    byToken.putIfAbsent('cash', () => {}).add(cash.single.id);
  }
  final mentions = <({String id, String? prep})>[];
  for (var i = 0; i < tokens.length; i++) {
    final ids = byToken[tokens[i]];
    if (ids == null || ids.length != 1) continue;
    final prev = i > 0 ? tokens[i - 1] : null;
    mentions.add((
      id: ids.single,
      prep: const {'from', 'to', 'into'}.contains(prev) ? prev : null,
    ));
  }
  String? accountId;
  String? destinationId;
  if (type == TxType.transfer) {
    accountId = mentions.where((m) => m.prep == 'from').firstOrNull?.id;
    destinationId = mentions
        .where((m) => m.prep == 'to' || m.prep == 'into')
        .firstOrNull
        ?.id;
    if (has(_withdrawWords)) {
      accountId ??= mentions
          .where((m) => !cash.any((c) => c.id == m.id))
          .firstOrNull
          ?.id;
      if (destinationId == null && cash.length == 1) {
        destinationId = cash.single.id;
      }
    }
    if (accountId != null && accountId == destinationId) destinationId = null;
  } else if (type != null) {
    final distinct = mentions.map((m) => m.id).toSet();
    if (distinct.length == 1) accountId = distinct.single;
  }
  if (accountId != null) suggested.add('accountId');
  if (destinationId != null) suggested.add('destinationAccountId');

  // Category: user rules first, then curated keywords matched by category name.
  String? categoryId;
  final merchantKey = tokens.where(_merchants.containsKey).firstOrNull;
  final merchant = merchantKey == null ? '' : _merchants[merchantKey]!;
  if (type == TxType.expense || type == TxType.income) {
    final typeName = type!.name;
    final matches =
        refs.rules
            .where(
              (r) =>
                  r.type == typeName &&
                  (r.kind == 'merchantExact'
                      ? normalizeMerchant(merchant) == r.pattern ||
                            tokens.join(' ').contains(r.pattern)
                      : tokens.contains(r.pattern)),
            )
            .toList()
          ..sort((a, b) => b.priority.compareTo(a.priority));
    if (matches.isNotEmpty &&
        matches
                .where((r) => r.priority == matches.first.priority)
                .map((r) => r.categoryId)
                .toSet()
                .length ==
            1) {
      categoryId = matches.first.categoryId;
    } else if (keyword != null) {
      for (final name in _keywordCategories[keyword]!) {
        final hits = refs.categories
            .where(
              (c) =>
                  c.type == typeName &&
                  c.name.toLowerCase() == name.toLowerCase(),
            )
            .toList();
        if (hits.length == 1) {
          categoryId = hits.single.id;
          break;
        }
      }
    }
    if (categoryId != null) suggested.add('categoryId');
  }

  String? sourceId;
  if (type == TxType.income) {
    final named = refs.sources
        .where(
          (s) =>
              _words(s.name.toLowerCase())
                  .where((w) => w.length >= 3)
                  .any(tokens.contains),
        )
        .toList();
    if (named.length == 1) sourceId = named.single.id;
    if (sourceId != null) suggested.add('incomeSourceId');
  }

  final dropped = {
    ...numeric,
    ...byToken.keys,
    ?merchantKey,
    'rs',
    'lkr',
    'from',
    'to',
    'into',
  };
  final description = _words(normalized)
      .where((w) => !dropped.contains(w))
      .join(' ');

  return QuickParse(
    TransactionDraft(
      type: type,
      amountText: amountText,
      accountId: accountId,
      destinationAccountId: destinationId,
      categoryId: categoryId,
      incomeSourceId: sourceId,
      merchant: merchant,
      description: description.isEmpty
          ? ''
          : description[0].toUpperCase() + description.substring(1),
      origin: TxOrigin.aiInput,
      categorizationSource: categoryId == null
          ? null
          : CategorizationSource.rule,
    ),
    suggested,
    questions.take(5).toList(),
  );
}
