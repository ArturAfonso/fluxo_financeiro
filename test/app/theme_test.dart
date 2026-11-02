import 'package:fluxo_financeiro/app/theme/app_theme.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'tema inicia claro e alterna persistindo somente claro ou escuro',
    () async {
      final preferences = _Preferences();
      final cubit = ThemeCubit(preferences);
      addTearDown(cubit.close);

      expect(cubit.state.mode, ThemeMode.light);

      await cubit.toggle();
      expect(cubit.state.mode, ThemeMode.dark);
      expect(preferences.mode, ThemeMode.dark);

      await cubit.toggle();
      expect(cubit.state.mode, ThemeMode.light);
      expect(preferences.mode, ThemeMode.light);

      await cubit.setMode(ThemeMode.system);
      expect(cubit.state.mode, ThemeMode.light);
      expect(preferences.mode, ThemeMode.light);
    },
  );

  test('tooltip do gráfico possui contraste mínimo nos dois temas', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final scheme = theme.colorScheme;
      expect(
        _contrastRatio(scheme.inverseSurface, scheme.onInverseSurface),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

final class _Preferences implements AppPreferences {
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
