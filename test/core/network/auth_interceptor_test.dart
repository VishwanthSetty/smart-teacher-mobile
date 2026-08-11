import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/network/auth_event_notifier.dart';
import 'package:smart_teacher_mobile/src/core/network/auth_interceptor.dart';

import '../../support/fake_token_storage.dart';

void main() {
  late Dio dio;
  late _FakeHttpClientAdapter adapter;
  late FakeTokenStorage storage;
  late AuthEventNotifier authEvents;

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    storage = FakeTokenStorage(
      accessToken: 'expired-access',
      refreshToken: 'valid-refresh',
    );
    authEvents = AuthEventNotifier();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(dio: dio, storage: storage, authEvents: authEvents),
    );
  });

  tearDown(() {
    authEvents.dispose();
  });

  test('attaches the stored access token to a normal request', () async {
    adapter.handler = (RequestOptions options) async {
      expect(options.headers['Authorization'], 'Bearer expired-access');
      return _jsonResponse(200, <String, dynamic>{'ok': true});
    };

    final Response<dynamic> response = await dio.get<dynamic>('/ping');

    expect(response.data, <String, dynamic>{'ok': true});
    expect(adapter.requests, hasLength(1));
  });

  test('refreshes once on 401 and retries the original request', () async {
    final List<String> calls = <String>[];
    adapter.handler = (RequestOptions options) async {
      calls.add(options.path);
      if (options.path == refreshPath) {
        expect(options.headers['Authorization'], 'Bearer valid-refresh');
        return _jsonResponse(200, <String, dynamic>{
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        });
      }
      if (options.headers['Authorization'] == 'Bearer expired-access') {
        return _jsonResponse(401, <String, dynamic>{'message': 'expired'});
      }
      expect(options.headers['Authorization'], 'Bearer new-access');
      return _jsonResponse(200, <String, dynamic>{'name': 'Ada'});
    };

    final Response<dynamic> response = await dio.get<dynamic>('/me');

    expect(response.data, <String, dynamic>{'name': 'Ada'});
    expect(calls, <String>['/me', refreshPath, '/me']);
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
  });

  test('concurrent 401s share a single in-flight refresh', () async {
    int refreshCalls = 0;
    adapter.handler = (RequestOptions options) async {
      if (options.path == refreshPath) {
        refreshCalls += 1;
        // Widen the race window so both requests' 401s land before the
        // refresh resolves, proving the second one waited on the first.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return _jsonResponse(200, <String, dynamic>{
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        });
      }
      if (options.headers['Authorization'] == 'Bearer expired-access') {
        return _jsonResponse(401, <String, dynamic>{'message': 'expired'});
      }
      return _jsonResponse(200, <String, dynamic>{'path': options.path});
    };

    final List<Response<dynamic>> responses = await Future.wait(<
        Future<Response<dynamic>>>[
      dio.get<dynamic>('/a'),
      dio.get<dynamic>('/b'),
    ]);

    expect(refreshCalls, 1);
    expect(responses[0].data, <String, dynamic>{'path': '/a'});
    expect(responses[1].data, <String, dynamic>{'path': '/b'});
  });

  test('forces logout when refresh itself fails', () async {
    adapter.handler = (RequestOptions options) async {
      if (options.path == refreshPath) {
        return _jsonResponse(401, <String, dynamic>{
          'message': 'invalid refresh token',
        });
      }
      return _jsonResponse(401, <String, dynamic>{'message': 'expired'});
    };

    final Future<AuthEvent> loggedOut = authEvents.events.first;

    await expectLater(
      dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    expect(await loggedOut, AuthEvent.loggedOut);
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });

  test('never retries more than once, even if the retry also 401s', () async {
    int meCalls = 0;
    adapter.handler = (RequestOptions options) async {
      if (options.path == refreshPath) {
        return _jsonResponse(200, <String, dynamic>{
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        });
      }
      meCalls += 1;
      return _jsonResponse(401, <String, dynamic>{
        'message': 'still unauthorized',
      });
    };

    await expectLater(
      dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    // Original attempt + exactly one retry — no loop.
    expect(meCalls, 2);
  });
}

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
    },
  );
}

/// Minimal fake standing in for the real network so [AuthInterceptor] can be
/// tested without any HTTP mocking package: each test installs a [handler]
/// that inspects the outgoing [RequestOptions] and returns a canned
/// [ResponseBody].
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];
  FutureOr<ResponseBody> Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final FutureOr<ResponseBody> Function(RequestOptions options)? current =
        handler;
    if (current == null) {
      throw StateError('No handler configured for ${options.path}');
    }
    return current(options);
  }

  @override
  void close({bool force = false}) {}
}
