import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppPreferences {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<bool> getBalanceVisible();
  Future<void> setBalanceVisible(bool visible);
}

final class SharedAppPreferences implements AppPreferences {
  SharedAppPreferences(this.preferences);

  final SharedPreferencesAsync preferences;

  static const _themeKey = 'theme_mode';
  static const _balanceVisibleKey = 'balance_visible';

  @override
  Future<ThemeMode> getThemeMode() async =>
      switch (await preferences.getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      };

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      preferences.setString(_themeKey, mode.name);

  @override
  Future<bool> getBalanceVisible() async =>
      await preferences.getBool(_balanceVisibleKey) ?? true;

  @override
  Future<void> setBalanceVisible(bool visible) =>
      preferences.setBool(_balanceVisibleKey, visible);
}
