import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final class _MockFinancialRepository extends Mock
    implements FinancialRepository {}

final class _MemoryPreferences implements AppPreferences {
  bool balanceVisible = true;
  ThemeMode themeMode = ThemeMode.light;

  @override
  Future<bool> getBalanceVisible() async => balanceVisible;

  @override
  Future<ThemeMode> getThemeMode() async => themeMode;

  @override
  Future<void> setBalanceVisible(bool visible) async {
    balanceVisible = visible;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
  }
}

void main() {
  late _MockFinancialRepository repository;

  setUpAll(() {
    registerFallbackValue(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );
  });

  setUp(() {
    repository = _MockFinancialRepository();
  });

  test(
    'DashboardCubit carrega resumo, recentes e preferência de saldo',
    () async {
      final preferences = _MemoryPreferences()..balanceVisible = false;
      when(repository.getLedgerSnapshot).thenAnswer(
        (_) async => Success(
          _snapshot.withFreshness(
            lastSynchronizedAt: DateTime.utc(2026, 11, 1, 9),
            isStale: true,
          ),
        ),
      );
      when(() => repository.getTransactions(any())).thenAnswer(
        (_) async => Success(TransactionPage(items: [_transaction])),
      );

      final cubit = DashboardCubit(
        getAccountSummary: GetAccountSummary(repository: repository),
        getTransactions: GetTransactions(repository),
        refreshFinancialData: RefreshFinancialData(repository),
        preferences: preferences,
        clock: () => DateTime(2026, 11),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, DashboardStatus.success);
      expect(cubit.state.summary, isNotNull);
      expect(cubit.state.summary?.isStale, isTrue);
      expect(cubit.state.recentTransactions, [_transaction]);
      expect(cubit.state.balanceVisible, isFalse);

      await cubit.toggleBalanceVisibility();
      expect(preferences.balanceVisible, isTrue);
    },
  );

  test('DashboardCubit mantém conteúdo quando refresh falha', () async {
    when(
      repository.getLedgerSnapshot,
    ).thenAnswer((_) async => Success(_snapshot));
    when(
      () => repository.getTransactions(any()),
    ).thenAnswer((_) async => Success(TransactionPage(items: [_transaction])));
    when(
      () => repository.refresh(replaceInFlight: any(named: 'replaceInFlight')),
    ).thenAnswer((_) async => const FailureResult(OfflineFailure()));
    final cubit = DashboardCubit(
      getAccountSummary: GetAccountSummary(repository: repository),
      getTransactions: GetTransactions(repository),
      refreshFinancialData: RefreshFinancialData(repository),
      preferences: _MemoryPreferences(),
      clock: () => DateTime(2026, 11),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.refresh();

    expect(cubit.state.status, DashboardStatus.success);
    expect(cubit.state.summary, isNotNull);
    expect(cubit.state.failure, const OfflineFailure());
  });

  test(
    'StatementCubit pagina e combina filtros em uma única consulta',
    () async {
      when(() => repository.getTransactions(any())).thenAnswer((
        invocation,
      ) async {
        final query = invocation.positionalArguments.single as TransactionQuery;
        return Success(
          TransactionPage(
            items: [_transaction],
            nextCursor: query.page.cursor == null ? 'next' : null,
            lastSynchronizedAt: DateTime.utc(2026, 11, 1, 9),
            isStale: true,
          ),
        );
      });
      final cubit = StatementCubit(
        getTransactions: GetTransactions(repository),
        refreshFinancialData: RefreshFinancialData(repository),
      );
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.load(reset: false);
      cubit.setFilters(
        types: const {TransactionType.credit},
        statuses: const {TransactionStatus.completed},
        period: null,
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, StatementStatus.success);
      expect(cubit.state.filter?.types, const {TransactionType.credit});
      expect(cubit.state.filter?.statuses, const {TransactionStatus.completed});
      expect(cubit.state.isStale, isTrue);
      expect(cubit.state.lastSynchronizedAt, DateTime.utc(2026, 11, 1, 9));
      verify(() => repository.getTransactions(any())).called(3);
    },
  );

  test(
    'TransactionDetailsCubit expõe falha tipada de item inexistente',
    () async {
      when(() => repository.getTransactionById('missing')).thenAnswer(
        (_) async => const FailureResult(
          NotFoundFailure(resource: 'transaction', identifier: 'missing'),
        ),
      );
      final cubit = TransactionDetailsCubit(
        transactionId: 'missing',
        getTransactionDetails: GetTransactionDetails(repository),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, TransactionDetailsStatus.failure);
      expect(cubit.state.failure, isA<NotFoundFailure>());
    },
  );
}

final _transaction = FinancialTransaction(
  id: 'tx-1',
  description: 'Transferência recebida',
  amount: const Money.fromCents(50000),
  occurredAt: DateTime.utc(2026, 11, 1, 10),
  type: TransactionType.credit,
  status: TransactionStatus.completed,
);

final _snapshot = LedgerSnapshot(
  openingBalance: const Money.fromCents(100000),
  openingBalanceAt: DateTime.utc(2026, 10, 1),
  asOf: DateTime.utc(2026, 11, 1, 12),
  transactions: [_transaction],
);
