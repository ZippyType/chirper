import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, system }

final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.light);

class AppTheme {
  // === VIOLET (Brand) ===
  static const Color violet50 = Color(0xFFEDE9FF);
  static const Color violet200 = Color(0xFFC4B5FD);
  static const Color violet400 = Color(0xFFA78BF5);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet800 = Color(0xFF5B21B6);
  static const Color violet900 = Color(0xFF3B0F8F);

  // === CORAL (Energy/Likes) ===
  static const Color coral50 = Color(0xFFFFF1ED);
  static const Color coral200 = Color(0xFFFECAB8);
  static const Color coral400 = Color(0xFFFD9172);
  static const Color coral600 = Color(0xFFE25021);
  static const Color coral800 = Color(0xFFB03818);

  // === STONE (Neutral) - Light Mode ===
  static const Color stone50 = Color(0xFFF4F3F0);
  static const Color stone100 = Color(0xFFE2E0D8);
  static const Color stone300 = Color(0xFFBFBDB4);
  static const Color stone500 = Color(0xFF888680);
  static const Color stone700 = Color(0xFF55534E);
  
  // === STONE (Neutral) - Dark Mode ===
  static const Color darkStone = Color(0xFF1C1B19);
  static const Color darkCard = Color(0xFF27261F);
  static const Color darkBorder = Color(0xFF3A3930);
  static const Color darkTextPrimary = Color(0xFFEBE9E3);
  static const Color darkTextSecondary = Color(0xFF777268);

  // === MOSS (Success/Verified) ===
  static const Color moss100 = Color(0xFFA7F3D0);
  static const Color moss600 = Color(0xFF059669);
  static const Color moss800 = Color(0xFF065F46);

  // Current brand colors (pointing to palette)
  static const Color primaryColor = violet600;
  static const Color secondaryColor = violet400;
  static const Color accentColor = coral600;
  static const Color errorColor = coral600;
  static const Color successColor = moss600;

  // Background colors
  static Color backgroundColor(bool isDark) => isDark ? darkStone : stone50;
  static Color cardColor(bool isDark) => isDark ? darkCard : Colors.white;
  static Color cardBorder(bool isDark) => isDark ? darkBorder : stone100;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : stone700;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : stone500;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: stone50,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: stone50,
        foregroundColor: stone700,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: stone700,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: stone500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: stone100, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: stone100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: stone100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: stone700,
          side: const BorderSide(color: stone100, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: stone100,
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkStone,
      primaryColor: violet400,
      colorScheme: const ColorScheme.dark(
        primary: violet400,
        secondary: violet200,
        surface: darkCard,
        error: coral400,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkStone,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: violet400,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: violet400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: violet400,
          foregroundColor: darkStone,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: violet400,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 0.5,
      ),
    );
  }
}