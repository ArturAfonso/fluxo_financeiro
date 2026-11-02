import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/calculate_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';

final class GetAccountSummary {
  const GetAccountSummary({
    required this.repository,
    this.calculateAccountSummary = const CalculateAccountSummary(),
  });

  final FinancialRepository repository;
  final CalculateAccountSummary calculateAccountSummary;

  Future<Result<AccountSummary>> call(UtcDateRange period) async {
    final result = await repository.getLedgerSnapshot();
    return result.map(
      (snapshot) => calculateAccountSummary(snapshot: snapshot, period: period),
    );
  }
}
