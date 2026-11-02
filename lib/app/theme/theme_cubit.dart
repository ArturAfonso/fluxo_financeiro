import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ThemeState extends Equatable {
  const ThemeState(this.mode);
  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

final class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this.preferences) : super(const ThemeState(ThemeMode.light));

  final AppPreferences preferences;

  Future<void> load() async =>
      emit(ThemeState(await preferences.getThemeMode()));

  Future<void> setMode(ThemeMode mode) async {
    final supportedMode = mode == ThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(supportedMode));
    await preferences.setThemeMode(supportedMode);
  }

  Future<void> toggle() =>
      setMode(state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
