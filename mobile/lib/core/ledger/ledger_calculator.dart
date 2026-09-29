import 'package:intl/intl.dart';

class LedgerCalculator {
  // Format integer minor units (e.g. 150050 minor -> "LKR 1,500.50")
  static String formatMoney(
    int amountMinor, {
    String currency = 'LKR',
    int exponent = 2,
  }) {
    final isNegative = amountMinor < 0;
    final absAmount = amountMinor.abs();
    final factor = _pow10(exponent);
    final major = absAmount ~/ factor;
    final minor = absAmount % factor;

    final formatter = NumberFormat('#,##0', 'en_US');
    final majorStr = formatter.format(major);
    final minorStr = minor.toString().padLeft(exponent, '0');
    final sign = isNegative ? '-' : '';

    return '$sign$currency $majorStr.$minorStr';
  }

  // Parse decimal text input to integer minor units safely (e.g. "1500.50" -> 150050)
  static int parseDecimalToMinor(String input, {int exponent = 2}) {
    final clean = input.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (clean.isEmpty) return 0;
    final parts = clean.split('.');
    final major = int.tryParse(parts[0]) ?? 0;
    if (parts.length == 1) {
      return major * _pow10(exponent);
    }
    var minorStr = parts[1];
    if (minorStr.length > exponent) {
      minorStr = minorStr.substring(0, exponent);
    } else {
      minorStr = minorStr.padRight(exponent, '0');
    }
    final minor = int.tryParse(minorStr) ?? 0;
    final sign = major < 0 || clean.startsWith('-') ? -1 : 1;
    return (major.abs() * _pow10(exponent) + minor) * sign;
  }

  // Ledger effect of a transaction on account a:
  // effect(t,a) = +m(t) if income and accountId=a
  //               -m(t) if expense and accountId=a
  //               -m(t) if transfer and accountId=a
  //               +m(t) if transfer and destinationAccountId=a
  //               d(t)*m(t) if opening and accountId=a
  //               0 otherwise
  static int calculateTransactionEffect({
    required String accountId,
    required String txAccountId,
    required String? txDestinationAccountId,
    required String type,
    required int amountMinor,
    required String? openingDirection, // 'credit' | 'debit'
  }) {
    if (type == 'income' && txAccountId == accountId) {
      return amountMinor;
    }
    if (type == 'expense' && txAccountId == accountId) {
      return -amountMinor;
    }
    if (type == 'transfer') {
      if (txAccountId == accountId) return -amountMinor;
      if (txDestinationAccountId == accountId) return amountMinor;
    }
    if (type == 'opening' && txAccountId == accountId) {
      final sign = openingDirection == 'debit' ? -1 : 1;
      return sign * amountMinor;
    }
    return 0;
  }

  static int _pow10(int exp) {
    var res = 1;
    for (var i = 0; i < exp; i++) {
      res *= 10;
    }
    return res;
  }
}
