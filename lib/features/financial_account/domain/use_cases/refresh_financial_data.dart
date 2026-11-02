import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';

final class RefreshFinancialData {
  const RefreshFinancialData(this.repository);

  final FinancialRepository repository;

  Future<Result<void>> call() => repository.refresh();
}
