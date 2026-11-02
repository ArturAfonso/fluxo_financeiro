import 'package:dio/dio.dart';
import 'package:fluxo_financeiro/app/config/app_config.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:fluxo_financeiro/features/financial_account/data/database/financial_database.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_local_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_remote_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/mock_financial_api_adapter.dart';
import 'package:fluxo_financeiro/features/financial_account/data/repositories/financial_repository_impl.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/repositories/financial_repository.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_account_summary.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transaction_details.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/get_transactions.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/use_cases/refresh_financial_data.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final appConfig = AppConfig.fromEnvironment();
  final dio = Dio(
    BaseOptions(
      baseUrl: appConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  if (appConfig.useMockApi) {
    dio.httpClientAdapter = MockFinancialApiAdapter();
  }

  getIt
    ..registerSingleton(appConfig)
    ..registerLazySingleton(FinancialDatabase.new)
    ..registerLazySingleton<FinancialLocalDataSource>(
      () => DriftFinancialLocalDataSource(getIt()),
    )
    ..registerLazySingleton<Dio>(() => dio)
    ..registerLazySingleton<FinancialRemoteDataSource>(
      () => DioFinancialRemoteDataSource(dio: getIt()),
    )
    ..registerLazySingleton<FinancialRepository>(
      () => FinancialRepositoryImpl(
        localDataSource: getIt(),
        remoteDataSource: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAccountSummary(repository: getIt()))
    ..registerLazySingleton(() => GetTransactions(getIt()))
    ..registerLazySingleton(() => GetTransactionDetails(getIt()))
    ..registerLazySingleton(() => RefreshFinancialData(getIt()))
    ..registerLazySingleton<AppPreferences>(
      () => SharedAppPreferences(SharedPreferencesAsync()),
    )
    ..registerLazySingleton(() => ThemeCubit(getIt())..load())
    ..registerFactory(
      () => DashboardCubit(
        getAccountSummary: getIt(),
        getTransactions: getIt(),
        refreshFinancialData: getIt(),
        preferences: getIt(),
      ),
    )
    ..registerLazySingleton(
      () => StatementCubit(
        getTransactions: getIt(),
        refreshFinancialData: getIt(),
      ),
    )
    ..registerFactoryParam<TransactionDetailsCubit, String, void>(
      (transactionId, _) => TransactionDetailsCubit(
        transactionId: transactionId,
        getTransactionDetails: getIt(),
      ),
    );
}
