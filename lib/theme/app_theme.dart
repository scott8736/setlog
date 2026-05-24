import 'package:flutter/material.dart';

class AppTheme {
  // 미니멀 베이지 컬러 팔레트
  static const Color primaryBeige = Color(0xFFF5F1ED);
  static const Color secondaryBeige = Color(0xFFE8DFD5);
  static const Color accentPink = Color(0xFFFFB8B8);
  static const Color textDark = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF8E8E8E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFAF8F5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: primaryBeige,
    colorScheme: ColorScheme.light(
      primary: accentPink,
      secondary: secondaryBeige,
      surface: white,
      onPrimary: white,
      onSecondary: textDark,
      onSurface: textDark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPink,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentPink, width: 2),
      ),
    ),
  );
}
