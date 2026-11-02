import 'package:fluxo_financeiro/app/theme/app_theme.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class FluxoFinanceiroApp extends StatelessWidget {
  const FluxoFinanceiroApp({
    required this.router,
    required this.themeCubit,
    super.key,
  });

  final GoRouter router;
  final ThemeCubit themeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) => MaterialApp.router(
          title: 'Fluxo Financeiro',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.mode,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
