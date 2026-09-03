import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_token_entity.freezed.dart';
part 'playback_token_entity.g.dart';

/// A short-lived HLS manifest minted by `GET /videos/:id/playback-token`.
///
/// The backend does not return the playback JWT as a separate JSON field. It
/// is carried by the manifest URL's `t` query parameter and exposed here only
/// as the computed [playbackToken] convenience getter.
@freezed
abstract class PlaybackTokenEntity with _$PlaybackTokenEntity {
  const factory PlaybackTokenEntity({
    required String videoId,
    required String manifestUrl,
    required String? posterUrl,
    required int? durationSecs,
    required int expiresInSecs,
  }) = _PlaybackTokenEntity;

  const PlaybackTokenEntity._();

  factory PlaybackTokenEntity.fromJson(Map<String, dynamic> json) =>
      _$PlaybackTokenEntityFromJson(json);

  /// The parsed HLS manifest URL, including its short-lived query token.
  Uri get manifestUri => Uri.parse(manifestUrl);

  /// The JWT embedded in [manifestUrl], or `null` if the URL has no `t` value.
  ///
  /// This is derived client-side and is not part of JSON serialization.
  String? get playbackToken {
    final String? token = manifestUri.queryParameters['t'];
    return token == null || token.isEmpty ? null : token;
  }
}
