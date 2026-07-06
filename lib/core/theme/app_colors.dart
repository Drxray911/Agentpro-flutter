import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Agent Pro Ghana colour tokens.
/// Mirrors the design tokens used in the React prototype (makeTheme).
/// Supports light and dark variants.
class AppColors {
  final bool isDark;
  const AppColors({required this.isDark});

  // Brand
  Color get gold => const Color(0xFFF5A623);
  Color get goldDark => const Color(0xFFC8860D);
  Color get goldLight => isDark ? const Color(0xFF3D2A00) : const Color(0xFFFDE8B8);

  Color get green => isDark ? const Color(0xFF2ECC71) : const Color(0xFF1A7A4A);
  Color get greenDark => isDark ? const Color(0xFF1A7A4A) : const Color(0xFF0F5232);
  Color get greenLight => isDark ? const Color(0xFF0D2B1A) : const Color(0xFFD4EFDF);

  Color get charcoal => isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1C1C1E);
  Color get slate => isDark ? const Color(0xFFC0C0D0) : const Color(0xFF3A3A4A);
  Color get muted => isDark ? const Color(0xFF888899) : const Color(0xFF6B6B7B);

  Color get surface => isDark ? const Color(0xFF121218) : const Color(0xFFF8F7F4);
  Color get white => isDark ? const Color(0xFF1E1E28) : const Color(0xFFFFFFFF);

  Color get red => const Color(0xFFD9534F);
  Color get redLight => isDark ? const Color(0xFF2D1010) : const Color(0xFFFDECEA);

  Color get blue => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
  Color get blueLight => isDark ? const Color(0xFF1A2035) : const Color(0xFFEFF6FF);

  Color get purple => isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
  Color get purpleLight => isDark ? const Color(0xFF1E1830) : const Color(0xFFEDE9FE);

  Color get border => isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE5E2DA);

  // Provider brand colours (fixed regardless of theme)
  static const mtnYellow = Color(0xFFFFCC00);
  static const telecelRed = Color(0xFFDC143C);
  static const atBlue = Color(0xFF0047AB);
}

/// InheritedWidget-free accessor: use `context.colors` via the extension below,
/// or `ref.watch(appColorsProvider)` if wired through Riverpod (see app_providers.dart).
extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors(isDark: Theme.of(this).brightness == Brightness.dark);
}
