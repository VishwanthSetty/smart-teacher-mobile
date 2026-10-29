import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/home/data/home_repository.dart';
import 'package:smart_teacher_mobile/src/features/home/domain/home_entity.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.student = const StudentHomeEntity(),
    this.teacher = const TeacherHomeEntity(),
    this.error,
  });

  StudentHomeEntity student;
  TeacherHomeEntity teacher;
  AppError? error;

  int studentCalls = 0;
  int teacherCalls = 0;

  @override
  Future<StudentHomeEntity> fetchStudentHome() async {
    studentCalls++;
    if (error case final AppError failure) {
      throw failure;
    }
    return student;
  }

  @override
  Future<TeacherHomeEntity> fetchTeacherHome() async {
    teacherCalls++;
    if (error case final AppError failure) {
      throw failure;
    }
    return teacher;
  }
}
