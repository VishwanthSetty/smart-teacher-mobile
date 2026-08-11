import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../../profile/data/current_user_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/me_entity.dart';
import '../data/auth_repository.dart';
import '../domain/auth_tokens.dart';
import 'login_state.dart';
import 'retry_countdown.dart';

/// Drives the login screen (PRD §5.1.1): submit → persist tokens → fetch the
/// profile → open the session.
///
/// Ordering matters and is the reason this sequence lives in one place:
///
///  1. `POST /auth/login`,
///  2. tokens into secure storage — *before* any authenticated call, since the
///     Dio interceptor reads the access token from storage, not from here,
///  3. `GET /users/me`, which is that first authenticated call,
///  4. profile into [currentUserProvider], so the role is available to the
///     shell before it builds,
///  5. `SessionController.onSignedIn()` last.
///
/// Step 5 is also the navigation: flipping the session makes the router's
/// redirect move off `/login` to `/home` (PRD §6.6). This controller never
/// calls `context.go` — the redirect is the only place navigation reacts to
/// auth state, so a session opened here and one restored at startup land the
/// user in exactly the same place.
///
/// If any step after (2) fails, the persisted tokens are cleared again: a
/// half-open session (tokens on disk, no session state) would let the next
/// launch skip login and land on a shell with no profile.
class LoginController extends Notifier<LoginState> {
  late final RetryCountdown _lockout = RetryCountdown(
    (Duration? remaining) => _emit(
      LoginState(failure: state.failure, lockoutRemaining: remaining),
    ),
  );

  @override
  LoginState build() {
    ref.onDispose(_lockout.cancel);
    return const LoginState();
  }

  /// Runs an attempt. Callers validate the form first — this trusts its
  /// inputs and only guards against double submission and the `429` lockout.
  Future<void> submit({
    required String email,
    required String password,
    required String schoolSlug,
  }) async {
    if (!state.canSubmit) {
      return;
    }

    _emit(const LoginState(isSubmitting: true));

    bool tokensPersisted = false;
    try {
      final AuthTokens tokens = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
            schoolSlug: schoolSlug,
          );

      await ref.read(tokenStorageProvider).saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
      tokensPersisted = true;

      final MeEntity user = await ref.read(profileRepositoryProvider).fetchMe();

      // The credentials were right, but every call from here on would 403
      // (PRD §5.2). Refuse the session rather than admitting the user to a
      // shell where each screen fails on its own.
      if (user.isSchoolSuspended) {
        await _discardTokens();
        _fail(const SchoolSuspended());
        return;
      }

      ref.read(currentUserProvider.notifier).setUser(user);
      ref.read(sessionControllerProvider.notifier).onSignedIn();
      // No state write past this point: the redirect disposes this screen,
      // and with it this (auto-disposed) controller.
    } on AppError catch (error) {
      if (tokensPersisted) {
        await _discardTokens();
      }
      _fail(_toFailure(error));
    }
  }

  /// Clears the error as soon as the user starts fixing the form, so a stale
  /// "that didn't match an account" doesn't sit under a field they've since
  /// corrected. The lockout is deliberately *not* cleared — it's the server's
  /// window, not a UI state, and editing the form doesn't shorten it.
  void clearFailure() {
    if (state.failure != null && !state.isSubmitting) {
      _emit(LoginState(lockoutRemaining: state.lockoutRemaining));
    }
  }

  void _fail(LoginFailure failure) {
    // The lockout ticks itself down so the button re-enables on its own,
    // rather than leaving the user poking at a dead one.
    final Duration? lockout = _lockout.start(
      failure is TooManyAttempts ? failure.retryAfter : null,
    );

    _emit(LoginState(failure: failure, lockoutRemaining: lockout));
  }

  Future<void> _discardTokens() async {
    try {
      await ref.read(tokenStorageProvider).clearTokens();
    } catch (_) {
      // Best effort. An unwritable keystore must not turn a failed login into
      // a crash — the session was never opened, so nothing downstream trusts
      // whatever is left behind.
    }
  }

  /// The one place login's HTTP outcomes become user-facing states
  /// (PRD §5.1.1). Exhaustive over [AppError]: a new variant there shows up
  /// here as an analyzer error rather than a silently generic message.
  LoginFailure _toFailure(AppError error) => switch (error) {
        // The interceptor doesn't refresh its way out of a 401 on a public
        // auth route, so this is genuinely "wrong credentials".
        UnauthorizedError() => const InvalidCredentials(),
        ForbiddenError(isSchoolSuspended: true) => const SchoolSuspended(),
        ForbiddenError() => const AccountDisabled(),
        // Don't confirm or deny that a school slug exists.
        NotFoundError() => const InvalidCredentials(),
        RateLimitedError(retryAfter: final Duration? retryAfter) =>
          TooManyAttempts(retryAfter: retryAfter),
        ValidationError(
          message: final String message,
          fieldErrors: final List<String> fieldErrors,
        ) =>
          LoginRejected(message, fieldErrors),
        NetworkError(message: final String message) =>
          LoginNetworkFailure(message),
        UnknownError(message: final String message) =>
          LoginUnexpectedFailure(message),
      };

  /// Guards every state write: the success path redirects away, which can
  /// dispose this controller while a late future is still unwinding.
  void _emit(LoginState next) {
    if (ref.mounted) {
      state = next;
    }
  }
}

/// Auto-disposed: leaving the login screen must not leave a stale error (or a
/// running lockout ticker) behind for the next visit.
final NotifierProvider<LoginController, LoginState> loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);
