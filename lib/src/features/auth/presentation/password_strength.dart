/// The client-side minimum for a new password.
///
/// The API is the real authority — a server-side policy the app doesn't know
/// about comes back as a `ValidationError` and is shown as-is. This exists to
/// catch the obvious case without a round-trip, so it is deliberately a floor,
/// not a copy of the policy.
const int minPasswordLength = 8;

/// A rough, local read on how hard a new password would be to guess. Advisory
/// only: [PasswordStrength.weak] does not block submission (anything meeting
/// [minPasswordLength] is accepted), it just tells the user where they stand
/// while they type.
enum PasswordStrength {
  weak,
  fair,
  strong;

  String get label => switch (this) {
        PasswordStrength.weak => 'Weak',
        PasswordStrength.fair => 'Fair',
        PasswordStrength.strong => 'Strong',
      };

  /// How much of the meter to fill, 0–1.
  double get fraction => switch (this) {
        PasswordStrength.weak => 1 / 3,
        PasswordStrength.fair => 2 / 3,
        PasswordStrength.strong => 1,
      };
}

/// Scores length first and character variety second, which is roughly how
/// guessing difficulty actually behaves — a long passphrase beats a short
/// string with a symbol bolted on.
PasswordStrength estimatePasswordStrength(String password) {
  if (password.length < minPasswordLength) {
    return PasswordStrength.weak;
  }

  int score = 0;
  if (password.length >= 12) {
    score++;
  }
  if (password.length >= 16) {
    score++;
  }
  if (_hasLower.hasMatch(password) && _hasUpper.hasMatch(password)) {
    score++;
  }
  if (_hasDigit.hasMatch(password)) {
    score++;
  }
  if (_hasSymbol.hasMatch(password)) {
    score++;
  }

  return switch (score) {
    >= 4 => PasswordStrength.strong,
    >= 2 => PasswordStrength.fair,
    _ => PasswordStrength.weak,
  };
}

final RegExp _hasLower = RegExp('[a-z]');
final RegExp _hasUpper = RegExp('[A-Z]');
final RegExp _hasDigit = RegExp(r'\d');
final RegExp _hasSymbol = RegExp(r'[^\w\s]');
