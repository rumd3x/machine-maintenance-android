import 'package:flutter/material.dart';

class AppTheme {
  // Dark theme colors based on reference design
  static const Color primaryBackground = Color(0xFF0A1628);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color accentBlue = Color(0xFF2D4263);
  
  // Status colors
  static const Color statusOptimal = Color(0xFF00D68F);
  static const Color statusWarning = Color(0xFFFFA500);
  static const Color statusOverdue = Color(0xFFFF4757);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C4);
  static const Color textAccent = Color(0xFF5B9FFF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentBlue,
      scaffoldBackgroundColor: primaryBackground,
      cardColor: cardBackground,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: textAccent,
        surface: cardBackground,
        error: statusOverdue,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: textAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: textAccent,
        foregroundColor: textPrimary,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
    );
  }
}
