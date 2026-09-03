import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/playback_token_entity.dart';

/// Mints the short-lived HLS URL used to play one entitled video (PRD B1).
abstract class VideoPlaybackRepository {
  /// Throws an [AppError], never a `DioException`.
  Future<PlaybackTokenEntity> fetchPlaybackToken(String videoId);
}

class DioVideoPlaybackRepository implements VideoPlaybackRepository {
  const DioVideoPlaybackRepository(this._dio);

  final Dio _dio;

  static String playbackTokenPath(String videoId) =>
      '/videos/${Uri.encodeComponent(videoId)}/playback-token';

  @override
  Future<PlaybackTokenEntity> fetchPlaybackToken(String videoId) {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(playbackTokenPath(videoId));
      return PlaybackTokenEntity.fromJson(response.data ?? <String, dynamic>{});
    });
  }
}

final Provider<VideoPlaybackRepository> videoPlaybackRepositoryProvider =
    Provider<VideoPlaybackRepository>(
      (Ref ref) => DioVideoPlaybackRepository(ref.watch(dioProvider)),
    );
