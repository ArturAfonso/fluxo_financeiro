import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

final class CalculateAvailableBalance {
  const CalculateAvailableBalance();

  Money call(LedgerSnapshot snapshot) {
    return snapshot.transactions
        .where((transaction) => transaction.affectsBalance)
        .fold(
          snapshot.openingBalance,
          (balance, transaction) => balance + transaction.signedAmount,
        );
  }
}
