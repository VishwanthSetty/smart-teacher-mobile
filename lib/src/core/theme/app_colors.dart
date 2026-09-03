import 'package:flutter/material.dart';

/// Central seed color and any brand colors that fall outside the generated
/// [ColorScheme]. Prefer `Theme.of(context).colorScheme` in widgets; only
/// reach for these when a value is genuinely brand-fixed.
class AppColors {
  const AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color sky50 = Color(0xFFE3F2FD);
  static const Color sky100 = Color(0xFFD0E7FB);
  static const Color sky200 = Color(0xFFB8DBF9);
  static const Color sky300 = Color(0xFFA1CFF7);
  static const Color sky400 = Color(0xFF90CAF9);
  static const Color blue = Color(0xFF2196F3);
  static const Color navy = Color(0xFF0D47A1);

  static const Color textPrimary = Color(0xFF12263A);
  static const Color textSecondary = Color(0xFF5B6B7B);
  static const Color textDisabled = Color(0xFF93A2B0);

  static const Color darkBackground = Color(0xFF0A1929);
  static const Color darkSurface = Color(0xFF12263A);
  static const Color darkOutline = Color(0xFF1B3A5C);
  static const Color darkText = Color(0xFFE8F1FA);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFD32F2F);
}
