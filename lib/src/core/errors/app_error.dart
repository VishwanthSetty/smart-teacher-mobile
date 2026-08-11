import 'package:dio/dio.dart';

/// Every API failure the app can show, as a closed set (PRD §6.3).
///
/// This file is the **only** place HTTP status codes are branched on. Feature
/// code catches nothing lower-level than this: repositories wrap their Dio
/// calls in [guardApiCall] (or catch [DioException] and call
/// [AppError.fromDioException] themselves), and presentation switches over
/// the variants below. A screen that inspects `statusCode`, `DioException`,
/// or `response.data` is a bug — the mapping belongs here so it stays
/// consistent across every endpoint.
///
/// Being `sealed`, a `switch` over an [AppError] is checked for
/// exhaustiveness at compile time, so a new variant added here surfaces as an
/// analyzer error at each call site rather than as a silently missed case:
///
/// ```dart
/// final String label = switch (error) {
///   ForbiddenError(isSchoolSuspended: true) => 'Contact your school admin',
///   RateLimitedError(retryAfter: final Duration? wait) => 'Try again$wait',
///   AppError(message: final String message) => message,
/// };
/// ```
sealed class AppError implements Exception {
  const AppError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.cause,
  });

  /// Maps a failed [DioException] onto exactly one variant. The single
  /// entry point for turning transport failures into app errors.
  factory AppError.fromDioException(DioException exception) {
    final Response<dynamic>? response = exception.response;

    // No HTTP response at all — connectivity, DNS, timeout, cancellation.
    if (response == null) {
      return NetworkError(
        message: _networkMessage(exception.type),
        isTimeout: _isTimeout(exception.type),
        cause: exception,
      );
    }

    final _ApiErrorBody body = _ApiErrorBody.parse(response.data);
    final int status = response.statusCode ?? 0;

    return switch (status) {
      401 => UnauthorizedError(
          message: body.message ??
              'Your session has expired. Please sign in again.',
          errorCode: body.errorCode,
          cause: exception,
        ),
      403 => _forbidden(body, exception),
      404 => NotFoundError(
          // Deliberately generic. The API answers 404 (not 403) for records
          // the caller may not see, so a permission-flavoured message here
          // would leak the existence of records (PRD §4, §6.3).
          message: body.message ?? "We couldn't find what you were looking for.",
          errorCode: body.errorCode,
          cause: exception,
        ),
      429 => RateLimitedError(
          message: body.message ?? 'Too many attempts. Please try again later.',
          retryAfter: _retryAfter(response.headers),
          errorCode: body.errorCode,
          cause: exception,
        ),
      400 || 422 when body.fieldErrors.isNotEmpty => ValidationError(
          message: body.message ?? 'Please check the details you entered.',
          fieldErrors: body.fieldErrors,
          statusCode: status,
          errorCode: body.errorCode,
          cause: exception,
        ),
      _ => UnknownError(
          message: body.message ?? 'Something went wrong. Please try again.',
          statusCode: status,
          errorCode: body.errorCode,
          cause: exception,
        ),
    };
  }

  /// Widens [AppError.fromDioException] to anything a repository might catch,
  /// so callers never have to type-test before mapping. An [AppError] passes
  /// through unchanged; anything else becomes an [UnknownError].
  static AppError from(Object error) => switch (error) {
        final AppError appError => appError,
        final DioException dioError => AppError.fromDioException(dioError),
        _ => UnknownError(
            message: 'Something went wrong. Please try again.',
            cause: error,
          ),
      };

  /// Safe to render directly in the UI: either the API's own message or a
  /// variant-appropriate fallback. Never contains a stack trace or a raw
  /// transport detail.
  final String message;

  /// HTTP status this came from, for logging and telemetry. Feature code
  /// should switch on the variant instead of comparing this.
  final int? statusCode;

  /// The API's machine-readable error identifier when it sends one — useful
  /// for distinguishing endpoint-specific cases (login lockout vs.
  /// forgot-password throttle, PRD §6.3) without matching on prose.
  final String? errorCode;

  /// The originating exception, kept for logging only. Never surface it.
  final Object? cause;

  @override
  String toString() => '$runtimeType($statusCode, $message)';
}

/// `401` — the session is gone. By the time this reaches feature code the
/// interceptor (PRD §6.2) has already attempted its one silent refresh and
/// failed, so the correct response is a forced logout, not a retry.
final class UnauthorizedError extends AppError {
  const UnauthorizedError({
    required super.message,
    super.errorCode,
    super.cause,
  }) : super(statusCode: 401);
}

/// `403` — role, entitlement, or suspension. Check [isSchoolSuspended] before
/// showing a generic message (PRD §5.2, §6.3): a suspended school 403s every
/// subsequent call, and deserves its own screen rather than an error toast on
/// each one.
final class ForbiddenError extends AppError {
  const ForbiddenError({
    required super.message,
    this.isSchoolSuspended = false,
    super.errorCode,
    super.cause,
  }) : super(statusCode: 403);

  final bool isSchoolSuspended;
}

/// `404` — the record isn't there, or isn't visible to this caller. Those two
/// are indistinguishable by design; treat both as "not found".
final class NotFoundError extends AppError {
  const NotFoundError({
    required super.message,
    super.errorCode,
    super.cause,
  }) : super(statusCode: 404);
}

/// `429` — throttled. [retryAfter] carries the server's `Retry-After` hint
/// when it sends one, so the UI can say *when* rather than just "later".
final class RateLimitedError extends AppError {
  const RateLimitedError({
    required super.message,
    this.retryAfter,
    super.errorCode,
    super.cause,
  }) : super(statusCode: 429);

  final Duration? retryAfter;
}

/// `400`/`422` carrying per-field complaints (Nest's `ValidationPipe` returns
/// these as a list). [fieldErrors] is never empty — a `400` without a list
/// falls through to [UnknownError].
final class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    required this.fieldErrors,
    super.statusCode,
    super.errorCode,
    super.cause,
  });

  final List<String> fieldErrors;
}

/// No response reached us: offline, DNS failure, timeout, TLS failure, or a
/// cancelled request. Retrying is meaningful here, unlike most other
/// variants.
final class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    this.isTimeout = false,
    super.cause,
  });

  final bool isTimeout;
}

/// Anything unmapped — 5xx, an unexpected 4xx, or a non-Dio throw. The
/// catch-all exists so `switch` stays exhaustive without a `default`.
final class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.cause,
  });
}

/// Wraps a repository's Dio call so the `DioException` never escapes the data
/// layer. This is the intended shape of every repository method:
///
/// ```dart
/// Future<MeEntity> fetchMe() => guardApiCall(() async {
///       final Response<dynamic> res = await _dio.get<dynamic>('/users/me');
///       return MeEntity.fromJson(res.data as Map<String, dynamic>);
///     });
/// ```
Future<T> guardApiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw AppError.fromDioException(error);
  } on AppError {
    rethrow;
  } catch (error) {
    throw UnknownError(
      message: 'Something went wrong. Please try again.',
      cause: error,
    );
  }
}

/// A `403` is a suspended school when the API says so. Preference order:
/// an explicit error code first, the message text only as a fallback — prose
/// matching is brittle and should disappear once `apps/api` exposes a stable
/// code for this case.
AppError _forbidden(_ApiErrorBody body, DioException exception) {
  final String haystack =
      '${body.errorCode ?? ''} ${body.message ?? ''}'.toLowerCase();
  final bool suspended = haystack.contains('suspend');

  return ForbiddenError(
    message: suspended
        ? "Your school's access is suspended. Contact your school admin."
        : body.message ?? "You don't have access to this.",
    isSchoolSuspended: suspended,
    errorCode: body.errorCode,
    cause: exception,
  );
}

bool _isTimeout(DioExceptionType type) =>
    type == DioExceptionType.connectionTimeout ||
    type == DioExceptionType.sendTimeout ||
    type == DioExceptionType.receiveTimeout;

String _networkMessage(DioExceptionType type) => switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The server took too long to respond. Please try again.',
      DioExceptionType.cancel => 'The request was cancelled.',
      _ => 'Could not reach the server. Check your connection.',
    };

/// `Retry-After` is defined as either a delay in seconds or an HTTP date.
/// Only the seconds form is honoured — the date form needs a trustworthy
/// device clock, and a missing hint degrades to a vaguer message rather than
/// a wrong countdown.
Duration? _retryAfter(Headers headers) {
  final String? raw = headers.value('retry-after');
  final int? seconds = raw == null ? null : int.tryParse(raw.trim());
  return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
}

/// The API's `ApiErrorResponse` (Nest's `HttpExceptionFilter`), normalised.
///
/// `message` arrives as either a single string or a list of validation
/// complaints, and the machine-readable code has appeared under both `error`
/// and `errorCode`. Parsing tolerates all of those and a body that isn't JSON
/// at all — an HTML error page from a proxy must not crash the mapper.
class _ApiErrorBody {
  const _ApiErrorBody({
    this.message,
    this.errorCode,
    this.fieldErrors = const <String>[],
  });

  factory _ApiErrorBody.parse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const _ApiErrorBody();
    }

    final dynamic rawMessage = data['message'];
    final List<String> fieldErrors = rawMessage is List<dynamic>
        ? rawMessage.map((dynamic e) => e.toString()).toList()
        : const <String>[];

    final String? message = switch (rawMessage) {
      final String text when text.trim().isNotEmpty => text,
      final List<dynamic> _ when fieldErrors.isNotEmpty => fieldErrors.first,
      _ => null,
    };

    final Object? rawCode = data['errorCode'] ?? data['error'];

    return _ApiErrorBody(
      message: message,
      errorCode: rawCode?.toString(),
      fieldErrors: fieldErrors,
    );
  }

  final String? message;
  final String? errorCode;
  final List<String> fieldErrors;
}
