import 'package:flutter/material.dart';

/// Warm neutral light theme with a restrained teal action colour; near-black
/// dark theme with high-contrast text (docs/09 "Design philosophy").
class AppTheme {
  static const teal = Color(0xFF0F766E);
  static const income = Color(0xFF15803D);
  static const expense = Color(0xFFB91C1C);

  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      surface: const Color(0xFFFAF7F2),
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.dark,
      surface: const Color(0xFF0E0F10),
    ),
  );

  static ThemeData _build(ColorScheme scheme) => ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 15),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
  );

  static ThemeMode modeOf(String? setting) => switch (setting) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
