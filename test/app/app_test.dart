import 'package:fluxo_financeiro/app/app.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('inicia o scaffold do aplicativo', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Fluxo Financeiro'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      FluxoFinanceiroApp(
        router: router,
        themeCubit: ThemeCubit(_MemoryPreferences()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fluxo Financeiro'), findsOneWidget);
  });
}

final class _MemoryPreferences implements AppPreferences {
  ThemeMode mode = ThemeMode.light;

  @override
  Future<bool> getBalanceVisible() async => true;

  @override
  Future<ThemeMode> getThemeMode() async => mode;

  @override
  Future<void> setBalanceVisible(bool visible) async {}

  @override
  Future<void> setThemeMode(ThemeMode mode) async => this.mode = mode;
}
