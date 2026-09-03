import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';

/// Scripted [ProfileRepository] for tests.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({MeEntity? user, this.error})
    : user = user ?? buildMe();

  /// Mutable so a test can change what the *next* call answers — the profile
  /// screen's pull-to-refresh (PRD §5.2) is only interesting when the second
  /// fetch differs from the first.
  MeEntity user;

  /// When set, [fetchMe] throws this instead of returning [user].
  AppError? error;

  int callCount = 0;

  @override
  Future<MeEntity> fetchMe() async {
    callCount++;
    if (error != null) {
      throw error!;
    }
    return user;
  }
}

/// A `GET /users/me` payload with sane defaults, for tests that only care
/// about one field of it.
MeEntity buildMe({
  String id = 'user-1',
  String name = 'Asha Rao',
  String email = 'asha@springfield.edu',
  UserRole role = UserRole.teacher,
  SchoolStatus schoolStatus = SchoolStatus.active,
  StudentEnrollmentSummary? enrollment,
}) {
  return MeEntity(
    id: id,
    email: email,
    name: name,
    role: role,
    schoolId: 'school-1',
    school: SchoolSummary(
      id: 'school-1',
      name: 'Springfield High',
      slug: 'springfield',
      status: schoolStatus,
    ),
    enrollment: enrollment,
  );
}
