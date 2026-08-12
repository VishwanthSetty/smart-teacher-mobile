import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/teacher_assignment_repository.dart';
import 'package:smart_teacher_mobile/src/features/classes/domain/teacher_assignment_entity.dart';

void main() {
  late _CapturingAdapter adapter;
  late Dio dio;
  late DioTeacherAssignmentRepository repository;

  setUp(() {
    adapter = _CapturingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
      ..httpClientAdapter = adapter;
    repository = DioTeacherAssignmentRepository(dio);
  });

  group('scoping (PRD §5.5.1)', () {
    test('sends the teacher id as a query parameter', () async {
      await repository.fetchAssignments(teacherId: 'user-1');

      // The reason this feature has a repository test at all: the endpoint is
      // not auto-scoped, and a call missing this parameter returns the whole
      // school's assignments with a 200 — indistinguishable from success
      // anywhere above the wire.
      expect(adapter.lastRequest?.path, '/teacher-assignments');
      expect(
        adapter.lastRequest?.queryParameters,
        <String, dynamic>{'teacherId': 'user-1'},
      );
    });

    test('refuses to call at all with a blank id', () async {
      await expectLater(
        repository.fetchAssignments(teacherId: '   '),
        throwsA(isA<UnknownError>()),
      );

      // `?teacherId=` is a filter the server may read as no filter, so the
      // unscoped request must never leave the app.
      expect(adapter.lastRequest, isNull);
    });
  });

  group('parsing', () {
    test('maps rows, including a school-wide grant', () async {
      adapter.body = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'assignment-1',
          'teacherId': 'user-1',
          'subjectId': 'subject-1',
          'subjectName': 'Mathematics',
          'sectionId': 'section-1',
          'sectionName': 'A',
          'gradeLevelId': 'grade-5',
          'gradeLevelName': 'Grade 5',
          'sectionLabel': 'Grade 5 - A',
        },
        <String, dynamic>{
          'id': 'assignment-2',
          'teacherId': 'user-1',
          'subjectId': 'subject-2',
          'subjectName': 'Science',
          'sectionId': null,
          'sectionName': null,
          'gradeLevelId': null,
          'gradeLevelName': null,
          'sectionLabel': null,
        },
      ];

      final List<TeacherAssignmentEntity> assignments =
          await repository.fetchAssignments(teacherId: 'user-1');

      expect(assignments, hasLength(2));
      expect(assignments.first.displayLabel, 'Mathematics — Grade 5 - A');
      expect(assignments.last.displayLabel, 'Science — all sections');
    });

    test('an empty array is data, not an error (§6.4)', () async {
      adapter.body = <Map<String, dynamic>>[];

      expect(await repository.fetchAssignments(teacherId: 'user-1'), isEmpty);
    });

    test('a DioException never escapes the data layer (§6.3)', () async {
      adapter.status = 403;
      adapter.body = <String, dynamic>{
        'message': "Your school's access is suspended.",
      };

      await expectLater(
        repository.fetchAssignments(teacherId: 'user-1'),
        throwsA(
          isA<ForbiddenError>().having(
            (ForbiddenError error) => error.isSchoolSuspended,
            'isSchoolSuspended',
            isTrue,
          ),
        ),
      );
    });
  });
}

/// Records the request Dio was about to make and answers it from [body],
/// without a socket.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  Object body = <Map<String, dynamic>>[];
  int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
