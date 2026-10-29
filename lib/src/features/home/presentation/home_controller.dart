import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_repository.dart';
import '../domain/home_entity.dart';

/// Backs the student Home (mobile plan §5.1).
///
/// Always fetches in [build] — nothing earlier in the app caches the
/// aggregate — and an empty result is data, not an error.
class StudentHomeController extends AsyncNotifier<StudentHomeEntity> {
  bool _refreshing = false;

  @override
  Future<StudentHomeEntity> build() => _fetch();

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      // The current state is left alone until the call answers, so a populated
      // home stays on screen instead of blanking mid-gesture.
      final AsyncValue<StudentHomeEntity> next = await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<StudentHomeEntity> _fetch() =>
      ref.read(homeRepositoryProvider).fetchStudentHome();
}

/// Backs the teacher Dashboard (mobile plan §5.7).
class TeacherHomeController extends AsyncNotifier<TeacherHomeEntity> {
  bool _refreshing = false;

  @override
  Future<TeacherHomeEntity> build() => _fetch();

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<TeacherHomeEntity> next = await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<TeacherHomeEntity> _fetch() =>
      ref.read(homeRepositoryProvider).fetchTeacherHome();
}

/// Neither controller confirms the suspension latch.
///
/// `SuspensionInterceptor` already observes both calls, so a screen that also
/// self-reported would turn one suspension-flavoured `403` into the
/// two-in-a-row the interceptor treats as corroboration. These endpoints are
/// role-gated rather than entitlement-scoped, so their `403` has an innocent
/// reading that `/curricula`'s does not.
final AsyncNotifierProvider<StudentHomeController, StudentHomeEntity>
studentHomeControllerProvider =
    AsyncNotifierProvider<StudentHomeController, StudentHomeEntity>(
      StudentHomeController.new,
      retry: (int retryCount, Object error) => null,
    );

final AsyncNotifierProvider<TeacherHomeController, TeacherHomeEntity>
teacherHomeControllerProvider =
    AsyncNotifierProvider<TeacherHomeController, TeacherHomeEntity>(
      TeacherHomeController.new,
      retry: (int retryCount, Object error) => null,
    );
