import 'package:flutter/foundation.dart';

/// Why a reset request couldn't be *sent* (PRD §5.1.4).
///
/// Note what isn't here: there is no "no such account" failure, and there
/// never can be. `POST /auth/forgot-password` answers `200` whether or not the
/// account exists, and the app treats the account-shaped rejections it could
/// still receive (401/403/404 from a proxy or a future API change) as success
/// too — see `ForgotPasswordController`. Only failures that mean *the request
/// itself didn't happen* reach the user, because those are the ones where
/// "check your inbox" would be a lie.
sealed class ForgotPasswordFailure {
  const ForgotPasswordFailure(this.message);

  final String message;
}

/// `429` — throttled independently of the login lockout (PRD §5.1.4), so this
/// deliberately reads differently from `TooManyAttempts`: nothing was typed
/// wrong here, the user just asked more than once.
final class TooManyResetRequests extends ForgotPasswordFailure {
  const TooManyResetRequests({this.retryAfter})
      : super(
          "You've asked for a reset link a few times already. Please wait "
          'before asking again.',
        );

  final Duration? retryAfter;
}

/// The request never left the device, or timed out on the way.
final class ForgotPasswordNetworkFailure extends ForgotPasswordFailure {
  const ForgotPasswordNetworkFailure(super.message);
}

/// `400`/`422` — the API rejected the payload itself.
final class ForgotPasswordRejected extends ForgotPasswordFailure {
  const ForgotPasswordRejected(super.message, this.fieldErrors);

  final List<String> fieldErrors;
}

/// 5xx and anything unmapped. Reported rather than swallowed: the app can't
/// claim a link is on its way when the server just fell over.
final class ForgotPasswordUnexpectedFailure extends ForgotPasswordFailure {
  const ForgotPasswordUnexpectedFailure(super.message);
}

/// Everything the forgot-password screen renders off.
@immutable
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.isSent = false,
    this.failure,
    this.lockoutRemaining,
  });

  final bool isSubmitting;

  /// The request went through. Says nothing about whether an email was
  /// actually sent — by design, that's exactly what the API refuses to tell
  /// us, so the confirmation copy is conditional ("if an account exists…").
  final bool isSent;

  final ForgotPasswordFailure? failure;

  /// Counts down while a `429` window from the server is still running.
  final Duration? lockoutRemaining;

  bool get canSubmit => !isSubmitting && lockoutRemaining == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordState &&
          other.isSubmitting == isSubmitting &&
          other.isSent == isSent &&
          other.failure == failure &&
          other.lockoutRemaining == lockoutRemaining;

  @override
  int get hashCode => Object.hash(isSubmitting, isSent, failure, lockoutRemaining);
}
