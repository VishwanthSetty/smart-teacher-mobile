import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/pagination/paginated_result.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/student_entity.dart';

/// One call to [FakeStudentRepository.fetchStudents], as it was made.
///
/// The roster's filters and its paging are *arguments*, and a response built
/// from the wrong ones can look perfectly plausible — a search that quietly
/// wasn't sent returns the unfiltered list, which is a full screen of students
/// either way. Asserting on these is the only thing that catches it.
class StudentQuery {
  const StudentQuery({
    required this.page,
    required this.limit,
    this.search,
    this.sectionId,
    this.status,
  });

  final int page;
  final int limit;
  final String? search;
  final String? sectionId;
  final StudentStatus? status;

  @override
  String toString() => 'StudentQuery(page: $page, limit: $limit, '
      'search: $search, sectionId: $sectionId, status: $status)';
}

/// Scripted [StudentRepository] for tests.
///
/// Unlike the flat-list fakes, this one *implements* the endpoint rather than
/// replaying a canned answer: it filters and slices [students] the way the
/// server would, so a pagination test can scroll a list of ninety through
/// pages of twenty without hand-building each page.
class FakeStudentRepository implements StudentRepository {
  FakeStudentRepository({
    List<StudentEntity>? students,
    this.error,
    this.laterPageError,
    this.reportTotal = true,
  }) : students = students ?? <StudentEntity>[buildStudent()];

  /// The whole table, unpaged. Mutable so a test can change what the *next*
  /// call answers — pull-to-refresh is only interesting when it differs.
  List<StudentEntity> students;

  /// When set, every call throws this.
  AppError? error;

  /// When set, only calls for page 2 and beyond throw it — the "first pages
  /// are fine, load-more failed" case the footer exists for.
  AppError? laterPageError;

  /// Whether the envelope carries a `total`. With it off, `hasMore` has to fall
  /// back to the shape of the page.
  bool reportTotal;

  /// Every call, in order.
  final List<StudentQuery> calls = <StudentQuery>[];

  int get callCount => calls.length;

  StudentQuery? get lastCall => calls.isEmpty ? null : calls.last;

  @override
  Future<PaginatedResult<StudentEntity>> fetchStudents({
    int page = PaginationConstants.firstPage,
    int limit = PaginationConstants.defaultLimit,
    String? search,
    String? sectionId,
    StudentStatus? status,
  }) async {
    calls.add(
      StudentQuery(
        page: page,
        limit: limit,
        search: search,
        sectionId: sectionId,
        status: status,
      ),
    );

    if (error != null) {
      throw error!;
    }
    if (page > PaginationConstants.firstPage && laterPageError != null) {
      throw laterPageError!;
    }

    final List<StudentEntity> matching = students
        .where((StudentEntity student) => _matches(student, search: search))
        .where(
          (StudentEntity student) =>
              sectionId == null ||
              student.enrollment?.sectionId == sectionId,
        )
        .where(
          (StudentEntity student) => status == null || student.status == status,
        )
        .toList(growable: false);

    final int start = (page - 1) * limit;
    final List<StudentEntity> slice = start >= matching.length
        ? const <StudentEntity>[]
        : matching.skip(start).take(limit).toList(growable: false);

    return PaginatedResult<StudentEntity>(
      items: slice,
      page: page,
      limit: limit,
      total: reportTotal ? matching.length : null,
    );
  }

  bool _matches(StudentEntity student, {required String? search}) {
    if (search == null) {
      return true;
    }
    final String term = search.toLowerCase();
    return student.displayName.toLowerCase().contains(term) ||
        (student.email ?? '').toLowerCase().contains(term);
  }
}

/// One `GET /students` row with sane defaults.
///
/// Defaults to an active, placed student. Pass `unassigned: true` for the
/// unplaced student of §5.5.2 — it drops the whole `enrollment` object, which
/// is the shape the API sends, rather than nulling its fields one by one.
StudentEntity buildStudent({
  String? id,
  String name = 'Zainab Ali',
  String? email,
  String sectionName = 'A',
  String? gradeLevelName = 'Grade 5',
  String? rollNumber = '12',
  StudentStatus status = StudentStatus.active,
  bool unassigned = false,
}) {
  final String resolvedId = id ?? 'student-${name.toLowerCase()}';

  return StudentEntity(
    id: resolvedId,
    name: name,
    email: email ?? '${name.split(' ').first.toLowerCase()}@example.com',
    firstName: name.split(' ').first,
    lastName: name.split(' ').length > 1 ? name.split(' ').last : null,
    status: status,
    enrollment: unassigned
        ? null
        : StudentEnrollmentEntity(
            id: 'enrollment-$resolvedId',
            sectionId: 'section-$sectionName',
            sectionName: sectionName,
            gradeLevelId: gradeLevelName == null ? null : 'grade-$gradeLevelName',
            gradeLevelName: gradeLevelName,
            rollNumber: rollNumber,
          ),
  );
}

/// [count] students named `Student 1 … Student N`, for paging tests.
List<StudentEntity> buildStudents(int count, {String sectionName = 'A'}) {
  return <StudentEntity>[
    for (int i = 1; i <= count; i++)
      buildStudent(
        id: 'student-$i',
        name: 'Student $i',
        email: 'student$i@example.com',
        sectionName: sectionName,
        rollNumber: '$i',
      ),
  ];
}
