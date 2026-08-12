import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/session_controller.dart';
import '../data/auth_repository.dart';
import 'reset_password_state.dart';
import 'retry_countdown.dart';

/// Drives the reset screen (PRD §5.1.4).
///
/// A successful reset revokes **every** session for that user server-side, so
/// any tokens this device is holding are already dead by the time the call
/// returns. [submit] therefore ends the local session before reporting
/// success: skipping that would leave the app "signed in" on credentials the
/// server has thrown away, and the router would happily bounce the user into a
/// shell where every request 401s.
///
/// Navigation to `/login` is the screen's job rather than this controller's —
/// it's a step in a flow, not a reaction to auth state. Signing out here does
/// mean the router's redirect is already pointing at `/login` anyway.
class ResetPasswordController extends Notifier<ResetPasswordState> {
  late final RetryCountdown _lockout = RetryCountdown(
    (Duration? remaining) => _emit(
      ResetPasswordState(failure: state.failure, lockoutRemaining: remaining),
    ),
  );

  @override
  ResetPasswordState build() {
    ref.onDispose(_lockout.cancel);
    return const ResetPasswordState();
  }

  /// Returns `true` when the password was changed, which is the screen's cue
  /// to route to `/login`.
  Future<bool> submit({required String token, required String password}) async {
    if (!state.canSubmit) {
      return false;
    }

    _emit(const ResetPasswordState(isSubmitting: true));

    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(token: token, password: password);

      // Unconditional: whatever this device was holding is revoked. On a
      // signed-out app this is a no-op beyond clearing empty storage.
      await ref.read(sessionControllerProvider.notifier).signOut();
      return true;
    } on AppError catch (error) {
      _fail(_toFailure(error));
      return false;
    }
  }

  void clearFailure() {
    if (state.failure != null && !state.isSubmitting && !state.isLinkDead) {
      _emit(ResetPasswordState(lockoutRemaining: state.lockoutRemaining));
    }
  }

  void _fail(ResetPasswordFailure failure) {
    final Duration? lockout = _lockout.start(
      failure is TooManyResetAttempts ? failure.retryAfter : null,
    );

    _emit(ResetPasswordState(failure: failure, lockoutRemaining: lockout));
  }

  ResetPasswordFailure _toFailure(AppError error) => switch (error) {
    // Nothing distinguishes "expired", "already used" and "forged" — and
    // nothing should.
    UnauthorizedError() ||
    ForbiddenError() ||
    NotFoundError() => const InvalidResetLink(),
    RateLimitedError(retryAfter: final Duration? retryAfter) =>
      TooManyResetAttempts(retryAfter: retryAfter),
    ValidationError(
      message: final String message,
      fieldErrors: final List<String> fieldErrors,
    ) =>
      ResetPasswordRejected(message, fieldErrors),
    NetworkError(message: final String message) => ResetPasswordNetworkFailure(
      message,
    ),
    UnknownError(message: final String message) =>
      ResetPasswordUnexpectedFailure(message),
  };

  void _emit(ResetPasswordState next) {
    if (ref.mounted) {
      state = next;
    }
  }
}

final NotifierProvider<ResetPasswordController, ResetPasswordState>
resetPasswordControllerProvider =
    NotifierProvider.autoDispose<ResetPasswordController, ResetPasswordState>(
      ResetPasswordController.new,
    );
