import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';

final class TransactionPage extends Equatable {
  TransactionPage({required List<FinancialTransaction> items, this.nextCursor})
    : items = UnmodifiableListView(List.of(items));

  final List<FinancialTransaction> items;
  final String? nextCursor;

  bool get hasNextPage => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor];
}
