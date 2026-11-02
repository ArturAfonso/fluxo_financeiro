import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';

final class GetTransactionDetails {
  const GetTransactionDetails(this.repository);

  final FinancialRepository repository;

  Future<Result<TransactionDetails>> call(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return Future.value(
        const FailureResult<TransactionDetails>(
          ValidationFailure(field: 'transactionId'),
        ),
      );
    }
    return repository.getTransactionById(normalizedId);
  }
}
