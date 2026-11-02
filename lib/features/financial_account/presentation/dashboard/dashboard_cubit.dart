import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DashboardStatus { initial, loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.recentTransactions = const [],
    this.balanceVisible = true,
    this.selectedMonth,
    this.isRefreshing = false,
    this.failure,
  });

  final DashboardStatus status;
  final AccountSummary? summary;
  final List<FinancialTransaction> recentTransactions;
  final bool balanceVisible;
  final DateTime? selectedMonth;
  final bool isRefreshing;
  final Failure? failure;

  DashboardState copyWith({
    DashboardStatus? status,
    AccountSummary? summary,
    List<FinancialTransaction>? recentTransactions,
    bool? balanceVisible,
    DateTime? selectedMonth,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) => DashboardState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    balanceVisible: balanceVisible ?? this.balanceVisible,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    summary,
    recentTransactions,
    balanceVisible,
    selectedMonth,
    isRefreshing,
    failure,
  ];
}

final class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this.getAccountSummary,
    required this.getTransactions,
    required this.refreshFinancialData,
    required this.preferences,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(const DashboardState());

  final GetAccountSummary getAccountSummary;
  final GetTransactions getTransactions;
  final RefreshFinancialData refreshFinancialData;
  final AppPreferences preferences;
  final DateTime Function() clock;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading, clearFailure: true));
    final visible = await preferences.getBalanceVisible();
    final now = state.selectedMonth ?? clock();
    final selectedMonth = DateTime(now.year, now.month);
    final period = UtcDateRange(
      startInclusive: selectedMonth.toUtc(),
      endExclusive: DateTime(now.year, now.month + 1).toUtc(),
    );
    final summaryResult = await getAccountSummary(period);
    final transactionsResult = await getTransactions(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(limit: 5),
      ),
    );
    Failure? failure;
    final summary = summaryResult.fold(
      onSuccess: (value) => value,
      onFailure: (value) {
        failure = value;
        return null;
      },
    );
    final transactions = transactionsResult.fold(
      onSuccess: (value) => value.items,
      onFailure: (value) {
        failure ??= value;
        return <FinancialTransaction>[];
      },
    );
    emit(
      DashboardState(
        status: summary == null
            ? DashboardStatus.failure
            : DashboardStatus.success,
        summary: summary,
        recentTransactions: transactions,
        balanceVisible: visible,
        selectedMonth: selectedMonth,
        failure: failure,
      ),
    );
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true, clearFailure: true));
    final result = await refreshFinancialData(replaceInFlight: true);
    final failure = result.fold<Failure?>(
      onSuccess: (_) => null,
      onFailure: (value) => value,
    );
    if (failure != null) {
      if (failure is RequestCancelledFailure) {
        emit(state.copyWith(isRefreshing: false));
        return;
      }
      emit(state.copyWith(isRefreshing: false, failure: failure));
      return;
    }
    await load();
  }

  Future<void> toggleBalanceVisibility() async {
    final visible = !state.balanceVisible;
    emit(state.copyWith(balanceVisible: visible));
    await preferences.setBalanceVisible(visible);
  }

  Future<void> changeMonth(int offset) async {
    final selected = state.selectedMonth ?? clock();
    final target = DateTime(selected.year, selected.month + offset);
    final current = clock();
    final currentMonth = DateTime(current.year, current.month);
    if (target.isAfter(currentMonth)) return;
    emit(state.copyWith(selectedMonth: target));
    await load();
  }
}
