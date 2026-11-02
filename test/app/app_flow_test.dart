import 'package:fluxo_financeiro/app/app.dart';
import 'package:fluxo_financeiro/app/di/injection.dart';
import 'package:fluxo_financeiro/app/router/app_router.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
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
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

final class _MockRepository extends Mock implements FinancialRepository {}

final class _Preferences implements AppPreferences {
  @override
  Future<bool> getBalanceVisible() async => true;

  @override
  Future<ThemeMode> getThemeMode() async => ThemeMode.light;

  @override
  Future<void> setBalanceVisible(bool visible) async {}

  @override
  Future<void> setThemeMode(ThemeMode mode) async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    registerFallbackValue(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );
  });

  testWidgets(
    'fluxo principal navega do dashboard ao extrato e preserva busca ao voltar',
    (tester) async {
      final repository = _MockRepository();
      when(
        repository.getLedgerSnapshot,
      ).thenAnswer((_) async => Success(_snapshot));
      when(() => repository.getTransactions(any())).thenAnswer((
        invocation,
      ) async {
        final query = invocation.positionalArguments.single as TransactionQuery;
        final items =
            query.filter.descriptionQuery.isEmpty ||
                _transaction.description.toLowerCase().contains(
                  query.filter.descriptionQuery.toLowerCase(),
                )
            ? [_transaction]
            : <FinancialTransaction>[];
        return Success(TransactionPage(items: items));
      });
      when(
        () => repository.getTransactionById(_transaction.id),
      ).thenAnswer((_) async => Success(_transaction));
      when(repository.refresh).thenAnswer((_) async => const Success(null));

      final preferences = _Preferences();
      getIt
        ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(preferences))
        ..registerFactory<DashboardCubit>(
          () => DashboardCubit(
            getAccountSummary: GetAccountSummary(repository: repository),
            getTransactions: GetTransactions(repository),
            refreshFinancialData: RefreshFinancialData(repository),
            preferences: preferences,
            clock: () => DateTime(2026, 11),
          ),
        )
        ..registerLazySingleton<StatementCubit>(
          () => StatementCubit(
            getTransactions: GetTransactions(repository),
            refreshFinancialData: RefreshFinancialData(repository),
          ),
        )
        ..registerFactoryParam<TransactionDetailsCubit, String, void>(
          (transactionId, _) => TransactionDetailsCubit(
            transactionId: transactionId,
            getTransactionDetails: GetTransactionDetails(repository),
          ),
        );

      final router = createAppRouter();
      addTearDown(() async {
        router.dispose();
        if (getIt.isRegistered<StatementCubit>()) {
          await getIt<StatementCubit>().close();
        }
        if (getIt.isRegistered<ThemeCubit>()) {
          await getIt<ThemeCubit>().close();
        }
        await getIt.reset();
      });

      await tester.pumpWidget(
        FluxoFinanceiroApp(router: router, themeCubit: getIt<ThemeCubit>()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saldo disponível'), findsOneWidget);
      await tester.tap(find.text('Extrato'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'mercado');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Compra no mercado'), findsOneWidget);

      await tester.tap(find.text('Compra no mercado'));
      await tester.pumpAndSettle();
      expect(find.text('Detalhes da transação'), findsOneWidget);
      expect(find.text('tx-market'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Extrato'), findsWidgets);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'mercado',
      );
    },
  );
}

final _transaction = FinancialTransaction(
  id: 'tx-market',
  description: 'Compra no mercado',
  amount: const Money.fromCents(24890),
  occurredAt: DateTime.utc(2026, 10, 31, 18, 42),
  type: TransactionType.debit,
  status: TransactionStatus.completed,
  metadata: const {'merchant': 'Mercado Fictício'},
);

final _snapshot = LedgerSnapshot(
  openingBalance: const Money.fromCents(250000),
  openingBalanceAt: DateTime.utc(2026, 10),
  asOf: DateTime.utc(2026, 11, 1, 12),
  transactions: [_transaction],
);
