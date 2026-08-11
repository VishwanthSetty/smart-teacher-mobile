import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';

void main() {
  group('status mapping', () {
    test('401 maps to UnauthorizedError with the API message', () {
      final AppError error = AppError.fromDioException(
        _dioError(401, <String, dynamic>{'message': 'Invalid credentials'}),
      );

      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Invalid credentials');
      expect(error.statusCode, 401);
    });

    test('403 maps to ForbiddenError, not suspended by default', () {
      final AppError error = AppError.fromDioException(
        _dioError(403, <String, dynamic>{'message': 'Teachers only'}),
      );

      expect(error, isA<ForbiddenError>());
      expect((error as ForbiddenError).isSchoolSuspended, isFalse);
      expect(error.message, 'Teachers only');
    });

    test('403 flags a suspended school from the error code', () {
      final AppError error = AppError.fromDioException(
        _dioError(403, <String, dynamic>{
          'message': 'Forbidden',
          'errorCode': 'SCHOOL_SUSPENDED',
        }),
      );

      expect((error as ForbiddenError).isSchoolSuspended, isTrue);
      expect(error.message, contains('suspended'));
      expect(error.errorCode, 'SCHOOL_SUSPENDED');
    });

    test('403 flags a suspended school from the message as a fallback', () {
      final AppError error = AppError.fromDioException(
        _dioError(403, <String, dynamic>{
          'message': 'This school is suspended',
        }),
      );

      expect((error as ForbiddenError).isSchoolSuspended, isTrue);
    });

    test('404 maps to NotFoundError', () {
      final AppError error = AppError.fromDioException(
        _dioError(404, <String, dynamic>{'message': 'Curriculum not found'}),
      );

      expect(error, isA<NotFoundError>());
      expect(error.message, 'Curriculum not found');
    });

    test('404 with no body stays generic and implies nothing about access', () {
      final AppError error = AppError.fromDioException(_dioError(404, null));

      expect(error, isA<NotFoundError>());
      expect(error.message, "We couldn't find what you were looking for.");
      expect(error.message.toLowerCase(), isNot(contains('allow')));
      expect(error.message.toLowerCase(), isNot(contains('permission')));
    });

    test('429 maps to RateLimitedError and reads the Retry-After hint', () {
      final AppError error = AppError.fromDioException(
        _dioError(
          429,
          <String, dynamic>{'message': 'Too many attempts'},
          headers: <String, List<String>>{
            'retry-after': <String>['120'],
          },
        ),
      );

      expect(error, isA<RateLimitedError>());
      expect((error as RateLimitedError).retryAfter, const Duration(minutes: 2));
    });

    test('429 without a Retry-After header leaves the hint null', () {
      final AppError error = AppError.fromDioException(
        _dioError(429, <String, dynamic>{'message': 'Slow down'}),
      );

      expect((error as RateLimitedError).retryAfter, isNull);
    });

    test('429 ignores a Retry-After given as an HTTP date', () {
      final AppError error = AppError.fromDioException(
        _dioError(
          429,
          <String, dynamic>{'message': 'Slow down'},
          headers: <String, List<String>>{
            'retry-after': <String>['Wed, 21 Oct 2026 07:28:00 GMT'],
          },
        ),
      );

      expect((error as RateLimitedError).retryAfter, isNull);
    });

    test('400 with a list message maps to ValidationError', () {
      final AppError error = AppError.fromDioException(
        _dioError(400, <String, dynamic>{
          'message': <String>['email must be an email', 'password too short'],
          'error': 'Bad Request',
        }),
      );

      expect(error, isA<ValidationError>());
      final ValidationError validation = error as ValidationError;
      expect(validation.fieldErrors, hasLength(2));
      expect(validation.message, 'email must be an email');
      expect(validation.statusCode, 400);
    });

    test('422 with a list message maps to ValidationError', () {
      final AppError error = AppError.fromDioException(
        _dioError(422, <String, dynamic>{
          'message': <String>['schoolSlug is required'],
        }),
      );

      expect(error, isA<ValidationError>());
    });

    test('400 with a plain string message is not a ValidationError', () {
      final AppError error = AppError.fromDioException(
        _dioError(400, <String, dynamic>{'message': 'Malformed request'}),
      );

      expect(error, isA<UnknownError>());
      expect(error.statusCode, 400);
      expect(error.message, 'Malformed request');
    });

    test('500 maps to UnknownError', () {
      final AppError error = AppError.fromDioException(
        _dioError(500, <String, dynamic>{'message': 'Internal server error'}),
      );

      expect(error, isA<UnknownError>());
      expect(error.statusCode, 500);
    });
  });

  group('transport failures', () {
    test('no response maps to NetworkError', () {
      final AppError error = AppError.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(error, isA<NetworkError>());
      expect((error as NetworkError).isTimeout, isFalse);
      expect(error.statusCode, isNull);
    });

    test('a timeout maps to NetworkError flagged as a timeout', () {
      final AppError error = AppError.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect((error as NetworkError).isTimeout, isTrue);
    });
  });

  group('malformed bodies', () {
    test('an HTML body from a proxy falls back to the default message', () {
      final AppError error = AppError.fromDioException(
        _dioError(503, '<html><body>Service Unavailable</body></html>'),
      );

      expect(error, isA<UnknownError>());
      expect(error.message, 'Something went wrong. Please try again.');
    });

    test('a blank message falls back rather than showing empty text', () {
      final AppError error = AppError.fromDioException(
        _dioError(403, <String, dynamic>{'message': '   '}),
      );

      expect(error.message, "You don't have access to this.");
    });
  });

  group('AppError.from', () {
    test('passes an existing AppError through unchanged', () {
      const AppError original = NotFoundError(message: 'gone');

      expect(AppError.from(original), same(original));
    });

    test('maps a DioException', () {
      expect(
        AppError.from(_dioError(401, <String, dynamic>{'message': 'nope'})),
        isA<UnauthorizedError>(),
      );
    });

    test('wraps an arbitrary throw as UnknownError, keeping the cause', () {
      const Object thrown = FormatException('bad json');

      final AppError error = AppError.from(thrown);

      expect(error, isA<UnknownError>());
      expect(error.cause, same(thrown));
    });
  });

  group('guardApiCall', () {
    test('returns the value when the request succeeds', () async {
      expect(await guardApiCall<int>(() async => 42), 42);
    });

    test('converts a DioException into the matching AppError', () async {
      await expectLater(
        guardApiCall<void>(
          () async => throw _dioError(404, <String, dynamic>{'message': 'no'}),
        ),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('rethrows an AppError without double-wrapping', () async {
      await expectLater(
        guardApiCall<void>(
          () async => throw const UnauthorizedError(message: 'expired'),
        ),
        throwsA(isA<UnauthorizedError>()),
      );
    });

    test('wraps a parsing failure as UnknownError', () async {
      await expectLater(
        guardApiCall<void>(() async => throw const FormatException('bad')),
        throwsA(isA<UnknownError>()),
      );
    });
  });

  test('a switch over AppError is exhaustive without a default', () {
    String describe(AppError error) => switch (error) {
          UnauthorizedError() => 'unauthorized',
          ForbiddenError() => 'forbidden',
          NotFoundError() => 'notFound',
          RateLimitedError() => 'rateLimited',
          ValidationError() => 'validation',
          NetworkError() => 'network',
          UnknownError() => 'unknown',
        };

    expect(describe(const NetworkError(message: 'offline')), 'network');
  });
}

DioException _dioError(
  int statusCode,
  dynamic body, {
  Map<String, List<String>>? headers,
}) {
  final RequestOptions options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: body,
      headers: headers == null ? null : Headers.fromMap(headers),
    ),
    type: DioExceptionType.badResponse,
  );
}
