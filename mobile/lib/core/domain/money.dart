import 'result.dart';

/// Integer minor-unit money (docs/02 "Value and serialization conventions").
/// Parsing uses string arithmetic; floating point is never used for amounts.
const int maxAmountMinor = 1000000000000;
const int maxSafeInteger = 9007199254740991;

final RegExp _decimal = RegExp(
  r'^([0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)(?:\.([0-9]+))?$',
);
final RegExp _ambiguousComma = RegExp(r'^[0-9]+,[0-9]{1,2}$');
final RegExp _europeanThousands = RegExp(
  r'^[0-9]{1,3}(\.[0-9]{3})+(,[0-9]+)?$',
);

/// Parses user text such as "2,500.50" into minor units. Rejects excess
/// precision, ambiguous separators, signs, exponents and out-of-range values.
Result<int> parseAmountToMinor(
  String text,
  int exponent, {
  bool allowZero = false,
}) {
  final s = text.trim();
  if (s.isEmpty) {
    return Err(AppError.validation({'amount': 'Enter an amount.'}));
  }
  final m = _decimal.firstMatch(s);
  if (m == null) {
    if (_ambiguousComma.hasMatch(s) || _europeanThousands.hasMatch(s)) {
      return Err(
        AppError.validation({'amount': 'Use "." for decimals, e.g. 2500.50.'}),
      );
    }
    return Err(
      AppError.validation({'amount': 'Enter digits only, e.g. 2500.50.'}),
    );
  }
  final whole = m.group(1)!.replaceAll(',', '');
  final frac = m.group(2) ?? '';
  if (frac.length > exponent) {
    return Err(
      AppError.validation({'amount': 'At most $exponent decimal places.'}),
    );
  }
  final digits = (whole + frac.padRight(exponent, '0')).replaceFirst(
    RegExp(r'^0+(?=[0-9])'),
    '',
  );
  if (digits.length > 16) {
    return Err(AppError.validation({'amount': 'Amount is too large.'}));
  }
  final minor = int.parse(digits);
  if (minor > maxAmountMinor) {
    return Err(AppError.validation({'amount': 'Amount is too large.'}));
  }
  if (minor == 0 && !allowZero) {
    return Err(
      AppError.validation({'amount': 'Amount must be greater than zero.'}),
    );
  }
  return Ok(minor);
}

/// Signed opening balance input: optional leading "-" then an amount (zero allowed).
Result<int> parseSignedOpeningMinor(String text, int exponent) {
  final s = text.trim();
  final negative = s.startsWith('-');
  final r = parseAmountToMinor(
    negative ? s.substring(1) : s,
    exponent,
    allowZero: true,
  );
  return switch (r) {
    Ok(:final value) => Ok(negative ? -value : value),
    Err(:final error) => Err(error),
  };
}

/// Formats minor units without floating point, e.g. 150050 → "LKR 1,500.50".
String formatMinor(
  int minor, {
  required String currency,
  required int exponent,
  bool showCurrency = true,
}) {
  final negative = minor < 0;
  final abs = minor.abs().toString().padLeft(exponent + 1, '0');
  final wholeDigits = abs.substring(0, abs.length - exponent);
  final buffer = StringBuffer();
  for (var i = 0; i < wholeDigits.length; i++) {
    if (i > 0 && (wholeDigits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(wholeDigits[i]);
  }
  final frac = exponent > 0 ? '.${abs.substring(abs.length - exponent)}' : '';
  final body = '$buffer$frac';
  final sign = negative ? '-' : '';
  return showCurrency ? '$sign$currency $body' : '$sign$body';
}

/// Minor units → plain editable text, e.g. 250000 → "2500.00".
String minorToInput(int minor, int exponent) => formatMinor(
  minor,
  currency: '',
  exponent: exponent,
  showCurrency: false,
).replaceAll(',', '');

/// Sum with an explicit safe-integer bound (balances must stay within ±2^53-1).
Result<int> checkedSum(Iterable<int> values) {
  var total = BigInt.zero;
  for (final v in values) {
    total += BigInt.from(v);
  }
  if (total > BigInt.from(maxSafeInteger) ||
      total < BigInt.from(-maxSafeInteger)) {
    return const Err(
      AppError(ErrorKind.overflow, 'Balance is outside the supported range.'),
    );
  }
  return Ok(total.toInt());
}
