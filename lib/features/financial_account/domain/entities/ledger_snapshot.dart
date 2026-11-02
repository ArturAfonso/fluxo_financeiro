import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';

final class LedgerSnapshot extends Equatable {
  LedgerSnapshot({
    required this.openingBalance,
    required this.openingBalanceAt,
    required this.asOf,
    required List<FinancialTransaction> transactions,
    this.lastSynchronizedAt,
    this.isStale = false,
  }) : transactions = UnmodifiableListView(List.of(transactions)) {
    if (!openingBalanceAt.isUtc) {
      throw ArgumentError.value(
        openingBalanceAt,
        'openingBalanceAt',
        'Must use UTC.',
      );
    }
    if (!asOf.isUtc) {
      throw ArgumentError.value(asOf, 'asOf', 'Must use UTC.');
    }
    if (openingBalanceAt.isAfter(asOf)) {
      throw ArgumentError.value(
        openingBalanceAt,
        'openingBalanceAt',
        'Must not be after asOf.',
      );
    }
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
        'A stale snapshot must include its synchronization instant.',
      );
    }
    for (final transaction in this.transactions) {
      if (transaction.occurredAt.isBefore(openingBalanceAt) ||
          transaction.occurredAt.isAfter(asOf)) {
        throw ArgumentError.value(
          transaction,
          'transactions',
          'Every transaction must be within the snapshot interval.',
        );
      }
    }
  }

  final Money openingBalance;
  final DateTime openingBalanceAt;
  final DateTime asOf;
  final List<FinancialTransaction> transactions;
  final DateTime? lastSynchronizedAt;
  final bool isStale;

  LedgerSnapshot withFreshness({
    required DateTime lastSynchronizedAt,
    required bool isStale,
  }) => LedgerSnapshot(
    openingBalance: openingBalance,
    openingBalanceAt: openingBalanceAt,
    asOf: asOf,
    transactions: transactions,
    lastSynchronizedAt: lastSynchronizedAt,
    isStale: isStale,
  );

  @override
  List<Object?> get props => [
    openingBalance,
    openingBalanceAt,
    asOf,
    transactions,
    lastSynchronizedAt,
    isStale,
  ];
}
