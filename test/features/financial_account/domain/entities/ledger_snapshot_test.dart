import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LedgerSnapshot', () {
    test('protege a lista de transações contra alteração', () {
      final source = [_transactionAt(DateTime.utc(2026, 1, 2))];
      final snapshot = LedgerSnapshot(
        openingBalance: Money.zero,
        openingBalanceAt: DateTime.utc(2026, 1, 1),
        asOf: DateTime.utc(2026, 1, 3),
        transactions: source,
      );

      source.clear();

      expect(snapshot.transactions, hasLength(1));
      expect(() => snapshot.transactions.clear(), throwsUnsupportedError);
    });

    test('rejeita instantes locais e abertura posterior ao snapshot', () {
      expect(
        () => LedgerSnapshot(
          openingBalance: Money.zero,
          openingBalanceAt: DateTime(2026, 1, 1),
          asOf: DateTime.utc(2026, 1, 3),
          transactions: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => LedgerSnapshot(
          openingBalance: Money.zero,
          openingBalanceAt: DateTime.utc(2026, 1, 1),
          asOf: DateTime(2026, 1, 3),
          transactions: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => LedgerSnapshot(
          openingBalance: Money.zero,
          openingBalanceAt: DateTime.utc(2026, 1, 4),
          asOf: DateTime.utc(2026, 1, 3),
          transactions: const [],
        ),
        throwsArgumentError,
      );
    });

    test('rejeita transação fora do intervalo atômico', () {
      expect(
        () => LedgerSnapshot(
          openingBalance: Money.zero,
          openingBalanceAt: DateTime.utc(2026, 1, 2),
          asOf: DateTime.utc(2026, 1, 3),
          transactions: [_transactionAt(DateTime.utc(2026, 1, 1))],
        ),
        throwsArgumentError,
      );
      expect(
        () => LedgerSnapshot(
          openingBalance: Money.zero,
          openingBalanceAt: DateTime.utc(2026, 1, 2),
          asOf: DateTime.utc(2026, 1, 3),
          transactions: [_transactionAt(DateTime.utc(2026, 1, 4))],
        ),
        throwsArgumentError,
      );
    });
  });
}

FinancialTransaction _transactionAt(DateTime occurredAt) {
  return FinancialTransaction(
    id: occurredAt.toIso8601String(),
    description: 'Transação',
    amount: const Money.fromCents(100),
    occurredAt: occurredAt,
    type: TransactionType.credit,
    status: TransactionStatus.completed,
  );
}
