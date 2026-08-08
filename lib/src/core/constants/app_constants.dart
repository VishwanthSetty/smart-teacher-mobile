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

  /// Standard corner radius used across cards, buttons and sheets.
  static const double radius = 16;

  /// Default animation duration for micro-interactions.
  static const Duration animationDuration = Duration(milliseconds: 250);
}
