import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const petroleum = Color(0xFF003B32);
  static const deepPetroleum = Color(0xFF002A24);
  static const emerald = Color(0xFF00815F);
  static const lime = Color(0xFFC6F36A);
  static const lightCanvas = Color(0xFFF4F8F5);
  static const darkCanvas = Color(0xFF001E1A);
  static const darkCard = Color(0xFF0B302A);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final generated = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: brightness,
    );
    final scheme = generated.copyWith(
      primary: isDark ? lime : petroleum,
      onPrimary: isDark ? deepPetroleum : Colors.white,
      primaryContainer: isDark ? darkCard : const Color(0xFFD9F5E8),
      onPrimaryContainer: isDark ? const Color(0xFFE5FFF4) : deepPetroleum,
      secondary: lime,
      onSecondary: deepPetroleum,
      secondaryContainer: isDark
          ? const Color(0xFF294A2D)
          : const Color(0xFFE8F9C5),
      onSecondaryContainer: isDark ? const Color(0xFFE8FFD0) : deepPetroleum,
      tertiary: emerald,
      onTertiary: Colors.white,
      surface: isDark ? darkCanvas : lightCanvas,
      onSurface: isDark ? const Color(0xFFE7F1ED) : const Color(0xFF10201C),
      surfaceContainerLowest: isDark ? const Color(0xFF001713) : Colors.white,
      surfaceContainerLow: isDark ? const Color(0xFF062722) : Colors.white,
      surfaceContainer: isDark ? darkCard : const Color(0xFFEAF1ED),
      surfaceContainerHigh: isDark
          ? const Color(0xFF153B34)
          : const Color(0xFFE1EAE5),
      outline: isDark ? const Color(0xFF668079) : const Color(0xFF71827C),
      outlineVariant: isDark
          ? const Color(0xFF294A43)
          : const Color(0xFFD2DDD7),
      error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
    );
    const roundedRectangle = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: lime,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: deepPetroleum, size: 22);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: lime,
        secondarySelectedColor: lime,
        disabledColor: scheme.surfaceContainer,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: deepPetroleum,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: roundedRectangle,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: roundedRectangle,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: const CircleBorder()),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? lime : deepPetroleum,
        contentTextStyle: TextStyle(
          color: isDark ? deepPetroleum : Colors.white,
        ),
        shape: roundedRectangle,
      ),
    );
  }
}
