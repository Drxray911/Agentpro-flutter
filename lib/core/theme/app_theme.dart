import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the Material 3 ThemeData for Agent Pro Ghana.
/// Call AppTheme.light() / AppTheme.dark() from MaterialApp.
class AppTheme {
  static ThemeData light() => _build(const AppColors(isDark: false), Brightness.light);
  static ThemeData dark() => _build(const AppColors(isDark: true), Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: c.charcoal,
      displayColor: c.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.surface,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.green,
        onPrimary: Colors.white,
        secondary: c.gold,
        onSecondary: c.greenDark,
        error: c.red,
        onError: Colors.white,
        surface: c.white,
        onSurface: c.charcoal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.white,
        foregroundColor: c.charcoal,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
        shape: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: c.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.green,
          side: BorderSide(color: c.green, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.green,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.green, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.white,
        selectedItemColor: c.green,
        unselectedItemColor: c.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    );
  }
}
