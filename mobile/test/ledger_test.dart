import 'package:flutter_test/flutter_test.dart';
import '../lib/core/ledger/ledger_calculator.dart';

void main() {
  group('LedgerCalculator Invariants', () {
    test('formats integer minor units accurately without floating point rounding error', () {
      expect(LedgerCalculator.formatMoney(150050, currency: 'LKR', exponent: 2), 'LKR 1,500.50');
      expect(LedgerCalculator.formatMoney(0, currency: 'LKR', exponent: 2), 'LKR 0.00');
      expect(LedgerCalculator.formatMoney(-45000, currency: 'LKR', exponent: 2), '-LKR 450.00');
      expect(LedgerCalculator.formatMoney(100000000, currency: 'USD', exponent: 2), 'USD 1,000,000.00');
    });

    test('parses decimal text strings accurately to integer minor units', () {
      expect(LedgerCalculator.parseDecimalToMinor('1500.50', exponent: 2), 150050);
      expect(LedgerCalculator.parseDecimalToMinor('250', exponent: 2), 25000);
      expect(LedgerCalculator.parseDecimalToMinor('0.05', exponent: 2), 5);
      expect(LedgerCalculator.parseDecimalToMinor('-45.20', exponent: 2), -4520);
    });

    test('calculates transaction effects correctly per data model rules', () {
      const bankAcc = 'acc-bank';
      const cashAcc = 'acc-cash';

      // 1. Income effect
      final incomeEffect = LedgerCalculator.calculateTransactionEffect(
        accountId: bankAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: null,
        type: 'income',
        amountMinor: 20000000, // LKR 200,000.00
        openingDirection: null,
      );
      expect(incomeEffect, 20000000);

      // 2. Expense effect
      final expenseEffect = LedgerCalculator.calculateTransactionEffect(
        accountId: bankAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: null,
        type: 'expense',
        amountMinor: 450000, // LKR 4,500.00
        openingDirection: null,
      );
      expect(expenseEffect, -450000);

      // 3. Transfer effect: source loses, destination gains; sum equals 0
      final transferSourceEffect = LedgerCalculator.calculateTransactionEffect(
        accountId: bankAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: cashAcc,
        type: 'transfer',
        amountMinor: 1000000, // LKR 10,000.00
        openingDirection: null,
      );
      final transferDestEffect = LedgerCalculator.calculateTransactionEffect(
        accountId: cashAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: cashAcc,
        type: 'transfer',
        amountMinor: 1000000,
        openingDirection: null,
      );

      expect(transferSourceEffect, -1000000);
      expect(transferDestEffect, 1000000);
      expect(transferSourceEffect + transferDestEffect, 0); // Invariant: Transfers have sum(effect) = 0

      // 4. Opening balances
      final creditOpening = LedgerCalculator.calculateTransactionEffect(
        accountId: bankAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: null,
        type: 'opening',
        amountMinor: 5000000,
        openingDirection: 'credit',
      );
      expect(creditOpening, 5000000);

      final debitOpening = LedgerCalculator.calculateTransactionEffect(
        accountId: bankAcc,
        txAccountId: bankAcc,
        txDestinationAccountId: null,
        type: 'opening',
        amountMinor: 1000000,
        openingDirection: 'debit',
      );
      expect(debitOpening, -1000000);
    });
  });
}
