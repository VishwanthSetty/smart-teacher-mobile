import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../data/auth_repository.dart';
import 'forgot_password_state.dart';
import 'retry_countdown.dart';

/// Drives the reset-request screen (PRD §5.1.4).
///
/// The whole point of this screen is that its outcome must not depend on
/// whether the account exists. The API already answers `200` either way; this
/// controller extends the same discretion to the account-shaped rejections it
/// could still see — a `401`, `403` or `404` from a proxy, a misconfigured
/// route, or a future API change would otherwise turn into an oracle for
/// "which email addresses are registered at which school".
///
/// The exception is failures that mean *the request never happened*: no
/// connection, a timeout, a 5xx. Reporting those as success would leave
/// someone waiting on an email that was never going to arrive, which is worse
/// than the (nonexistent) disclosure of admitting the server is down.
class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  late final RetryCountdown _lockout = RetryCountdown(
    (Duration? remaining) => _emit(
      ForgotPasswordState(
        failure: state.failure,
        lockoutRemaining: remaining,
      ),
    ),
  );

  @override
  ForgotPasswordState build() {
    ref.onDispose(_lockout.cancel);
    return const ForgotPasswordState();
  }

  Future<void> submit({
    required String email,
    required String schoolSlug,
  }) async {
    if (!state.canSubmit) {
      return;
    }

    _emit(const ForgotPasswordState(isSubmitting: true));

    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(
            email: email,
            schoolSlug: schoolSlug,
          );
      _emit(const ForgotPasswordState(isSent: true));
    } on AppError catch (error) {
      final ForgotPasswordFailure? failure = _toFailure(error);
      if (failure == null) {
        // Indistinguishable from a real send, on purpose.
        _emit(const ForgotPasswordState(isSent: true));
        return;
      }
      _fail(failure);
    }
  }

  /// Returns to the form from the confirmation panel, so a mistyped address
  /// can be corrected without leaving the screen.
  void editRequest() {
    _lockout.cancel();
    _emit(const ForgotPasswordState());
  }

  void clearFailure() {
    if (state.failure != null && !state.isSubmitting) {
      _emit(ForgotPasswordState(lockoutRemaining: state.lockoutRemaining));
    }
  }

  void _fail(ForgotPasswordFailure failure) {
    final Duration? lockout = _lockout.start(
      failure is TooManyResetRequests ? failure.retryAfter : null,
    );

    _emit(
      ForgotPasswordState(failure: failure, lockoutRemaining: lockout),
    );
  }

  /// `null` means "show the generic confirmation" — i.e. this outcome must not
  /// be distinguishable from a successful send.
  ForgotPasswordFailure? _toFailure(AppError error) => switch (error) {
        // The three that could reveal whether the account exists.
        UnauthorizedError() || ForbiddenError() || NotFoundError() => null,
        RateLimitedError(retryAfter: final Duration? retryAfter) =>
          TooManyResetRequests(retryAfter: retryAfter),
        ValidationError(
          message: final String message,
          fieldErrors: final List<String> fieldErrors,
        ) =>
          ForgotPasswordRejected(message, fieldErrors),
        NetworkError(message: final String message) =>
          ForgotPasswordNetworkFailure(message),
        UnknownError(message: final String message) =>
          ForgotPasswordUnexpectedFailure(message),
      };

  void _emit(ForgotPasswordState next) {
    if (ref.mounted) {
      state = next;
    }
  }
}

/// Auto-disposed: leaving the screen must not keep a confirmation panel (or a
/// running lockout) around for the next visit.
final NotifierProvider<ForgotPasswordController, ForgotPasswordState>
    forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);
