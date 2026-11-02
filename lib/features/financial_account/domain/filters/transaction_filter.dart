import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';

final class TransactionFilter extends Equatable {
  TransactionFilter({
    Set<TransactionType> types = const {},
    Set<TransactionStatus> statuses = const {},
    this.period,
    String descriptionQuery = '',
  }) : types = UnmodifiableSetView(Set.of(types)),
       statuses = UnmodifiableSetView(Set.of(statuses)),
       descriptionQuery = descriptionQuery.trim();

  final Set<TransactionType> types;
  final Set<TransactionStatus> statuses;
  final UtcDateRange? period;
  final String descriptionQuery;

  bool get isEmpty =>
      types.isEmpty &&
      statuses.isEmpty &&
      period == null &&
      descriptionQuery.isEmpty;

  @override
  List<Object?> get props => [
    (types.toList()..sort((left, right) => left.index.compareTo(right.index))),
    (statuses.toList()
      ..sort((left, right) => left.index.compareTo(right.index))),
    period,
    descriptionQuery,
  ];
}

final class TransactionPageRequest extends Equatable {
  TransactionPageRequest({this.cursor, this.limit = 20}) {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    if (cursor != null && cursor!.trim().isEmpty) {
      throw ArgumentError.value(cursor, 'cursor', 'Must not be blank.');
    }
  }

  final String? cursor;
  final int limit;

  @override
  List<Object?> get props => [cursor, limit];
}

final class TransactionQuery extends Equatable {
  const TransactionQuery({required this.filter, required this.page});

  final TransactionFilter filter;
  final TransactionPageRequest page;

  @override
  List<Object?> get props => [filter, page];
}
