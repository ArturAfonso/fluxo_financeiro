import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transaction_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TransactionDetailsStatus { initial, loading, success, failure }

final class TransactionDetailsState extends Equatable {
  const TransactionDetailsState({
    this.status = TransactionDetailsStatus.initial,
    this.transaction,
    this.isStale = false,
    this.lastSynchronizedAt,
    this.failure,
  });
  final TransactionDetailsStatus status;
  final FinancialTransaction? transaction;
  final bool isStale;
  final DateTime? lastSynchronizedAt;
  final Failure? failure;

  @override
  List<Object?> get props => [
    status,
    transaction,
    isStale,
    lastSynchronizedAt,
    failure,
  ];
}

final class TransactionDetailsCubit extends Cubit<TransactionDetailsState> {
  TransactionDetailsCubit({
    required this.transactionId,
    required this.getTransactionDetails,
  }) : super(const TransactionDetailsState());

  final String transactionId;
  final GetTransactionDetails getTransactionDetails;

  Future<void> load() async {
    emit(
      const TransactionDetailsState(status: TransactionDetailsStatus.loading),
    );
    final result = await getTransactionDetails(transactionId);
    result.fold(
      onSuccess: (details) => emit(
        TransactionDetailsState(
          status: TransactionDetailsStatus.success,
          transaction: details.transaction,
          isStale: details.isStale,
          lastSynchronizedAt: details.lastSynchronizedAt,
        ),
      ),
      onFailure: (failure) => emit(
        TransactionDetailsState(
          status: TransactionDetailsStatus.failure,
          failure: failure,
        ),
      ),
    );
  }
}
