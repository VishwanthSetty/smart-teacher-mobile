import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/data/history_repository.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';

/// A recorded `GET /me/activity` call.
///
/// Recorded for the same reason the student fake records its queries: a filter
/// that quietly wasn't sent returns a plausible-looking screenful either way,
/// and only the arguments catch it.
class HistoryCall {
  const HistoryCall({this.type, this.status, this.cursor, this.limit = 20});

  final ActivityResourceType? type;
  final ActivityProgressStatus? status;
  final String? cursor;
  final int limit;

  @override
  String toString() => 'HistoryCall(type: $type, status: $status, '
      'cursor: $cursor, limit: $limit)';
}

/// Unlike the flat-list fakes, this **implements** the endpoint: it filters by
/// type and status and slices by cursor, so a paging test can scroll a real
/// number of rows through real pages.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({
    List<ResourceActivityEntity>? rows,
    List<ResourceActivityEntity>? continueRows,
    this.error,
  }) : rows = rows ?? <ResourceActivityEntity>[],
       continueRows = continueRows ?? <ResourceActivityEntity>[];

  List<ResourceActivityEntity> rows;
  List<ResourceActivityEntity> continueRows;
  AppError? error;

  final List<HistoryCall> calls = <HistoryCall>[];

  @override
  Future<List<ResourceActivityEntity>> fetchHistory({
    ActivityResourceType? type,
    ActivityProgressStatus? status,
    String? cursor,
    int limit = activityPageLimit,
  }) async {
    calls.add(
      HistoryCall(type: type, status: status, cursor: cursor, limit: limit),
    );
    if (error case final AppError failure) {
      throw failure;
    }

    final List<ResourceActivityEntity> matching = rows
        .where(
          (ResourceActivityEntity row) =>
              (type == null || row.kind == type) &&
              (status == null || row.status == status),
        )
        .toList();

    // The cursor is a row id and the server skips past it, so a cursor that no
    // longer matches anything yields an empty page rather than the first one.
    final int start = cursor == null
        ? 0
        : matching.indexWhere((ResourceActivityEntity row) => row.id == cursor) +
              1;
    if (start <= 0 && cursor != null) {
      return const <ResourceActivityEntity>[];
    }
    return matching.skip(start).take(limit).toList();
  }

  @override
  Future<List<ResourceActivityEntity>> fetchContinueLearning() async {
    if (error case final AppError failure) {
      throw failure;
    }
    return continueRows;
  }
}
