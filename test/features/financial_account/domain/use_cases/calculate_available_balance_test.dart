import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/calculate_available_balance.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculate = CalculateAvailableBalance();

  test('calcula saldo com valores concluídos e ignora outros status', () {
    final snapshot = LedgerSnapshot(
      openingBalance: const Money.fromCents(10000),
      openingBalanceAt: DateTime.utc(2026, 1, 1),
      asOf: DateTime.utc(2026, 1, 31, 23, 59),
      transactions: [
        _transaction('credit', 5000, TransactionType.credit),
        _transaction('debit', 2300, TransactionType.debit),
        _transaction(
          'pending',
          9000,
          TransactionType.debit,
          status: TransactionStatus.pending,
        ),
        _transaction(
          'failed',
          7000,
          TransactionType.debit,
          status: TransactionStatus.failed,
        ),
        _transaction(
          'reversed',
          4000,
          TransactionType.debit,
          status: TransactionStatus.reversed,
        ),
        _transaction('zero', 0, TransactionType.credit),
      ],
    );

    expect(calculate(snapshot), const Money.fromCents(12700));
  });

  test('mantém precisão com volume grande de transações', () {
    final transactions = List.generate(
      10000,
      (index) => _transaction('tx-$index', 999999, TransactionType.credit),
    );
    final snapshot = LedgerSnapshot(
      openingBalance: Money.zero,
      openingBalanceAt: DateTime.utc(2026, 1, 1),
      asOf: DateTime.utc(2026, 1, 31),
      transactions: transactions,
    );

    expect(calculate(snapshot), const Money.fromCents(9999990000));
  });
}

FinancialTransaction _transaction(
  String id,
  int cents,
  TransactionType type, {
  TransactionStatus status = TransactionStatus.completed,
}) {
  return FinancialTransaction(
    id: id,
    description: id,
    amount: Money.fromCents(cents),
    occurredAt: DateTime.utc(2026, 1, 15),
    type: type,
    status: status,
  );
}
