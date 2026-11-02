import 'package:fluxo_financeiro/features/financial_account/domain/entities/account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/calculate_available_balance.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';

final class CalculateAccountSummary {
  const CalculateAccountSummary({
    this.calculateAvailableBalance = const CalculateAvailableBalance(),
  });

  final CalculateAvailableBalance calculateAvailableBalance;

  AccountSummary call({
    required LedgerSnapshot snapshot,
    required UtcDateRange period,
  }) {
    var totalCredits = Money.zero;
    var totalDebits = Money.zero;
    final cutoff = snapshot.asOf.isBefore(period.endExclusive)
        ? snapshot.asOf
        : period.endExclusive;
    final elapsed = cutoff.difference(period.startInclusive);
    final completeDays = elapsed.inDays;
    final hasPartialDay = cutoff.isAfter(
      period.startInclusive.add(Duration(days: completeDays)),
    );
    final dayCount = (completeDays + (hasPartialDay ? 1 : 0)).clamp(1, 366);
    final creditCentsByDay = List<int>.filled(dayCount, 0);
    final debitCentsByDay = List<int>.filled(dayCount, 0);

    for (final transaction in snapshot.transactions) {
      if (!transaction.affectsBalance ||
          !period.contains(transaction.occurredAt)) {
        continue;
      }

      switch (transaction.type) {
        case TransactionType.credit:
          totalCredits += transaction.amount;
        case TransactionType.debit:
          totalDebits += transaction.amount;
      }

      final dayIndex = transaction.occurredAt
          .difference(period.startInclusive)
          .inDays;
      if (dayIndex < 0 || dayIndex >= dayCount) continue;
      switch (transaction.type) {
        case TransactionType.credit:
          creditCentsByDay[dayIndex] += transaction.amount.cents;
        case TransactionType.debit:
          debitCentsByDay[dayIndex] += transaction.amount.cents;
      }
    }

    final dailyCashFlow = List<DailyCashFlow>.generate(
      dayCount,
      (index) => DailyCashFlow(
        dayStart: period.startInclusive.add(Duration(days: index)),
        credits: Money.fromCents(creditCentsByDay[index]),
        debits: Money.fromCents(debitCentsByDay[index]),
      ),
      growable: false,
    );

    return AccountSummary(
      availableBalance: calculateAvailableBalance(snapshot),
      totalCredits: totalCredits,
      totalDebits: totalDebits,
      period: period,
      calculatedAt: snapshot.asOf,
      dailyCashFlow: dailyCashFlow,
      isStale: snapshot.isStale,
      lastSynchronizedAt: snapshot.lastSynchronizedAt,
    );
  }
}
