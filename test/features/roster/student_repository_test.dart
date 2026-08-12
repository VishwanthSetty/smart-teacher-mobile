import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/pagination/paginated_result.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/student_entity.dart';

/// PRD §5.5.2 / §6.5 — `GET /students`, the app's only paginated call.
void main() {
  late _CapturingAdapter adapter;
  late DioStudentRepository repository;

  setUp(() {
    adapter = _CapturingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
      ..httpClientAdapter = adapter;
    repository = DioStudentRepository(dio);
  });

  group('query parameters', () {
    test('sends page and limit, defaulting the limit to 20', () async {
      await repository.fetchStudents();

      expect(adapter.lastRequest?.path, '/students');
      expect(
        adapter.lastRequest?.queryParameters,
        <String, dynamic>{'page': 1, 'limit': 20},
      );
    });

    test('sends every filter it is given', () async {
      await repository.fetchStudents(
        page: 3,
        limit: 50,
        search: 'zainab',
        sectionId: 'section-1',
        status: StudentStatus.pending,
      );

      expect(adapter.lastRequest?.queryParameters, <String, dynamic>{
        'page': 3,
        'limit': 50,
        'search': 'zainab',
        'sectionId': 'section-1',
        'status': 'PENDING',
      });
    });

    test('omits a blank filter rather than sending it empty', () async {
      // `?sectionId=` is a parameter the server is free to read as "no filter",
      // and `?search=` as a term that matches nothing. Neither guess should be
      // made from an empty text field.
      await repository.fetchStudents(search: '   ', sectionId: '');

      expect(
        adapter.lastRequest?.queryParameters,
        <String, dynamic>{'page': 1, 'limit': 20},
      );
    });

    test('never sends a status the server did not give us', () async {
      await repository.fetchStudents(status: StudentStatus.unknown);

      expect(adapter.lastRequest?.queryParameters.containsKey('status'), false);
    });

    test('clamps the limit to the documented maximum of 100', () async {
      await repository.fetchStudents(limit: 500);

      expect(adapter.lastRequest?.queryParameters['limit'], 100);
    });

    test('clamps a page below one', () async {
      await repository.fetchStudents(page: 0);

      expect(adapter.lastRequest?.queryParameters['page'], 1);
    });
  });

  group('parsing', () {
    test('maps an envelope into a page, including an unplaced student',
        () async {
      adapter.body = <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'student-1',
            'name': 'Zainab Ali',
            'email': 'zainab@example.com',
            'status': 'ACTIVE',
            'enrollment': <String, dynamic>{
              'sectionId': 'section-1',
              'sectionName': 'A',
              'gradeLevelName': 'Grade 5',
              'rollNumber': '12',
            },
          },
          <String, dynamic>{
            'id': 'student-2',
            'name': 'Ravi Kumar',
            'status': 'PENDING',
            'enrollment': null,
          },
        ],
        'meta': <String, dynamic>{'page': 1, 'limit': 20, 'total': 2},
      };

      final PaginatedResult<StudentEntity> page =
          await repository.fetchStudents();

      expect(page.items.first.sectionLabel, 'Grade 5 - A');
      expect(page.items.last.isUnassigned, isTrue);
      expect(page.total, 2);
      expect(page.hasMore, isFalse);
    });

    test('an empty page is data, not an error (§6.4)', () async {
      adapter.body = <String, dynamic>{
        'data': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{'total': 0},
      };

      expect((await repository.fetchStudents()).items, isEmpty);
    });

    test('a DioException never escapes the data layer (§6.3)', () async {
      adapter
        ..status = 403
        ..body = <String, dynamic>{'message': 'Forbidden'};

      await expectLater(
        repository.fetchStudents(),
        throwsA(isA<ForbiddenError>()),
      );
    });
  });
}

/// Records the request Dio was about to make and answers it from [body],
/// without a socket.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  Object body = <String, dynamic>{
    'data': <Map<String, dynamic>>[],
    'meta': <String, dynamic>{'page': 1, 'limit': 20, 'total': 0},
  };
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
