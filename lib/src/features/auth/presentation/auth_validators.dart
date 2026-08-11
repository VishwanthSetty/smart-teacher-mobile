import 'password_strength.dart';

/// Client-side form checks shared by the auth screens.
///
/// They exist to save a round-trip and to point at the offending field — which
/// the API's own `401` deliberately never does. They are not a copy of the
/// server's rules: anything they let through is still the server's call, and a
/// rejection comes back as a `ValidationError`.
///
/// Shared rather than per-screen so a user can't be told two different things
/// about the same address on two different screens.
String? validateEmailField(String? value) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email';
  }
  if (!_emailPattern.hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validateSchoolSlugField(String? value) {
  if ((value?.trim() ?? '').isEmpty) {
    return 'Enter your school code';
  }
  return null;
}

/// For *entering* an existing password (login): presence only. Length rules
/// belong on the screen that sets a password, not the one that checks it — an
/// account created before a policy change must still be able to sign in.
String? validateExistingPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter your password';
  }
  return null;
}

/// For *choosing* a password (reset).
String? validateNewPassword(String? value) {
  final String password = value ?? '';
  if (password.isEmpty) {
    return 'Enter a new password';
  }
  if (password.length < minPasswordLength) {
    return 'Use at least $minPasswordLength characters';
  }
  return null;
}

/// Catches the typo that would otherwise lock someone out of the account they
/// just reset — they'd have no way to discover which keystroke went wrong.
String? validatePasswordConfirmation(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Re-enter your new password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

/// Deliberately permissive: `something@something.tld`. Anything stricter
/// rejects addresses that are actually valid, and the server is the authority
/// on whether the account exists anyway.
final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
