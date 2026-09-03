// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_token_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackTokenEntity _$PlaybackTokenEntityFromJson(Map<String, dynamic> json) =>
    _PlaybackTokenEntity(
      videoId: json['videoId'] as String,
      manifestUrl: json['manifestUrl'] as String,
      posterUrl: json['posterUrl'] as String?,
      durationSecs: (json['durationSecs'] as num?)?.toInt(),
      expiresInSecs: (json['expiresInSecs'] as num).toInt(),
    );

Map<String, dynamic> _$PlaybackTokenEntityToJson(
  _PlaybackTokenEntity instance,
) => <String, dynamic>{
  'videoId': instance.videoId,
  'manifestUrl': instance.manifestUrl,
  'posterUrl': instance.posterUrl,
  'durationSecs': instance.durationSecs,
  'expiresInSecs': instance.expiresInSecs,
};
