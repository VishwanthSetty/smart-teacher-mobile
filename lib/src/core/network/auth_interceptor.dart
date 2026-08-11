import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'auth_event_notifier.dart';

/// Path of the refresh endpoint, relative to the Dio base URL. A 401 on this
/// path specifically means the refresh token itself was rejected — that is
/// an unrecoverable session failure, not something [AuthInterceptor.onError]
/// should try to refresh its way out of.
const String refreshPath = '/auth/refresh';

/// Routes the interceptor keeps its hands off: it neither attaches a stored
/// bearer token to them nor tries to refresh its way out of their `401`s.
///
/// Most are routes for a caller who, by definition, has no session yet (PRD
/// §5.1.1, §5.1.4). A stale token left over from a previous user is
/// meaningless to them, and their `401`s are *answers*, not expired sessions:
/// a 401 from `/auth/login` means the password was wrong, so refreshing and
/// retrying would both hide the real result and hand the user a forced logout
/// for mistyping.
///
/// `/auth/logout` is here for the mirror-image reason (PRD §5.1.3): it sends
/// its own `Authorization` header because the local session is torn down
/// without waiting for it, and a 401 there means the session is already gone
/// — precisely what was being asked for, so refreshing a *new* pair just to
/// retry the revoke would undo the logout it is trying to complete.
const Set<String> unauthenticatedPaths = <String>{
  '/auth/login',
  '/auth/logout',
  '/auth/forgot-password',
  '/auth/reset-password',
  refreshPath,
};

/// The single place the app's token lifecycle lives (PRD §6.2 — "no
/// per-screen retry logic"):
///
///  1. Attaches `Authorization: Bearer <accessToken>` to every request that
///     doesn't already carry an `Authorization` header and isn't one of the
///     [unauthenticatedPaths]. (The refresh call sets its own — bearer =
///     refresh token — so it's left alone here.)
///  2. On a `401` from any other request: refreshes the session once,
///     persists the rotated pair, and retries the original request once.
///     Concurrent 401s share the same in-flight refresh instead of each
///     triggering their own ("pause in-flight requests").
///  3. If refresh fails, clears secure storage and emits [AuthEvent
///     .loggedOut] instead of navigating directly — the router reacts to
///     that stream once the auth feature exists.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.storage,
    required this.authEvents,
  });

  final Dio dio;
  final TokenStorage storage;
  final AuthEventNotifier authEvents;

  static const String _retriedFlag = 'auth_interceptor_retried';

  Future<String>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!unauthenticatedPaths.contains(options.path) &&
        !options.headers.containsKey('Authorization')) {
      final String? accessToken = await storage.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final bool isUnauthenticatedRoute =
        unauthenticatedPaths.contains(request.path);
    final bool alreadyRetried = request.extra[_retriedFlag] == true;

    if (err.response?.statusCode != 401 ||
        isUnauthenticatedRoute ||
        alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      final String accessToken = await _refreshTokens();
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.extra = <String, dynamic>{...request.extra, _retriedFlag: true};

      final Response<dynamic> response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      // Refresh itself failed (already reported/logged out in
      // _performRefresh) — surface the original 401 to the caller.
      handler.next(err);
    }
  }

  /// Runs the refresh call, sharing a single in-flight [Future] across any
  /// requests that hit 401 concurrently rather than each triggering their
  /// own refresh call.
  Future<String> _refreshTokens() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String> _performRefresh() async {
    try {
      final String? refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        throw StateError('No refresh token available.');
      }

      final Response<dynamic> response = await dio.post<dynamic>(
        refreshPath,
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final dynamic data = response.data;
      final String? newAccessToken =
          data is Map<String, dynamic> ? data['accessToken']?.toString() : null;
      final String? newRefreshToken =
          data is Map<String, dynamic> ? data['refreshToken']?.toString() : null;
      if (newAccessToken == null || newRefreshToken == null) {
        throw StateError('Malformed refresh response.');
      }

      await storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return newAccessToken;
    } catch (_) {
      await storage.clearTokens();
      authEvents.notifyLoggedOut();
      rethrow;
    }
  }
}
