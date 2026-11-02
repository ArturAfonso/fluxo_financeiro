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
    }

    return AccountSummary(
      availableBalance: calculateAvailableBalance(snapshot),
      totalCredits: totalCredits,
      totalDebits: totalDebits,
      period: period,
      calculatedAt: snapshot.asOf,
    );
  }
}
