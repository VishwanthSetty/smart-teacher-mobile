import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/progress_summary_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';

void main() {
  group('ResourceActivityEntity', () {
    test('parses a video row', () {
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{
          'id': 'activity-1',
          'resourceType': 'VIDEO',
          'videoId': 'video-1',
          'status': 'IN_PROGRESS',
          'positionSecs': 412,
          'percent': 68,
          'video': <String, dynamic>{
            'id': 'video-1',
            'title': 'Photosynthesis',
            'durationSecs': 600,
          },
        },
      );

      expect(row.resourceId, 'video-1');
      expect(row.isVideo, isTrue);
      expect(row.title, 'Photosynthesis');
      expect(row.durationSecs, 600);
      expect(row.progressFraction, closeTo(0.68, 0.001));
    });

    test('an unknown status or type falls back rather than throwing', () {
      // One odd row must not fail a whole page of history.
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{
          'id': 'activity-1',
          'resourceType': 'AUDIO',
          'status': 'ARCHIVED',
          'videoId': 'video-1',
        },
      );

      expect(row.resourceType, ActivityResourceType.unknown);
      expect(row.status, ActivityProgressStatus.unknown);
      // Still resolvable, because the id column says what it is.
      expect(row.kind, ActivityResourceType.video);
    });

    test('infers the kind from whichever id is present', () {
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{'id': 'a', 'documentId': 'doc-1'},
      );
      expect(row.isDocument, isTrue);
      expect(row.resourceId, 'doc-1');
    });

    test('falls back to a placeholder title rather than a blank row', () {
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{'id': 'a', 'videoId': 'video-1'},
      );
      expect(row.title, 'Untitled video');
    });

    group('readingLabel', () {
      test('omits the denominator when pageCount is unknown', () {
        // `Document.pageCount` is null for anything ingested before the
        // backend started reading it — guessing would be worse than omitting.
        final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
          <String, dynamic>{'id': 'a', 'documentId': 'd', 'lastPage': 7},
        );
        expect(row.readingLabel, 'page 7');
      });

      test('includes it when the server knows it', () {
        final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
          <String, dynamic>{
            'id': 'a',
            'documentId': 'd',
            'lastPage': 7,
            'pageCount': 24,
          },
        );
        expect(row.readingLabel, 'page 7 of 24');
      });

      test("prefers the row's own snapshot over the live document", () {
        // The snapshot is what a stored percentage was computed against; a
        // re-upload must not retroactively change it.
        final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
          <String, dynamic>{
            'id': 'a',
            'documentId': 'd',
            'lastPage': 7,
            'pageCount': 24,
            'document': <String, dynamic>{'id': 'd', 'pageCount': 40},
          },
        );
        expect(row.readingLabel, 'page 7 of 24');
      });

      test('is null with no page at all', () {
        final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
          <String, dynamic>{'id': 'a', 'documentId': 'd'},
        );
        expect(row.readingLabel, isNull);
      });
    });

    test('a completed row is a full bar regardless of percent', () {
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{
          'id': 'a',
          'videoId': 'v',
          'status': 'COMPLETED',
          'percent': 91,
        },
      );
      expect(row.progressFraction, 1);
    });

    test('converts to a synced cache row', () {
      final ResourceActivityEntity row = ResourceActivityEntity.fromJson(
        <String, dynamic>{
          'id': 'a',
          'videoId': 'v',
          'status': 'COMPLETED',
          'percent': 95,
          'positionSecs': 590,
          'updatedAt': '2026-09-11T10:00:00.000Z',
        },
      );

      final LocalActivity local = row.toLocalActivity();
      expect(local.resourceId, 'v');
      expect(local.status, 'COMPLETED');
      expect(local.percent, 95);
      // Anything that came from the server is synced by definition — that is
      // what the resume chooser reads to tell a cross-device position from
      // this device's own optimistic write.
      expect(local.isSynced, isTrue);
    });
  });

  group('ProgressSummaryEntity', () {
    test('splits the bar from the counts, not from percent', () {
      // `percent` is completed-over-total only, so it cannot describe the
      // middle segment — deriving all three from it would put a rounding
      // error in the bar.
      const ProgressSummaryEntity summary = ProgressSummaryEntity(
        subjectId: 's',
        total: 10,
        notStarted: 5,
        inProgress: 3,
        completed: 2,
        percent: 20,
      );

      final (double notStarted, double inProgress, double completed) =
          summary.segments;
      expect(notStarted, 0.5);
      expect(inProgress, closeTo(0.3, 0.001));
      expect(completed, closeTo(0.2, 0.001));
    });

    test('an empty subject does not divide by zero', () {
      const ProgressSummaryEntity summary = ProgressSummaryEntity(
        subjectId: 's',
      );
      expect(summary.isEmpty, isTrue);
      expect(summary.segments, (0.0, 0.0, 0.0));
    });

    test('names an untitled subject rather than rendering blank', () {
      const ProgressSummaryEntity summary = ProgressSummaryEntity(
        subjectId: 's',
        subjectName: '   ',
      );
      expect(summary.displayName, 'Untitled subject');
    });
  });
}
