// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_download_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentDownloadEntity _$DocumentDownloadEntityFromJson(
  Map<String, dynamic> json,
) => _DocumentDownloadEntity(
  url: json['url'] as String,
  expiresInSecs: (json['expiresInSecs'] as num).toInt(),
  fileName: json['fileName'] as String,
);

Map<String, dynamic> _$DocumentDownloadEntityToJson(
  _DocumentDownloadEntity instance,
) => <String, dynamic>{
  'url': instance.url,
  'expiresInSecs': instance.expiresInSecs,
  'fileName': instance.fileName,
};
