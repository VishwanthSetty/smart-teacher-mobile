import 'package:flutter/foundation.dart';

/// Why a login attempt didn't produce a session.
///
/// A closed set on purpose: PRD §5.1.1 requires each of these to read
/// differently to the user, so "show `error.message`" is not good enough. The
/// mapping from [AppError] to one of these lives in `LoginController`, and the
/// screen switches over the variants exhaustively.
sealed class LoginFailure {
  const LoginFailure(this.message);

  /// Ready to render. Never contains the API's raw prose for the credential
  /// cases — those are deliberately fixed strings (see [InvalidCredentials]).
  final String message;
}

/// `401`, and also `404`.
///
/// One message for all three fields, by requirement: revealing *which* of
/// email / password / school slug was wrong tells an attacker which accounts
/// and which tenants exist. A wrong slug can surface as a `404` rather than a
/// `401` depending on how far the request got — same message, same reason.
final class InvalidCredentials extends LoginFailure {
  const InvalidCredentials()
      : super(
          "That didn't match an account. Check your email, password and "
          'school code, then try again.',
        );
}

/// `403` where the school itself is fine — the user's own account is off.
/// Nothing the app can do about it, so the message points at the one person
/// who can (PRD §5.1.1).
final class AccountDisabled extends LoginFailure {
  const AccountDisabled()
      : super(
          'This account is disabled. Contact your school admin to have it '
          'switched back on.',
        );
}

/// `403` carrying the suspended-tenant signal, or a login that succeeded into
/// a school whose status is `SUSPENDED` (PRD §5.2). Distinguished from
/// [AccountDisabled] because the person to contact and the thing that's wrong
/// are different — one user vs. the whole school.
final class SchoolSuspended extends LoginFailure {
  const SchoolSuspended()
      : super(
          "Your school's access is suspended. Contact your school admin.",
        );
}

/// `429` — the backend's login lockout (20 failed attempts in a 50-minute
/// window, PRD §5.1.1). [retryAfter] is the server's `Retry-After` hint when
/// it sends one; without it the app can only say "wait", not "wait this
/// long", and must not invent a duration.
final class TooManyAttempts extends LoginFailure {
  const TooManyAttempts({this.retryAfter})
      : super('Too many sign-in attempts. Please wait before trying again.');

  final Duration? retryAfter;
}

/// The request never reached the API, or timed out. The only failure here
/// where retrying immediately is reasonable.
final class LoginNetworkFailure extends LoginFailure {
  const LoginNetworkFailure(super.message);
}

/// `400`/`422` — the API rejected the payload itself. Rare from this screen
/// (client-side validation runs first), but a server-side rule the client
/// doesn't know about would land here rather than in a silent no-op.
final class LoginRejected extends LoginFailure {
  const LoginRejected(super.message, this.fieldErrors);

  final List<String> fieldErrors;
}

/// 5xx and anything unmapped.
final class LoginUnexpectedFailure extends LoginFailure {
  const LoginUnexpectedFailure(super.message);
}

/// Everything the login screen renders off.
@immutable
class LoginState {
  const LoginState({
    this.isSubmitting = false,
    this.failure,
    this.lockoutRemaining,
  });

  /// A request is in flight — the button shows a spinner and re-submission is
  /// refused (see [canSubmit]).
  final bool isSubmitting;

  /// The last attempt's failure, or `null` if there hasn't been one since the
  /// user last edited the form.
  final LoginFailure? failure;

  /// Counts down while the server-provided lockout window from a `429` is
  /// still running. `null` means "not locked out" — including after a `429`
  /// with no `Retry-After` header, where the app shows the message but leaves
  /// the button live rather than guessing at a duration.
  final Duration? lockoutRemaining;

  bool get canSubmit => !isSubmitting && lockoutRemaining == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginState &&
          other.isSubmitting == isSubmitting &&
          other.failure == failure &&
          other.lockoutRemaining == lockoutRemaining;

  @override
  int get hashCode => Object.hash(isSubmitting, failure, lockoutRemaining);
}
