import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/features/notifications/presentation/notification_deep_link.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_profile_repository.dart';

void main() {
  group('notification deep links (mobile plan §5.10)', () {
    test('a teacher opens the task they authored', () async {
      // `/tasks/:id` and `/my-tasks/:id` are different endpoints behind
      // different role gates. Routing both through one would 403 half the
      // users, so the destination is a property of who is holding the phone.
      expect(
        (await _pathFor(UserRole.teacher))('task-1'),
        AppRoutes.taskPath('task-1'),
      );
    });

    test('a student opens their own assignment', () async {
      expect(
        (await _pathFor(UserRole.student))('task-1'),
        AppRoutes.studentTaskPath('task-1'),
      );
    });

    test('a role with no Tasks tab falls back rather than erroring', () async {
      // §5.10: a link a role cannot open falls back to somewhere it can, and
      // the inbox is where they already are. Pushing a task route such a user
      // cannot read would be exactly the error the rule forbids.
      expect(
        (await _pathFor(UserRole.unknown))('task-1'),
        AppRoutes.notifications,
      );
    });
  });
}

Future<String Function(String)> _pathFor(UserRole role) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...activityOverrides(),
      profileRepositoryProvider.overrideWithValue(
        FakeProfileRepository(user: buildMe(role: role)),
      ),
    ],
  );
  addTearDown(container.dispose);

  // The provider reads the role off the profile, which is the shell's own
  // source — so the decision still comes from `shellTabsFor` and not from a
  // second role check.
  await container.read(profileControllerProvider.future);
  return container.read(notificationTaskPathProvider);
}
