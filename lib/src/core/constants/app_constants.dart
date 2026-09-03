/// Application-wide constant values.
///
/// Keep only truly global, environment-agnostic constants here. Feature-
/// specific values belong inside their respective feature folders.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Smart Teacher';

  /// Standard spacing scale used across the UI (in logical pixels).
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  /// Compatibility radius for older feature widgets.
  static const double radius = 20;

  static const double cardRadius = 20;
  static const double buttonRadius = 16;
  static const double inputRadius = 16;

  /// Default animation duration for micro-interactions.
  static const Duration animationDuration = Duration(milliseconds: 220);
}
