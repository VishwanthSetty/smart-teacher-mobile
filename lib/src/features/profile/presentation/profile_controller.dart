import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/current_user_controller.dart';
import '../data/profile_repository.dart';
import '../domain/me_entity.dart';

/// Backs the profile screen (PRD §5.2).
///
/// Login already fetched `GET /users/me` and put the result in
/// [currentUserProvider], so opening the profile screen must not re-fetch:
/// [build] serves that cached actor and the screen paints immediately. A
/// pull-to-refresh calls [refresh], which is the only thing that goes back to
/// the network — and which writes what it gets back into
/// [currentUserProvider], so the rest of the app (the role-based shell, §5.7)
/// sees the same user this screen is showing.
///
/// Only the restored-session case falls through to a fetch: a user who was
/// signed in at launch never went through the login flow this run, so nothing
/// populated the cache.
///
/// Suspension is reported to [schoolSuspensionProvider] from here rather than
/// left to the widget, because `/users/me` is the authoritative answer
/// (§5.2): a `school.status` of `SUSPENDED`, or a `403` that reads as a
/// suspension, latches the app-wide flag without waiting for the repeat
/// pattern the interceptor watches for.
class ProfileController extends AsyncNotifier<MeEntity> {
  /// Guards against a second pull landing while the first is still in flight.
  bool _refreshing = false;

  @override
  Future<MeEntity> build() async {
    final MeEntity? cached = ref.read(currentUserProvider);
    if (cached != null) {
      _reportSuspension(cached);
      return cached;
    }

    return _fetch();
  }

  /// Pull-to-refresh.
  ///
  /// The state is left alone until the call answers, so the fields stay on
  /// screen instead of blanking out mid-gesture — `RefreshIndicator` is
  /// already showing the progress, and it awaits this future to decide when to
  /// retract. A failure lands as an error state rather than being thrown at
  /// the gesture.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<MeEntity> next = await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<MeEntity> _fetch() async {
    try {
      final MeEntity user = await ref.read(profileRepositoryProvider).fetchMe();

      if (ref.mounted) {
        ref.read(currentUserProvider.notifier).setUser(user);
        _reportSuspension(user);
      }
      return user;
    } on ForbiddenError catch (error) {
      // A 403 on /users/me itself, worded as a suspension, is not a pattern to
      // corroborate — it is the answer.
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }

  void _reportSuspension(MeEntity user) {
    if (user.isSchoolSuspended) {
      ref.read(schoolSuspensionProvider.notifier).confirm();
    }
  }
}

/// `retry: null` turns off Riverpod's automatic exponential retry. A failed
/// profile load is shown to the user with a "Try again" button (and a
/// pull-to-refresh); a background retry loop would re-issue the call behind
/// their back — pointlessly against a suspended school, which 403s every time.
final AsyncNotifierProvider<ProfileController, MeEntity>
    profileControllerProvider =
    AsyncNotifierProvider<ProfileController, MeEntity>(
  ProfileController.new,
  retry: (int retryCount, Object error) => null,
);
