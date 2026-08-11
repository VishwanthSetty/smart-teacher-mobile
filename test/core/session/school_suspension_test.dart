import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/network/suspension_interceptor.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';

import '../../support/fake_token_storage.dart';

void main() {
  group('SchoolSuspensionController (PRD §5.2)', () {
    test('one suspension-flavoured 403 is not enough', () {
      final ProviderContainer container = _container();

      container
          .read(schoolSuspensionProvider.notifier)
          .reportSuspendedForbidden();

      // A single 403 can be a role or entitlement refusal that happens to
      // mention suspension. §5.2 asks for the repeated pattern.
      expect(container.read(schoolSuspensionProvider), isFalse);
    });

    test('repeated ones latch the flag', () {
      final ProviderContainer container = _container();
      final SchoolSuspensionController controller =
          container.read(schoolSuspensionProvider.notifier);

      controller.reportSuspendedForbidden();
      controller.reportSuspendedForbidden();

      expect(container.read(schoolSuspensionProvider), isTrue);
    });

    test('a successful authenticated call breaks the streak', () {
      final ProviderContainer container = _container();
      final SchoolSuspensionController controller =
          container.read(schoolSuspensionProvider.notifier);

      controller.reportSuspendedForbidden();
      controller.reportAuthenticatedCallSucceeded();
      controller.reportSuspendedForbidden();

      expect(container.read(schoolSuspensionProvider), isFalse);
    });

    test('a successful call releases an already latched suspension', () {
      final ProviderContainer container = _container();
      final SchoolSuspensionController controller =
          container.read(schoolSuspensionProvider.notifier);

      controller.confirm();
      expect(container.read(schoolSuspensionProvider), isTrue);

      // Reinstated server-side: the app heals without a restart.
      controller.reportAuthenticatedCallSucceeded();
      expect(container.read(schoolSuspensionProvider), isFalse);
    });

    test('confirm() latches immediately — /users/me is the answer', () {
      final ProviderContainer container = _container();

      container.read(schoolSuspensionProvider.notifier).confirm();

      expect(container.read(schoolSuspensionProvider), isTrue);
    });

    test('signing out clears it, so it cannot greet the next user', () async {
      final ProviderContainer container = _container();
      container.read(schoolSuspensionProvider.notifier).confirm();

      await container.read(sessionControllerProvider.notifier).signOut();

      expect(container.read(schoolSuspensionProvider), isFalse);
    });
  });

  group('SuspensionInterceptor', () {
    test('reports a suspended 403 on an authenticated route', () async {
      final _Signals signals = _Signals();
      final Dio dio = _dio(
        signals,
        status: 403,
        message: "Your school's access is suspended.",
      );

      await expectLater(dio.get<dynamic>('/curricula'), throwsA(isA<DioException>()));

      expect(signals.suspended, 1);
      expect(signals.succeeded, 0);
    });

    test('ignores a 403 that is not about suspension', () async {
      final _Signals signals = _Signals();
      final Dio dio = _dio(
        signals,
        status: 403,
        message: 'Teachers cannot edit students.',
      );

      await expectLater(dio.get<dynamic>('/students'), throwsA(isA<DioException>()));

      expect(signals.suspended, 0);
    });

    test('ignores the auth routes — login handles its own suspension',
        () async {
      final _Signals signals = _Signals();
      final Dio dio = _dio(
        signals,
        status: 403,
        message: 'School suspended.',
      );

      await expectLater(
        dio.post<dynamic>('/auth/login'),
        throwsA(isA<DioException>()),
      );

      expect(signals.suspended, 0);
    });

    test('reports success only for authenticated routes', () async {
      final _Signals signals = _Signals();
      final Dio dio = _dio(signals, status: 200, message: 'ok');

      await dio.post<dynamic>('/auth/login');
      expect(signals.succeeded, 0);

      await dio.get<dynamic>('/users/me');
      expect(signals.succeeded, 1);
    });
  });
}

/// Counts what the interceptor reported.
class _Signals {
  int suspended = 0;
  int succeeded = 0;
}

/// A [Dio] whose every call answers with [status] and [message], wired to the
/// interceptor under test. Going through Dio rather than calling `onError`
/// directly means the exception it inspects is one Dio actually built.
Dio _dio(
  _Signals signals, {
  required int status,
  required String message,
}) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
    ..httpClientAdapter = _StubAdapter(status: status, message: message)
    ..interceptors.add(
      SuspensionInterceptor(
        onSuspendedForbidden: () => signals.suspended++,
        onAuthenticatedCallSucceeded: () => signals.succeeded++,
      ),
    );
  return dio;
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.message});

  final int status;
  final String message;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'message': message}),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ProviderContainer _container() {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

