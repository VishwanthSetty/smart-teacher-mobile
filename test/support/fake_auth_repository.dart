import 'dart:async';

import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/domain/auth_tokens.dart';

/// Scripted [AuthRepository] for tests: either returns [tokens] or throws
/// [error]. Overriding `authRepositoryProvider` with this keeps the login
/// tests off Dio entirely — the HTTP-to-[AppError] mapping is already covered
/// by the `AppError` tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.tokens = const AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    ),
    this.error,
    this.forgotPasswordError,
    this.resetPasswordError,
    this.logoutError,
    this.gate,
  });

  final AuthTokens tokens;

  /// When set, [login] throws this instead of returning.
  final AppError? error;

  /// When set, [requestPasswordReset] throws this.
  final AppError? forgotPasswordError;

  /// When set, [resetPassword] throws this.
  final AppError? resetPasswordError;

  /// When set, [logout] throws this — the caller is expected to sign out
  /// anyway (PRD §5.1.3).
  final AppError? logoutError;

  /// When set, every call waits on it — lets a test observe the in-flight
  /// state.
  final Completer<void>? gate;

  int callCount = 0;
  String? lastEmail;
  String? lastPassword;
  String? lastSchoolSlug;

  int forgotPasswordCallCount = 0;
  int resetPasswordCallCount = 0;
  String? lastResetToken;

  int logoutCallCount = 0;
  String? lastLogoutRefreshToken;
  String? lastLogoutAccessToken;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
    required String schoolSlug,
  }) async {
    callCount++;
    lastEmail = email;
    lastPassword = password;
    lastSchoolSlug = schoolSlug;

    if (gate != null) {
      await gate!.future;
    }
    if (error != null) {
      throw error!;
    }
    return tokens;
  }

  @override
  Future<void> logout({
    required String? refreshToken,
    required String? accessToken,
  }) async {
    logoutCallCount++;
    lastLogoutRefreshToken = refreshToken;
    lastLogoutAccessToken = accessToken;

    if (gate != null) {
      await gate!.future;
    }
    if (logoutError != null) {
      throw logoutError!;
    }
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    required String schoolSlug,
  }) async {
    forgotPasswordCallCount++;
    lastEmail = email;
    lastSchoolSlug = schoolSlug;

    if (gate != null) {
      await gate!.future;
    }
    if (forgotPasswordError != null) {
      throw forgotPasswordError!;
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    resetPasswordCallCount++;
    lastResetToken = token;
    lastPassword = password;

    if (gate != null) {
      await gate!.future;
    }
    if (resetPasswordError != null) {
      throw resetPasswordError!;
    }
  }
}
