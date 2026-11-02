import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/calculate_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculate = CalculateAccountSummary();

  test('calcula entradas e saídas concluídas dentro do período', () {
    final period = UtcDateRange(
      startInclusive: DateTime.utc(2026, 1, 10),
      endExclusive: DateTime.utc(2026, 1, 20),
    );
    final snapshot = LedgerSnapshot(
      openingBalance: const Money.fromCents(1000),
      openingBalanceAt: DateTime.utc(2026, 1, 1),
      asOf: DateTime.utc(2026, 1, 31),
      transactions: [
        _transaction('credit', 500, DateTime.utc(2026, 1, 10)),
        _transaction(
          'debit',
          200,
          DateTime.utc(2026, 1, 19, 23, 59),
          type: TransactionType.debit,
        ),
        _transaction('outside', 900, DateTime.utc(2026, 1, 20)),
        _transaction(
          'reversed',
          800,
          DateTime.utc(2026, 1, 15),
          status: TransactionStatus.reversed,
        ),
      ],
    );

    final summary = calculate(snapshot: snapshot, period: period);

    expect(summary.totalCredits, const Money.fromCents(500));
    expect(summary.totalDebits, const Money.fromCents(200));
    expect(summary.netChange, const Money.fromCents(300));
    expect(summary.availableBalance, const Money.fromCents(2200));
  });

  test('respeita virada do dia convertida do fuso local para UTC', () {
    // Em Fortaleza (UTC-03), este período representa 01/01 inteiro no fuso
    // local: [01/01 03:00Z, 02/01 03:00Z).
    final localDayInUtc = UtcDateRange(
      startInclusive: DateTime.utc(2026, 1, 1, 3),
      endExclusive: DateTime.utc(2026, 1, 2, 3),
    );
    final snapshot = LedgerSnapshot(
      openingBalance: Money.zero,
      openingBalanceAt: DateTime.utc(2026, 1, 1),
      asOf: DateTime.utc(2026, 1, 3),
      transactions: [
        _transaction('before', 100, DateTime.utc(2026, 1, 1, 2, 59)),
        _transaction('start', 200, DateTime.utc(2026, 1, 1, 3)),
        _transaction('last', 300, DateTime.utc(2026, 1, 2, 2, 59)),
        _transaction('end', 400, DateTime.utc(2026, 1, 2, 3)),
      ],
    );

    final summary = calculate(snapshot: snapshot, period: localDayInUtc);

    expect(summary.totalCredits, const Money.fromCents(500));
  });
}

FinancialTransaction _transaction(
  String id,
  int cents,
  DateTime occurredAt, {
  TransactionType type = TransactionType.credit,
  TransactionStatus status = TransactionStatus.completed,
}) {
  return FinancialTransaction(
    id: id,
    description: id,
    amount: Money.fromCents(cents),
    occurredAt: occurredAt,
    type: type,
    status: status,
  );
}
