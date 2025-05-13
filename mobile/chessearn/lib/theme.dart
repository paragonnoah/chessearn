import 'package:flutter/material.dart';

class ChessEarnTheme {
  static final Map<String, Color> themeColors = {
    'brand-dark': const Color(0xFF0A2647),
    'brand-light': const Color(0xFFE8ECEF),
    'brand-accent': const Color(0xFF2ECC71),
    'brand-danger': const Color(0xFFC0392B),
    'brand-secondary': const Color(0xFF3498DB),
    'brand-gradient-start': const Color(0xFF0A2647),
    'brand-gradient-end': const Color(0xFF144272),
    'text-light': const Color(0xFFF8F9FA),
    'text-muted': const Color(0xFFAAB8C2),
    'text-dark': const Color(0xFF1C1C1E),
    'btn-primary': const Color(0xFF2ECC71),
    'btn-primary-hover': const Color(0xFF27AE60),
    'btn-outline': const Color(0xFFFFFFFF),
    'btn-outline-hover': const Color(0xFF2ECC71),
    'surface-light': const Color(0xFFF4F4F4),
    'surface-dark': const Color(0xFF1B1F23),
    'border-soft': const Color(0xFFD1D5DB),
  };

  static ThemeData get themeData => ThemeData(
        primaryColor: themeColors['brand-accent'],
        colorScheme: ColorScheme(
          primary: themeColors['brand-accent']!,
          secondary: themeColors['brand-secondary']!,
          surface: themeColors['surface-light']!,
          error: themeColors['brand-danger']!,
          onPrimary: themeColors['text-light']!,
          onSecondary: themeColors['text-dark']!,
          onSurface: themeColors['text-dark']!,
          onError: themeColors['text-light']!,
          brightness: Brightness.light,
          primaryContainer: themeColors['brand-dark']!,
          onPrimaryContainer: themeColors['text-light']!,
          secondaryContainer: themeColors['brand-secondary']!,
          onSecondaryContainer: themeColors['text-dark']!,
          tertiary: themeColors['brand-secondary']!,
          onTertiary: themeColors['text-dark']!,
          tertiaryContainer: themeColors['surface-light']!,
          onTertiaryContainer: themeColors['text-dark']!,
        ),
        scaffoldBackgroundColor: themeColors['brand-light'],
        appBarTheme: AppBarTheme(
          backgroundColor: themeColors['brand-dark'],
          foregroundColor: themeColors['text-light'],
          elevation: 0,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: themeColors['brand-accent'], fontSize: 48, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: themeColors['text-muted'], fontSize: 18),
          labelLarge: TextStyle(color: themeColors['text-muted']),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors['btn-primary'],
            foregroundColor: themeColors['btn-outline'],
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                  return themeColors['btn-primary-hover'];
                }
                return null;
              },
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: themeColors['btn-outline'],
            side: BorderSide(color: themeColors['btn-outline']!),
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                  return themeColors['btn-outline-hover'];
                }
                return null;
              },
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: themeColors['surface-light']!.withOpacity(0.3),
          labelStyle: TextStyle(color: themeColors['text-muted']),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}