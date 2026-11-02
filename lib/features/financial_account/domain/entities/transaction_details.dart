import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';

final class TransactionDetails extends Equatable {
  const TransactionDetails({
    required this.transaction,
    this.lastSynchronizedAt,
    this.isStale = false,
  }) : assert(!isStale || lastSynchronizedAt != null);

  final FinancialTransaction transaction;
  final DateTime? lastSynchronizedAt;
  final bool isStale;

  @override
  List<Object?> get props => [transaction, lastSynchronizedAt, isStale];
}
