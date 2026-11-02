import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';

final class DailyCashFlow extends Equatable {
  DailyCashFlow({
    required this.dayStart,
    required this.credits,
    required this.debits,
  }) {
    if (!dayStart.isUtc) {
      throw ArgumentError.value(dayStart, 'dayStart', 'Must use UTC.');
    }
  }

  final DateTime dayStart;
  final Money credits;
  final Money debits;

  @override
  List<Object?> get props => [dayStart, credits, debits];
}

final class AccountSummary extends Equatable {
  AccountSummary({
    required this.availableBalance,
    required this.totalCredits,
    required this.totalDebits,
    required this.period,
    required this.calculatedAt,
    required List<DailyCashFlow> dailyCashFlow,
    required this.isStale,
    required this.lastSynchronizedAt,
  }) : dailyCashFlow = UnmodifiableListView(List.of(dailyCashFlow)) {
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
        'A stale summary must include its synchronization instant.',
      );
    }
  }

  final Money availableBalance;
  final Money totalCredits;
  final Money totalDebits;
  final UtcDateRange period;
  final DateTime calculatedAt;
  final List<DailyCashFlow> dailyCashFlow;
  final bool isStale;
  final DateTime? lastSynchronizedAt;

  Money get netChange => totalCredits - totalDebits;

  @override
  List<Object?> get props => [
    availableBalance,
    totalCredits,
    totalDebits,
    period,
    calculatedAt,
    dailyCashFlow,
    isStale,
    lastSynchronizedAt,
  ];
}
