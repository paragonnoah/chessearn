import 'package:flutter/material.dart';

class ChessEarnTheme {
  static const Map<String, Color> themeColors = {
    'brand-dark': Color(0xFF0A2647),
    'brand-light': Color(0xFFE8ECEF),
    'brand-accent': Color(0xFF2ECC71),
    'brand-danger': Color(0xFFC0392B),
    'brand-secondary': Color(0xFF3498DB),
    'brand-gradient-start': Color(0xFF0A2647),
    'brand-gradient-end': Color(0xFF144272),
    'brand-gradient-accent': Color(0xFF1A365D),
    'text-light': Color(0xFFF8F9FA),
    'text-muted': Color(0xFFAAB8C2),
    'text-dark': Color(0xFF1C1C1E),
    'text-secondary': Color(0xFF6C757D),
    'btn-primary': Color(0xFF2ECC71),
    'btn-primary-hover': Color(0xFF27AE60),
    'btn-outline': Color(0xFFFFFFFF),
    'btn-outline-hover': Color(0xFF2ECC71),
    'btn-secondary': Color(0xFF3498DB),
    'btn-secondary-hover': Color(0xFF2980B9),
    'surface-light': Color(0xFFF4F4F4),
    'surface-dark': Color(0xFF1B1F23),
    'surface-card': Color(0xFFFFFFFF),
    'surface-overlay': Color(0xFF000000),
    'border-soft': Color(0xFFD1D5DB),
    'border-accent': Color(0xFF2ECC71),
    'divider': Color(0xFFE2E8F0),
    'success': Color(0xFF2ECC71),
    'warning': Color(0xFFF39C12),
    'info': Color(0xFF3498DB),
    'error': Color(0xFFC0392B),
    'glow-accent': Color(0xFF2ECC71),
    'shadow-dark': Color(0xFF000000),
    'glass-overlay': Color(0xFFFFFFFF),
  };

  // Helper method to get colors with null safety fallback
  static Color getColor(String key) => themeColors[key] ?? const Color(0xFF000000); // Fallback to black if key missing

  // Gradient Definitions
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [
          getColor('brand-gradient-start'),
          getColor('brand-gradient-end'),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => LinearGradient(
        colors: [
          getColor('brand-accent'),
          getColor('btn-primary-hover'),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        colors: [
          getColor('brand-gradient-start'),
          getColor('brand-gradient-end'),
          getColor('brand-dark'),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.6, 1.0],
      );

  // Shadow Definitions
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: getColor('shadow-dark').withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: getColor('glow-accent').withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: getColor('brand-accent').withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Text Styles
  static TextStyle get headlineStyle => TextStyle(
        color: getColor('text-light'),
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      );

  static TextStyle get titleStyle => TextStyle(
        color: getColor('brand-accent'),
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get subtitleStyle => TextStyle(
        color: getColor('text-muted'),
        fontSize: 18,
        fontWeight: FontWeight.w300,
      );

  static TextStyle get bodyStyle => TextStyle(
        color: getColor('text-dark'),
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get captionStyle => TextStyle(
        color: getColor('text-muted'),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  // Enhanced Theme Data
  static ThemeData get themeData => ThemeData(
        primaryColor: getColor('brand-accent'),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: getColor('brand-accent'),
              onPrimary: getColor('text-light'),
              secondary: getColor('brand-secondary'),
              onSecondary: getColor('text-dark'),
              tertiary: getColor('brand-secondary'),
              onTertiary: getColor('text-dark'),
              surface: getColor('surface-light'),
              onSurface: getColor('text-dark'),
              error: getColor('brand-danger'),
              onError: getColor('text-light'),
              primaryContainer: getColor('brand-dark'),
              onPrimaryContainer: getColor('text-light'),
              secondaryContainer: getColor('brand-secondary'),
              onSecondaryContainer: getColor('text-dark'),
              tertiaryContainer: getColor('surface-light'),
              onTertiaryContainer: getColor('text-dark'),
            ),
        scaffoldBackgroundColor: getColor('brand-light'),
        appBarTheme: AppBarTheme(
          backgroundColor: getColor('brand-dark'),
          foregroundColor: getColor('text-light'),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: getColor('text-light'),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: getColor('brand-accent'),
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            color: getColor('text-dark'),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: getColor('brand-accent'),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: getColor('text-dark'),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: getColor('text-dark'),
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: getColor('text-muted'),
            fontSize: 16,
          ),
          bodySmall: TextStyle(
            color: getColor('text-muted'),
            fontSize: 14,
          ),
          labelLarge: TextStyle(
            color: getColor('text-muted'),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: getColor('text-secondary'),
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: getColor('btn-primary'),
            foregroundColor: getColor('btn-outline'),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                  return getColor('btn-primary-hover');
                }
                return null;
              },
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: getColor('brand-accent'),
            side: BorderSide(
              color: getColor('brand-accent'),
              width: 2,
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                  return getColor('btn-outline-hover').withValues(alpha: 0.1);
                }
                return null;
              },
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: getColor('brand-accent'),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: getColor('surface-light').withValues(alpha: 0.8),
          labelStyle: TextStyle(color: getColor('text-muted')),
          hintStyle: TextStyle(color: getColor('text-muted').withValues(alpha: 0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: getColor('border-soft')),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: getColor('border-soft')),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: getColor('brand-accent'),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: getColor('brand-danger')),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: getColor('surface-card'),
          elevation: 4,
          shadowColor: getColor('shadow-dark').withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: getColor('surface-card'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
        ),
        dividerTheme: DividerThemeData(
          color: getColor('divider'),
          thickness: 1,
        ),
        iconTheme: IconThemeData(
          color: getColor('brand-accent'),
          size: 24,
        ),
        primaryIconTheme: IconThemeData(
          color: getColor('text-light'),
          size: 24,
        ),
      );

  // Dark Theme
  static ThemeData get darkThemeData => ThemeData.dark().copyWith(
        primaryColor: getColor('brand-accent'),
        scaffoldBackgroundColor: getColor('surface-dark'),
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: getColor('brand-accent'),
              secondary: getColor('brand-secondary'),
              surface: getColor('surface-dark'),
              error: getColor('brand-danger'),
              onPrimary: getColor('text-light'),
              onSecondary: getColor('text-light'),
              onSurface: getColor('text-light'),
              onError: getColor('text-light'),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: getColor('brand-dark'),
          foregroundColor: getColor('text-light'),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: getColor('surface-dark'),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}