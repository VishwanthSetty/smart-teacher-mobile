import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_node_entity.freezed.dart';
part 'content_node_entity.g.dart';

/// Which of a node's two content lists an item came from.
///
/// Deliberately **not** a JSON field: `GET /curricula/:id/tree` doesn't tag the
/// items, it puts them in `videos[]` or `documents[]`. The kind is therefore a
/// fact about which array was iterated, supplied at render time, and there is
/// no `unknown` fallback because there is no third array to fall into.
enum ContentItemKind { video, document }

/// One playable/readable item hanging off a content node (PRD §5.4.2).
///
/// The tree returns these inline, so a row can be labelled without the flat
/// `/videos` and `/documents` reads (§5.4.3). Only [id] and [title] are relied
/// on: [id] is what the (out-of-scope) player/reader will be handed, and
/// everything else is a subtitle nicety that a leaner payload may omit.
@freezed
abstract class ContentItemEntity with _$ContentItemEntity {
  const factory ContentItemEntity({
    required String id,
    // Defaulted rather than required: a document uploaded without a title
    // should render as one untitled row, not fail the whole tree.
    @Default('') String title,
    String? description,
    // Videos only, and only when the backend has probed the media.
    int? durationSecs,
    // Documents only.
    String? fileName,
  }) = _ContentItemEntity;

  const ContentItemEntity._();

  factory ContentItemEntity.fromJson(Map<String, dynamic> json) =>
      _$ContentItemEntityFromJson(json);

  /// Never empty — [kind] decides the fallback, since "Untitled" alone doesn't
  /// say what the row would have opened.
  String displayTitle(ContentItemKind kind) {
    final String trimmed = title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    final String? file = fileName?.trim();
    if (file != null && file.isNotEmpty) {
      return file;
    }
    return switch (kind) {
      ContentItemKind.video => 'Untitled video',
      ContentItemKind.document => 'Untitled document',
    };
  }
}

/// One node of the recursive curriculum tree (PRD §5.4.2) — a chapter, or a
/// sub-topic of one. The two are the same shape at every depth; only nesting
/// distinguishes them, which is why this is one entity and not two.
///
/// [videoCountDeep] and [documentCountDeep] are **the whole point of this
/// payload**: they already account for the entire subtree, so the UI can grey
/// out or refuse to expand an empty branch without walking [children] itself.
/// Nothing in this feature recomputes them — a client-side walk would be both
/// wasted work and a second, disagreeing source of truth.
@freezed
abstract class ContentNodeEntity with _$ContentNodeEntity {
  const factory ContentNodeEntity({
    required String id,
    @Default('') String title,
    String? description,
    // `children` is the documented shape; `nodes` is tolerated because the PRD
    // (§5.4.2) names the payload without pinning its key, and a wrong guess
    // would silently flatten every tree to its root level. See [_readChildren].
    @JsonKey(readValue: _readChildren)
    @Default(<ContentNodeEntity>[])
    List<ContentNodeEntity> children,
    @Default(<ContentItemEntity>[]) List<ContentItemEntity> videos,
    @Default(<ContentItemEntity>[]) List<ContentItemEntity> documents,
    // Defaulted for the same reason the curriculum counts are (§8.3): a node
    // with nothing in it is a legitimate state, and an omitted zero must not
    // fail the whole tree. A missing count reads as "empty", which is also how
    // the branch renders — the conservative direction.
    @Default(0) int videoCountDeep,
    @Default(0) int documentCountDeep,
  }) = _ContentNodeEntity;

  const ContentNodeEntity._();

  factory ContentNodeEntity.fromJson(Map<String, dynamic> json) =>
      _$ContentNodeEntityFromJson(json);

  /// Everything playable or readable in this branch, subtree included. Straight
  /// from the server's counts — never from [children].
  int get itemCountDeep => videoCountDeep + documentCountDeep;

  /// True when there is nothing anywhere below this node. Such a branch is
  /// greyed out and cannot be opened: expanding it could only reveal more empty
  /// branches.
  bool get isEmptyDeep => itemCountDeep == 0;

  /// Never empty, so a title-less chapter still reads as a row.
  String get displayTitle {
    final String trimmed = title.trim();
    return trimmed.isEmpty ? 'Untitled section' : trimmed;
  }
}

/// The root of `GET /curricula/:id/tree` — the curriculum's chapters, plus
/// whatever the endpoint echoes back about the curriculum itself.
///
/// The labels are nullable because the screen already knows them from the card
/// it was opened from; they exist so a deep link that arrives without that
/// context can still title itself.
@freezed
abstract class ContentTreeEntity with _$ContentTreeEntity {
  const factory ContentTreeEntity({
    String? curriculumId,
    String? subjectName,
    String? gradeLevelName,
    @JsonKey(readValue: _readNodes)
    @Default(<ContentNodeEntity>[])
    List<ContentNodeEntity> nodes,
  }) = _ContentTreeEntity;

  const ContentTreeEntity._();

  factory ContentTreeEntity.fromJson(Map<String, dynamic> json) =>
      _$ContentTreeEntityFromJson(json);

  /// A curriculum with no chapters at all — an expected state (§6.4), not a
  /// failure, and distinct from a curriculum whose chapters are all empty.
  bool get isEmpty => nodes.isEmpty;
}

/// Accepts either key for a node's sub-nodes. See the field's comment.
Object? _readChildren(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['nodes'];

/// The mirror of [_readChildren] for the root envelope: the top-level list has
/// been named both ways too. A bare-array response is handled a layer up, in
/// the repository, since that is a question about the envelope rather than
/// about this object.
Object? _readNodes(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['children'];
