import 'package:fluxo_financeiro/app/di/injection.dart';
import 'package:fluxo_financeiro/app/router/main_shell.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/dashboard/dashboard_screen.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/statement/statement_screen.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_cubit.dart';
import 'package:fluxo_financeiro/features/financial_account/presentation/transaction_details/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'dashboard',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<DashboardCubit>()..load(),
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statement',
                name: 'statement',
                builder: (context, state) => BlocProvider.value(
                  value: getIt<StatementCubit>(),
                  child: const StatementScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/transactions/:transactionId',
        name: 'transactionDetails',
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return BlocProvider(
            create: (_) =>
                getIt<TransactionDetailsCubit>(param1: transactionId)..load(),
            child: const TransactionDetailsScreen(),
          );
        },
      ),
    ],
  );
}
