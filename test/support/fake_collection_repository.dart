import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/saved/data/collection_repository.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/collection_entity.dart';

CollectionEntity buildCollection({
  String id = 'collection-1',
  String name = 'Plants — Monday Lesson',
  int sortOrder = 0,
  int itemCount = 0,
}) => CollectionEntity(
  id: id,
  name: name,
  sortOrder: sortOrder,
  itemCount: itemCount,
);

/// **Implements** the endpoint rather than just answering — create, rename and
/// delete all mutate the list — so a test can assert that a rename shows up
/// without stubbing the follow-up read.
class FakeCollectionRepository implements CollectionRepository {
  FakeCollectionRepository({List<CollectionEntity>? collections, this.error})
    : collections = <CollectionEntity>[...?collections];

  List<CollectionEntity> collections;
  AppError? error;

  final List<({String collectionId, String bookmarkId, bool isAdding})> moves =
      <({String collectionId, String bookmarkId, bool isAdding})>[];

  @override
  Future<List<CollectionEntity>> fetchCollections() async {
    _throwIfFailing();
    return List<CollectionEntity>.unmodifiable(collections);
  }

  @override
  Future<CollectionEntity> createCollection(String name) async {
    _throwIfFailing();
    final CollectionEntity created = buildCollection(
      id: 'collection-${collections.length + 1}',
      name: name.trim(),
      sortOrder: collections.length,
    );
    collections = <CollectionEntity>[...collections, created];
    return created;
  }

  @override
  Future<CollectionEntity> renameCollection({
    required String id,
    required String name,
  }) async {
    _throwIfFailing();
    collections = collections
        .map(
          (CollectionEntity row) =>
              row.id == id ? row.copyWith(name: name.trim()) : row,
        )
        .toList();
    return collections.firstWhere((CollectionEntity row) => row.id == id);
  }

  @override
  Future<void> deleteCollection(String id) async {
    _throwIfFailing();
    collections = collections
        .where((CollectionEntity row) => row.id != id)
        .toList();
  }

  @override
  Future<void> moveBookmark({
    required String collectionId,
    required String bookmarkId,
    required bool isAdding,
  }) async {
    moves.add((
      collectionId: collectionId,
      bookmarkId: bookmarkId,
      isAdding: isAdding,
    ));
    _throwIfFailing();
  }

  void _throwIfFailing() {
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
  }
}
