import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';

final class GetTransactions {
  const GetTransactions(this.repository);

  final FinancialRepository repository;

  Future<Result<TransactionPage>> call(TransactionQuery query) {
    return repository.getTransactions(query);
  }
}
