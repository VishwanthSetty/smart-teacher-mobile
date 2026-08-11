import 'package:dio/dio.dart';

import '../errors/app_error.dart';
import 'auth_interceptor.dart';

/// Watches every authenticated call for the suspended-school pattern
/// (PRD §5.2).
///
/// A suspended school 403s each subsequent call, so the signal is only
/// recognisable across calls — no single repository can see it. Putting the
/// observation in the shared Dio pipeline means every endpoint feeds the
/// detector without having to remember to, which is the same reasoning that
/// keeps the token lifecycle in [AuthInterceptor].
///
/// It is purely an observer: it never resolves, rejects, or rewrites anything,
/// so removing it would change no request's outcome.
///
/// Note what it does *not* do — branch on `403` itself. The status code is
/// read in exactly one place (§6.3), so this asks [AppError.fromDioException]
/// what the failure is and pattern-matches the answer. A future change to how
/// the API signals suspension lands there, not here.
class SuspensionInterceptor extends Interceptor {
  SuspensionInterceptor({
    required this.onSuspendedForbidden,
    required this.onAuthenticatedCallSucceeded,
  });

  /// A `403` the error mapper reads as a suspension.
  final void Function() onSuspendedForbidden;

  /// Any successful authenticated response — proof the school is answering.
  final void Function() onAuthenticatedCallSucceeded;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_isUnauthenticatedRoute(response.requestOptions)) {
      onAuthenticatedCallSucceeded();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_isUnauthenticatedRoute(err.requestOptions)) {
      if (AppError.fromDioException(err)
          case ForbiddenError(isSchoolSuspended: true)) {
        onSuspendedForbidden();
      }
    }
    handler.next(err);
  }

  /// The auth routes are exempt for the same reason [AuthInterceptor] leaves
  /// them alone: they run without a session, so their outcomes say nothing
  /// about the signed-in user's school. Login's own suspended-school `403` is
  /// handled by the login flow (§5.1.1), which refuses the session outright.
  bool _isUnauthenticatedRoute(RequestOptions options) =>
      unauthenticatedPaths.contains(options.path);
}
