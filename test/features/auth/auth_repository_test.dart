import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';

void main() {
  late _CapturingAdapter adapter;
  late DioAuthRepository repository;

  setUp(() {
    adapter = _CapturingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
      ..httpClientAdapter = adapter;
    repository = DioAuthRepository(dio);
  });

  group('logout scope (PRD §5.1.3)', () {
    test('sends the refresh token for this-device logout', () async {
      await repository.logout(
        refreshToken: 'refresh-token',
        accessToken: 'access-token',
      );

      expect(adapter.lastRequest?.path, '/auth/logout');
      expect(adapter.lastRequest?.data, <String, String>{
        'refreshToken': 'refresh-token',
      });
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer access-token',
      );
    });

    test('omits the body for all-devices logout', () async {
      await repository.logout(refreshToken: null, accessToken: 'access-token');

      expect(adapter.lastRequest?.path, '/auth/logout');
      expect(adapter.lastRequest?.data, isNull);
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer access-token',
      );
    });
  });
}

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{}),
      204,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
