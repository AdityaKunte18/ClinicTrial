import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1565C0); // Medical blue
  static const _secondaryColor = Color(0xFF00897B); // Teal for clinical
  static const _errorColor = Color(0xFFD32F2F);
  static const _warningColor = Color(0xFFF9A825);
  static const _successColor = Color(0xFF2E7D32);

  // Status colors for workup items
  static const Color statusPending = Color(0xFFBDBDBD);
  static const Color statusOrdered = Color(0xFF42A5F5);
  static const Color statusSent = Color(0xFF66BB6A);
  static const Color statusOverdue = Color(0xFFEF5350);
  static const Color statusDone = Color(0xFF2E7D32);

  // Patient info card background
  static const Color patientCardBg = Color(0xFF1A237E); // Dark navy

  // Day colors for timeline
  static const Color day1 = Color(0xFF1565C0);
  static const Color day2 = Color(0xFF00897B);
  static const Color day3 = Color(0xFFF9A825);
  static const Color day4 = Color(0xFFEF6C00);
  static const Color day5 = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Convenience getters for common colors
  static Color get warning => _warningColor;
  static Color get success => _successColor;
}
