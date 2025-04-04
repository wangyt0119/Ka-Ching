import 'package:flutter/material.dart';

class AppTheme {
  // Color scheme
  static const Color primaryColor = Color(0xFFCFF0FA); // Light Blue
  static const Color secondaryColor = Color(0xFFD5FAE4); // Mint Green
  static const Color accentColor = Color(0xFFD2D1F8); // Pastel Purple
  static const Color backgroundColor = Color(0xFFFAFDCC); // Pale Yellow
  static const Color errorColor = Color(0xFFFEDBDB); // Soft Pink
  
  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  
  // Additional colors
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color cardColor = Colors.white;
  static const Color positiveAmount = Color(0xFF4CAF50); // Green for positive balances
  static const Color negativeAmount = Color(0xFFE57373); // Red for negative balances

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
    );
  }
} 