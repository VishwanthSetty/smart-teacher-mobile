import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/playback_token_entity.dart';

void main() {
  test(
    'parses the manifest URL and derives its JWT from the t query param',
    () {
      final PlaybackTokenEntity playback =
          PlaybackTokenEntity.fromJson(<String, dynamic>{
            'videoId': 'video-7',
            'manifestUrl':
                'https://media.example.test/videos/video-7/master.m3u8'
                '?quality=auto&t=header.payload.signature',
            'posterUrl': 'https://media.example.test/videos/video-7/poster.jpg',
            'durationSecs': 125,
            'expiresInSecs': 600,
          });

      expect(playback.manifestUri.scheme, 'https');
      expect(playback.manifestUri.path, '/videos/video-7/master.m3u8');
      expect(playback.playbackToken, 'header.payload.signature');
      expect(playback.expiresInSecs, 600);
    },
  );

  test('percent-decodes the token from the URL instead of a JSON field', () {
    final PlaybackTokenEntity playback = PlaybackTokenEntity.fromJson(
      <String, dynamic>{
        'videoId': 'video-7',
        'manifestUrl':
            'https://media.example.test/master.m3u8?t=encoded%2Etoken%2Evalue',
        'posterUrl': null,
        'durationSecs': null,
        'expiresInSecs': 600,
        'token': 'must-not-be-read',
      },
    );

    expect(playback.playbackToken, 'encoded.token.value');
    expect(playback.posterUrl, isNull);
    expect(playback.durationSecs, isNull);
    expect(playback.toJson(), isNot(contains('token')));
  });

  test('returns null when the manifest URL has no usable t query param', () {
    const PlaybackTokenEntity missing = PlaybackTokenEntity(
      videoId: 'video-7',
      manifestUrl: 'https://media.example.test/master.m3u8',
      posterUrl: null,
      durationSecs: null,
      expiresInSecs: 600,
    );
    const PlaybackTokenEntity empty = PlaybackTokenEntity(
      videoId: 'video-7',
      manifestUrl: 'https://media.example.test/master.m3u8?t=',
      posterUrl: null,
      durationSecs: null,
      expiresInSecs: 600,
    );

    expect(missing.playbackToken, isNull);
    expect(empty.playbackToken, isNull);
  });
}
