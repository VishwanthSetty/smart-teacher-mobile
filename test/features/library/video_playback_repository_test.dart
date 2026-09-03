import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/data/video_playback_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/playback_token_entity.dart';

void main() {
  test('calls the playback-token endpoint and parses its response', () async {
    final _PlaybackAdapter adapter = _PlaybackAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
      ..httpClientAdapter = adapter;
    final DioVideoPlaybackRepository repository = DioVideoPlaybackRepository(
      dio,
    );

    final PlaybackTokenEntity playback = await repository.fetchPlaybackToken(
      'video/7',
    );

    expect(adapter.lastRequest?.path, '/videos/video%2F7/playback-token');
    expect(playback.videoId, 'video/7');
    expect(playback.playbackToken, 'header.payload.signature');
    expect(playback.posterUrl, isNull);
    expect(playback.durationSecs, isNull);
  });
}

class _PlaybackAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'videoId': 'video/7',
        'manifestUrl':
            'https://media.example.test/master.m3u8?t=header.payload.signature',
        'posterUrl': null,
        'durationSecs': null,
        'expiresInSecs': 600,
      }),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
