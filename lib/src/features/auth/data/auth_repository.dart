import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/auth_tokens.dart';

/// Everything the auth feature asks of the API. Presentation depends on this
/// interface only — [DioAuthRepository] is never referenced from a screen, so
/// tests override [authRepositoryProvider] instead of stubbing HTTP.
abstract class AuthRepository {
  /// `POST /auth/login` (PRD §5.1.1). Email is unique *per school*, so the
  /// slug is part of the credential, not a convenience.
  ///
  /// Throws an [AppError] — never a `DioException`.
  Future<AuthTokens> login({
    required String email,
    required String password,
    required String schoolSlug,
  });

  /// `POST /auth/logout` (PRD §5.1.3), revoking [refreshToken] — this
  /// device's session only. The token pair is passed in rather than read from
  /// storage because the caller clears storage *immediately*, without waiting
  /// for this call: [accessToken] is attached explicitly so the request still
  /// authenticates after the keystore is empty.
  ///
  /// Throws an [AppError] — never a `DioException`. Callers are expected to
  /// swallow it: logout is local-first, and a failed revoke must not keep the
  /// user signed in.
  Future<void> logout({
    required String refreshToken,
    required String? accessToken,
  });

  /// `POST /auth/forgot-password` (PRD §5.1.4). Answers `200` whether or not
  /// the account exists — callers must not treat a success as proof that an
  /// email went out, and must not report a failure in a way that implies the
  /// opposite.
  ///
  /// Throws an [AppError] — never a `DioException`.
  Future<void> requestPasswordReset({
    required String email,
    required String schoolSlug,
  });

  /// `POST /auth/reset-password` (PRD §5.1.4) with the token from the emailed
  /// deep link. On success every session for that user is revoked
  /// server-side, so the caller must end the local session too.
  ///
  /// Throws an [AppError] — never a `DioException`.
  Future<void> resetPassword({
    required String token,
    required String password,
  });
}

class DioAuthRepository implements AuthRepository {
  const DioAuthRepository(this._dio);

  final Dio _dio;

  static const String loginPath = '/auth/login';
  static const String logoutPath = '/auth/logout';
  static const String forgotPasswordPath = '/auth/forgot-password';
  static const String resetPasswordPath = '/auth/reset-password';

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
    required String schoolSlug,
  }) {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        loginPath,
        data: <String, String>{
          'email': email,
          'password': password,
          'schoolSlug': schoolSlug,
        },
      );

      return AuthTokens.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  @override
  Future<void> logout({
    required String refreshToken,
    required String? accessToken,
  }) {
    return guardApiCall(() async {
      await _dio.post<void>(
        logoutPath,
        // `refreshToken` present = revoke this device only; omitting it would
        // revoke every session the user has (PRD §5.1.3), which is not v1
        // behavior — so it is required here rather than nullable.
        data: <String, String>{'refreshToken': refreshToken},
        // Set explicitly instead of letting AuthInterceptor read the keystore:
        // by the time onRequest runs, logout has already cleared it.
        options: accessToken == null
            ? null
            : Options(
                headers: <String, dynamic>{
                  'Authorization': 'Bearer $accessToken',
                },
              ),
      );
    });
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    required String schoolSlug,
  }) {
    return guardApiCall(() async {
      await _dio.post<void>(
        forgotPasswordPath,
        data: <String, String>{'email': email, 'schoolSlug': schoolSlug},
      );
    });
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) {
    return guardApiCall(() async {
      // The token travels in the body, not as a bearer — it isn't a session,
      // and `/auth/reset-password` is one of the `unauthenticatedPaths`, so
      // nothing is attached to this request.
      await _dio.post<void>(
        resetPasswordPath,
        data: <String, String>{'token': token, 'password': password},
      );
    });
  }
}

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (Ref ref) => DioAuthRepository(ref.watch(dioProvider)),
);
