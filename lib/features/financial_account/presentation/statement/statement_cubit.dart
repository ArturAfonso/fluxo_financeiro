import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum StatementStatus { initial, loading, success, failure }

final class StatementState extends Equatable {
  const StatementState({
    this.status = StatementStatus.initial,
    this.items = const [],
    this.filter,
    this.nextCursor,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.failure,
  });

  final StatementStatus status;
  final List<FinancialTransaction> items;
  final TransactionFilter? filter;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool isRefreshing;
  final Failure? failure;
  bool get hasNextPage => nextCursor != null;

  @override
  List<Object?> get props => [
    status,
    items,
    filter,
    nextCursor,
    isLoadingMore,
    isRefreshing,
    failure,
  ];
}

final class StatementCubit extends Cubit<StatementState> {
  StatementCubit({
    required this.getTransactions,
    required this.refreshFinancialData,
  }) : super(StatementState(filter: TransactionFilter()));

  final GetTransactions getTransactions;
  final RefreshFinancialData refreshFinancialData;
  Timer? _debounce;
  int _requestVersion = 0;

  Future<void> load({bool reset = true}) async {
    final requestVersion = reset ? ++_requestVersion : _requestVersion;
    if (reset) {
      emit(
        StatementState(status: StatementStatus.loading, filter: state.filter),
      );
    } else {
      if (!state.hasNextPage || state.isLoadingMore) return;
      emit(_copy(isLoadingMore: true, clearFailure: true));
    }
    final result = await getTransactions(
      TransactionQuery(
        filter: state.filter ?? TransactionFilter(),
        page: TransactionPageRequest(
          cursor: reset ? null : state.nextCursor,
          limit: 20,
        ),
      ),
    );
    if (requestVersion != _requestVersion || isClosed) return;
    result.fold(
      onSuccess: (page) => emit(
        StatementState(
          status: StatementStatus.success,
          filter: state.filter,
          items: reset ? page.items : [...state.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      ),
      onFailure: (failure) => emit(
        StatementState(
          status: reset ? StatementStatus.failure : StatementStatus.success,
          filter: state.filter,
          items: state.items,
          nextCursor: state.nextCursor,
          failure: failure,
        ),
      ),
    );
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _setFilter(descriptionQuery: query);
    });
  }

  void setTypes(Set<TransactionType> types) => _setFilter(types: types);
  void setStatuses(Set<TransactionStatus> statuses) =>
      _setFilter(statuses: statuses);
  void setPeriod(UtcDateRange? period) =>
      _setFilter(period: period, replacePeriod: true);

  void setFilters({
    required Set<TransactionType> types,
    required Set<TransactionStatus> statuses,
    required UtcDateRange? period,
  }) {
    final current = state.filter ?? TransactionFilter();
    emit(
      StatementState(
        filter: TransactionFilter(
          types: types,
          statuses: statuses,
          period: period,
          descriptionQuery: current.descriptionQuery,
        ),
      ),
    );
    load();
  }

  void clearFilters() {
    _debounce?.cancel();
    emit(StatementState(filter: TransactionFilter()));
    load();
  }

  Future<void> refresh() async {
    emit(_copy(isRefreshing: true, clearFailure: true));
    final result = await refreshFinancialData();
    final failed = result.fold(onSuccess: (_) => false, onFailure: (_) => true);
    if (failed) {
      final failure = result.fold<Failure?>(
        onSuccess: (_) => null,
        onFailure: (value) => value,
      );
      emit(_copy(isRefreshing: false, failure: failure));
      return;
    }
    await load();
  }

  void _setFilter({
    Set<TransactionType>? types,
    Set<TransactionStatus>? statuses,
    UtcDateRange? period,
    bool replacePeriod = false,
    String? descriptionQuery,
  }) {
    final current = state.filter ?? TransactionFilter();
    emit(
      StatementState(
        filter: TransactionFilter(
          types: types ?? current.types,
          statuses: statuses ?? current.statuses,
          period: replacePeriod ? period : current.period,
          descriptionQuery: descriptionQuery ?? current.descriptionQuery,
        ),
      ),
    );
    load();
  }

  StatementState _copy({
    bool? isLoadingMore,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) => StatementState(
    status: state.status,
    items: state.items,
    filter: state.filter,
    nextCursor: state.nextCursor,
    isLoadingMore: isLoadingMore ?? state.isLoadingMore,
    isRefreshing: isRefreshing ?? state.isRefreshing,
    failure: clearFailure ? null : failure ?? state.failure,
  );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
