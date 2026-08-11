import 'package:flutter/foundation.dart';

/// Why a password reset didn't go through (PRD §5.1.4).
sealed class ResetPasswordFailure {
  const ResetPasswordFailure(this.message);

  final String message;
}

/// The token is expired, already used, or was never valid — `401`, `403` or
/// `404`. All three mean the same thing to the user, and the screen offers a
/// way to request a fresh link rather than leaving them on a dead form.
///
/// Reset tokens are single-use and every reset revokes all sessions, so
/// "already used" is a genuinely common case: re-opening the email link after
/// finishing lands here.
final class InvalidResetLink extends ResetPasswordFailure {
  const InvalidResetLink()
      : super(
          'This reset link has expired or has already been used. Request a '
          'new one to continue.',
        );
}

/// `429`. Throttled separately from both the login lockout and the
/// forgot-password limit.
final class TooManyResetAttempts extends ResetPasswordFailure {
  const TooManyResetAttempts({this.retryAfter})
      : super('Too many attempts. Please wait before trying again.');

  final Duration? retryAfter;
}

/// The API rejected the new password itself — a server-side policy the client
/// doesn't know about (length, reuse, a banned-password list). [message] is
/// the API's own wording, since it's the only thing that knows the rule.
final class ResetPasswordRejected extends ResetPasswordFailure {
  const ResetPasswordRejected(super.message, this.fieldErrors);

  final List<String> fieldErrors;
}

final class ResetPasswordNetworkFailure extends ResetPasswordFailure {
  const ResetPasswordNetworkFailure(super.message);
}

final class ResetPasswordUnexpectedFailure extends ResetPasswordFailure {
  const ResetPasswordUnexpectedFailure(super.message);
}

/// Everything the reset screen renders off.
@immutable
class ResetPasswordState {
  const ResetPasswordState({
    this.isSubmitting = false,
    this.failure,
    this.lockoutRemaining,
  });

  final bool isSubmitting;
  final ResetPasswordFailure? failure;
  final Duration? lockoutRemaining;

  bool get canSubmit => !isSubmitting && lockoutRemaining == null;

  /// True once the link is known to be unusable — the form comes down, since
  /// no password typed into it could succeed.
  bool get isLinkDead => failure is InvalidResetLink;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResetPasswordState &&
          other.isSubmitting == isSubmitting &&
          other.failure == failure &&
          other.lockoutRemaining == lockoutRemaining;

  @override
  int get hashCode => Object.hash(isSubmitting, failure, lockoutRemaining);
}
