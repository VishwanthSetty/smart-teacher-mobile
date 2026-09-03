import 'package:smart_teacher_mobile/src/features/library/data/video_playback_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/playback_token_entity.dart';

class FakeVideoPlaybackRepository implements VideoPlaybackRepository {
  FakeVideoPlaybackRepository({List<PlaybackTokenEntity>? tickets, this.error})
    : tickets = tickets ?? <PlaybackTokenEntity>[buildPlaybackTicket()];

  final List<PlaybackTokenEntity> tickets;
  Object? error;
  final List<String> requestedVideoIds = <String>[];

  int get callCount => requestedVideoIds.length;

  @override
  Future<PlaybackTokenEntity> fetchPlaybackToken(String videoId) async {
    requestedVideoIds.add(videoId);
    final Object? failure = error;
    if (failure != null) {
      throw failure;
    }
    final int index = (callCount - 1).clamp(0, tickets.length - 1).toInt();
    return tickets[index];
  }
}

PlaybackTokenEntity buildPlaybackTicket({
  String videoId = 'video-1',
  String token = 'token-1',
  String? posterUrl,
  int? durationSecs = 120,
  int expiresInSecs = 600,
}) => PlaybackTokenEntity(
  videoId: videoId,
  manifestUrl:
      'https://media.example.test/videos/$videoId/master.m3u8?t=$token',
  posterUrl: posterUrl,
  durationSecs: durationSecs,
  expiresInSecs: expiresInSecs,
);
