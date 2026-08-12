import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/content_node_entity.dart';

/// `GET /curricula/:id/tree` (PRD §5.4.2) — the chapters, sub-topics and
/// content behind one library card.
///
/// **A `404` here is the entitlement answer, not just a missing record.** The
/// backend returns a plain `404` both for "no such curriculum" and for "it
/// exists but this actor isn't entitled to it" (§4), deliberately, so that a
/// single-item read can't leak more than the list does. Nothing in this feature
/// tries to tell the two apart, and the UI must never phrase either as "you're
/// not allowed" — see [NotFoundError], whose message is already generic.
abstract class ContentTreeRepository {
  /// Throws an [AppError] — never a `DioException`.
  ///
  /// A tree with no nodes is a legitimate answer (§6.4), not an error: a
  /// curriculum can be entitled and published with nothing authored in it yet.
  Future<ContentTreeEntity> fetchTree(String curriculumId);
}

class DioContentTreeRepository implements ContentTreeRepository {
  const DioContentTreeRepository(this._dio);

  final Dio _dio;

  static String treePath(String curriculumId) =>
      '/curricula/${Uri.encodeComponent(curriculumId)}/tree';

  @override
  Future<ContentTreeEntity> fetchTree(String curriculumId) {
    return guardApiCall(() async {
      final Response<dynamic> response =
          await _dio.get<dynamic>(treePath(curriculumId));

      return _parse(response.data);
    });
  }

  /// The PRD names the response `ContentTreeEntity` (§5.4.2) without pinning
  /// whether the root is an envelope object or the bare array of chapters, so
  /// both are read. An unparseable body degrades to an empty tree — the
  /// designed "nothing in here yet" state — rather than throwing: the call
  /// succeeded, and a crash would be a worse answer than an empty one.
  ContentTreeEntity _parse(dynamic data) => switch (data) {
        final List<dynamic> nodes => ContentTreeEntity(nodes: _nodes(nodes)),
        final Map<String, dynamic> tree => ContentTreeEntity.fromJson(tree),
        _ => const ContentTreeEntity(),
      };

  List<ContentNodeEntity> _nodes(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(ContentNodeEntity.fromJson)
      .toList(growable: false);
}

final Provider<ContentTreeRepository> contentTreeRepositoryProvider =
    Provider<ContentTreeRepository>(
  (Ref ref) => DioContentTreeRepository(ref.watch(dioProvider)),
);
