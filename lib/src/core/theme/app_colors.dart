import 'package:flutter/material.dart';

/// Central seed color and any brand colors that fall outside the generated
/// [ColorScheme]. Prefer `Theme.of(context).colorScheme` in widgets; only
/// reach for these when a value is genuinely brand-fixed.
class AppColors {
  const AppColors._();

  /// Seed used to generate the Material 3 color schemes.
  static const Color seed = Color(0xFF2563EB);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
}
