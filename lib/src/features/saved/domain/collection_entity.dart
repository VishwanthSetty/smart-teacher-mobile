import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_entity.freezed.dart';
part 'collection_entity.g.dart';

/// One row of `GET /me/collections` (backend plan §1.2) — a **teacher-owned**
/// named grouping, e.g. "Plants — Monday Lesson".
///
/// Students never create one, and the endpoint is role-gated to `TEACHER`
/// (§5.2). Nothing on the client checks that: a student shell simply has no
/// screen that calls it, which is the same rule the rest of the app follows —
/// the server scopes, the client renders what came back.
///
/// [itemCount] is derived from the `bookmarks` the endpoint includes rather
/// than from a count column, because there isn't one; it is read with
/// `readValue` so the list itself is never materialised into an entity the UI
/// would then have to keep in sync with `savedControllerProvider`.
@freezed
abstract class CollectionEntity with _$CollectionEntity {
  const factory CollectionEntity({
    required String id,
    @Default('') String name,
    @Default(0) int sortOrder,
    @JsonKey(name: 'bookmarks', readValue: _readItemCount)
    @Default(0)
    int itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CollectionEntity;

  const CollectionEntity._();

  factory CollectionEntity.fromJson(Map<String, dynamic> json) =>
      _$CollectionEntityFromJson(json);

  /// Never blank — a collection saved with an all-whitespace name would
  /// otherwise render as an unlabelled tab.
  String get displayName {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? 'Untitled collection' : trimmed;
  }

  bool get isEmpty => itemCount == 0;
}

/// Turns the included `bookmarks[]` into its length. A payload that omits the
/// relation reads as zero, which is also how an empty collection renders — the
/// conservative direction, and the same trade the content tree's counts make.
Object? _readItemCount(Map<dynamic, dynamic> json, String key) {
  final Object? value = json[key];
  return value is List<dynamic> ? value.length : 0;
}
