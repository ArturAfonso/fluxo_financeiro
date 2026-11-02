import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';

abstract interface class FinancialRepository {
  Future<Result<LedgerSnapshot>> getLedgerSnapshot();

  Future<Result<TransactionPage>> getTransactions(TransactionQuery query);

  Future<Result<TransactionDetails>> getTransactionById(String id);

  Future<Result<void>> refresh({bool replaceInFlight = false});
}
