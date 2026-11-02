import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';

final class TransactionPage extends Equatable {
  TransactionPage({
    required List<FinancialTransaction> items,
    this.nextCursor,
    this.lastSynchronizedAt,
    this.isStale = false,
  }) : items = UnmodifiableListView(List.of(items)) {
    if (lastSynchronizedAt != null && !lastSynchronizedAt!.isUtc) {
      throw ArgumentError.value(
        lastSynchronizedAt,
        'lastSynchronizedAt',
        'Must use UTC.',
      );
    }
    if (isStale && lastSynchronizedAt == null) {
      throw ArgumentError.value(
        isStale,
        'isStale',
        'A stale page must include its synchronization instant.',
      );
    }
  }

  final List<FinancialTransaction> items;
  final String? nextCursor;
  final DateTime? lastSynchronizedAt;
  final bool isStale;

  bool get hasNextPage => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor, lastSynchronizedAt, isStale];
}
