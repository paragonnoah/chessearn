import 'package:flutter/material.dart';

class ChessEarnTheme {
  static final Map<String, Color> themeColors = {
    // Core Brand Colors
    'brand-dark': const Color(0xFF0A2647),
    'brand-light': const Color(0xFFE8ECEF),
    'brand-accent': const Color(0xFF2ECC71),
    'brand-danger': const Color(0xFFC0392B),
    'brand-secondary': const Color(0xFF3498DB),
    
    // Enhanced Gradient Colors
    'brand-gradient-start': const Color(0xFF0A2647),
    'brand-gradient-end': const Color(0xFF144272),
    'brand-gradient-accent': const Color(0xFF1A365D), // New intermediate gradient color
    
    // Text Colors
    'text-light': const Color(0xFFF8F9FA),
    'text-muted': const Color(0xFFAAB8C2),
    'text-dark': const Color(0xFF1C1C1E),
    'text-secondary': const Color(0xFF6C757D), // New secondary text color
    
    // Button Colors
    'btn-primary': const Color(0xFF2ECC71),
    'btn-primary-hover': const Color(0xFF27AE60),
    'btn-outline': const Color(0xFFFFFFFF),
    'btn-outline-hover': const Color(0xFF2ECC71),
    'btn-secondary': const Color(0xFF3498DB),
    'btn-secondary-hover': const Color(0xFF2980B9),
    
    // Surface Colors
    'surface-light': const Color(0xFFF4F4F4),
    'surface-dark': const Color(0xFF1B1F23),
    'surface-card': const Color(0xFFFFFFFF),
    'surface-overlay': const Color(0xFF000000), // For overlays with opacity
    
    // Border and Divider Colors
    'border-soft': const Color(0xFFD1D5DB),
    'border-accent': const Color(0xFF2ECC71),
    'divider': const Color(0xFFE2E8F0),
    
    // Status Colors
    'success': const Color(0xFF2ECC71),
    'warning': const Color(0xFFF39C12),
    'info': const Color(0xFF3498DB),
    'error': const Color(0xFFC0392B),
    
    // Special Effect Colors
    'glow-accent': const Color(0xFF2ECC71),
    'shadow-dark': const Color(0xFF000000),
    'glass-overlay': const Color(0xFFFFFFFF), // For glass morphism effects
  };

  // Gradient Definitions
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [
      themeColors['brand-gradient-start']!,
      themeColors['brand-gradient-end']!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => LinearGradient(
    colors: [
      themeColors['brand-accent']!,
      themeColors['btn-primary-hover']!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    colors: [
      themeColors['brand-gradient-start']!,
      themeColors['brand-gradient-end']!,
      themeColors['brand-dark']!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.6, 1.0],
  );

  // Shadow Definitions
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: themeColors['shadow-dark']!.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: themeColors['glow-accent']!.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 5,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: themeColors['brand-accent']!.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Text Styles
  static TextStyle get headlineStyle => TextStyle(
    color: themeColors['text-light'],
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static TextStyle get titleStyle => TextStyle(
    color: themeColors['brand-accent'],
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get subtitleStyle => TextStyle(
    color: themeColors['text-muted'],
    fontSize: 18,
    fontWeight: FontWeight.w300,
  );

  static TextStyle get bodyStyle => TextStyle(
    color: themeColors['text-dark'],
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get captionStyle => TextStyle(
    color: themeColors['text-muted'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Enhanced Theme Data
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
    
    // Enhanced AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: themeColors['brand-dark'],
      foregroundColor: themeColors['text-light'],
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: themeColors['text-light'],
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Enhanced Text Theme
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: themeColors['brand-accent'], 
        fontSize: 48, 
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      headlineMedium: TextStyle(
        color: themeColors['text-dark'], 
        fontSize: 32, 
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: themeColors['brand-accent'], 
        fontSize: 24, 
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: themeColors['text-dark'], 
        fontSize: 20, 
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: themeColors['text-dark'], 
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: themeColors['text-muted'], 
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: themeColors['text-muted'], 
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: themeColors['text-muted'],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: themeColors['text-secondary'],
        fontSize: 14,
      ),
    ),
    
    // Enhanced Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColors['btn-primary'],
        foregroundColor: themeColors['btn-outline'],
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
              return themeColors['btn-primary-hover'];
            }
            return null;
          },
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: themeColors['brand-accent'],
        side: BorderSide(color: themeColors['brand-accent']!, width: 2),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return themeColors['brand-accent']!.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: themeColors['brand-accent'],
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    
    // Enhanced Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: themeColors['surface-light']!.withOpacity(0.8),
      labelStyle: TextStyle(color: themeColors['text-muted']),
      hintStyle: TextStyle(color: themeColors['text-muted']!.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeColors['border-soft']!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeColors['border-soft']!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeColors['brand-accent']!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeColors['brand-danger']!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: themeColors['surface-card'],
      elevation: 4,
      shadowColor: themeColors['shadow-dark']!.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: themeColors['surface-card'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: themeColors['divider'],
      thickness: 1,
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: themeColors['brand-accent'],
      size: 24,
    ),
    
    // Primary Icon Theme
    primaryIconTheme: IconThemeData(
      color: themeColors['text-light'],
      size: 24,
    ),
  );

  // Dark Theme (Optional - for future use)
  static ThemeData get darkThemeData => ThemeData(
    brightness: Brightness.dark,
    primaryColor: themeColors['brand-accent'],
    scaffoldBackgroundColor: themeColors['surface-dark'],
    colorScheme: ColorScheme.dark(
      primary: themeColors['brand-accent']!,
      secondary: themeColors['brand-secondary']!,
      surface: themeColors['surface-dark']!,
      error: themeColors['brand-danger']!,
    ),
    // Add more dark theme customizations as needed
  );
}