import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_detail_entity.freezed.dart';
part 'content_detail_entity.g.dart';

/// Metadata shared by the entitlement-gated video and document detail reads
/// (PRD §5.4.3).
///
/// The identifiers are retained because they are part of the API contract, but
/// the stub screen only renders human-readable metadata. In particular, it
/// never exposes storage keys or asks for a playback/download URL.
abstract interface class ContentDetailEntity {
  String get id;
  String get title;
  String? get description;
  String get contentNodeId;
  String get contentNodeTitle;
  String get curriculumId;
  String get gradeLevelId;
  String get subjectId;
}

/// The public `GET /videos/:id` response.
///
/// This is deliberately the learner/teacher shape, not the admin ingest shape:
/// status, object-storage keys, renditions, and playback tokens do not belong
/// on this phase's read-only stub.
// TODO(PRD §B1): Future backend improvement: add `posterUrl` to
// `VideoEntity`; until then list rows must use a static placeholder and must
// not mint a playback token per row just to obtain a poster.
@freezed
abstract class VideoEntity with _$VideoEntity implements ContentDetailEntity {
  const factory VideoEntity({
    required String id,
    required String title,
    required String? description,
    required int? durationSecs,
    required String contentNodeId,
    required String contentNodeTitle,
    required String curriculumId,
    required String gradeLevelId,
    required String subjectId,
  }) = _VideoEntity;

  factory VideoEntity.fromJson(Map<String, dynamic> json) =>
      _$VideoEntityFromJson(json);
}

/// The public `GET /documents/:id` response.
///
/// A file name only comes from the optional `/download` endpoint, which is
/// explicitly deferred. The detail screen therefore shows the metadata this
/// endpoint actually returns and offers no open/share action.
@freezed
abstract class DocumentEntity
    with _$DocumentEntity
    implements ContentDetailEntity {
  const factory DocumentEntity({
    required String id,
    required String title,
    required String? description,
    required String contentNodeId,
    required String contentNodeTitle,
    required String curriculumId,
    required String gradeLevelId,
    required String subjectId,
  }) = _DocumentEntity;

  factory DocumentEntity.fromJson(Map<String, dynamic> json) =>
      _$DocumentEntityFromJson(json);
}
