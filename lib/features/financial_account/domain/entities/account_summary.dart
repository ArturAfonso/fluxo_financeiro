import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';

final class AccountSummary extends Equatable {
  const AccountSummary({
    required this.availableBalance,
    required this.totalCredits,
    required this.totalDebits,
    required this.period,
    required this.calculatedAt,
  });

  final Money availableBalance;
  final Money totalCredits;
  final Money totalDebits;
  final UtcDateRange period;
  final DateTime calculatedAt;

  Money get netChange => totalCredits - totalDebits;

  @override
  List<Object?> get props => [
    availableBalance,
    totalCredits,
    totalDebits,
    period,
    calculatedAt,
  ];
}
