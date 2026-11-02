import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/financial_transaction.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/ledger_snapshot.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_screen.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_screen.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  late _MockRepository repository;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    registerFallbackValue(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );
  });

  setUp(() => repository = _MockRepository());

  testWidgets('dashboard apresenta erro offline com ação de retry', (
    tester,
  ) async {
    when(
      repository.getLedgerSnapshot,
    ).thenAnswer((_) async => const FailureResult(OfflineFailure()));
    when(
      () => repository.getTransactions(any()),
    ).thenAnswer((_) async => const FailureResult(OfflineFailure()));
    final cubit = _dashboardCubit(repository);
    await cubit.load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _TestApp(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(_Preferences())),
          BlocProvider<DashboardCubit>.value(value: cubit),
        ],
        child: const DashboardScreen(),
      ),
    );

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('extrato apresenta estado vazio e permite limpar filtros', (
    tester,
  ) async {
    when(() => repository.getTransactions(any())).thenAnswer(
      (_) async => Success(
        TransactionPage(
          items: const [],
          lastSynchronizedAt: DateTime.utc(2026, 11, 1, 9),
          isStale: true,
        ),
      ),
    );
    final cubit = StatementCubit(
      getTransactions: GetTransactions(repository),
      refreshFinancialData: RefreshFinancialData(repository),
    );
    await cubit.load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _TestApp(
        providers: [BlocProvider<StatementCubit>.value(value: cubit)],
        child: const StatementScreen(),
      ),
    );

    expect(find.text('Nenhum resultado'), findsOneWidget);
    expect(find.text('Limpar filtros'), findsOneWidget);
    expect(find.textContaining('podem estar desatualizados'), findsOneWidget);
  });

  testWidgets('detalhe cobre loading e dados completos', (tester) async {
    when(() => repository.getTransactionById('tx-1')).thenAnswer(
      (_) async => Success(
        TransactionDetails(
          transaction: _transaction,
          lastSynchronizedAt: DateTime.utc(2026, 11, 1, 9),
          isStale: true,
        ),
      ),
    );
    final cubit = TransactionDetailsCubit(
      transactionId: 'tx-1',
      getTransactionDetails: GetTransactionDetails(repository),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _TestApp(
        providers: [BlocProvider<TransactionDetailsCubit>.value(value: cubit)],
        child: const TransactionDetailsScreen(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await cubit.load();
    await tester.pump();

    expect(find.text('Transferência recebida'), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('tx-1'), findsOneWidget);
    expect(find.textContaining('podem estar desatualizados'), findsOneWidget);
  });

  testWidgets('dashboard suporta escala de texto ampliada sem exceção', (
    tester,
  ) async {
    when(
      repository.getLedgerSnapshot,
    ).thenAnswer((_) async => Success(_snapshot));
    when(
      () => repository.getTransactions(any()),
    ).thenAnswer((_) async => Success(TransactionPage(items: [_transaction])));
    final cubit = _dashboardCubit(repository);
    final themeCubit = ThemeCubit(_Preferences());
    await cubit.load();
    addTearDown(cubit.close);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _TestApp(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<DashboardCubit>.value(value: cubit),
          ],
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Saldo disponível'), findsOneWidget);
    expect(find.byType(PopupMenuButton<ThemeMode>), findsNothing);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();

    expect(themeCubit.state.mode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('dashboard sinaliza cache desatualizado e oferece atualização', (
    tester,
  ) async {
    when(repository.getLedgerSnapshot).thenAnswer(
      (_) async => Success(
        _snapshot.withFreshness(
          lastSynchronizedAt: DateTime.utc(2026, 11, 1, 9),
          isStale: true,
        ),
      ),
    );
    when(
      () => repository.getTransactions(any()),
    ).thenAnswer((_) async => Success(TransactionPage(items: [_transaction])));
    final cubit = _dashboardCubit(repository);
    final themeCubit = ThemeCubit(_Preferences());
    await cubit.load();
    addTearDown(cubit.close);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(
      _TestApp(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<DashboardCubit>.value(value: cubit),
        ],
        child: const DashboardScreen(),
      ),
    );

    expect(find.textContaining('podem estar desatualizados'), findsOneWidget);
    expect(find.byTooltip('Tentar atualizar'), findsOneWidget);
  });

  testWidgets('dashboard agrupa mês completo em períodos semanais', (
    tester,
  ) async {
    when(
      repository.getLedgerSnapshot,
    ).thenAnswer((_) async => Success(_snapshot));
    when(
      () => repository.getTransactions(any()),
    ).thenAnswer((_) async => Success(TransactionPage(items: [_transaction])));
    final cubit = _dashboardCubit(repository);
    final themeCubit = ThemeCubit(_Preferences());
    await cubit.load();
    await cubit.changeMonth(-1);
    addTearDown(cubit.close);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(
      _TestApp(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<DashboardCubit>.value(value: cubit),
        ],
        child: const DashboardScreen(),
      ),
    );

    expect(find.text('Por semana'), findsOneWidget);
    expect(find.text('01–07'), findsOneWidget);
    expect(find.text('29–31'), findsOneWidget);
  });
}

DashboardCubit _dashboardCubit(FinancialRepository repository) =>
    DashboardCubit(
      getAccountSummary: GetAccountSummary(repository: repository),
      getTransactions: GetTransactions(repository),
      refreshFinancialData: RefreshFinancialData(repository),
      preferences: _Preferences(),
      clock: () => DateTime(2026, 11),
    );

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.providers, required this.child});

  final List<BlocProvider> providers;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }
}

final _transaction = FinancialTransaction(
  id: 'tx-1',
  description: 'Transferência recebida',
  amount: const Money.fromCents(50000),
  occurredAt: DateTime.utc(2026, 11, 1, 10),
  type: TransactionType.credit,
  status: TransactionStatus.completed,
  metadata: const {'sender': 'Cliente Exemplo'},
);

final _snapshot = LedgerSnapshot(
  openingBalance: const Money.fromCents(100000),
  openingBalanceAt: DateTime.utc(2026, 10, 1),
  asOf: DateTime.utc(2026, 11, 1, 12),
  transactions: [_transaction],
);
