import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_download_entity.freezed.dart';
part 'document_download_entity.g.dart';

/// The existing whole-file response from `GET /documents/:id/download`.
///
/// The document API exposes no page count, MIME type, or byte size. Page count
/// is learned only after the PDF has been parsed by the client-side renderer.
@freezed
abstract class DocumentDownloadEntity with _$DocumentDownloadEntity {
  const factory DocumentDownloadEntity({
    required String url,
    required int expiresInSecs,
    required String fileName,
  }) = _DocumentDownloadEntity;

  factory DocumentDownloadEntity.fromJson(Map<String, dynamic> json) =>
      _$DocumentDownloadEntityFromJson(json);
}
