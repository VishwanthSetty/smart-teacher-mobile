import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../profile/domain/me_entity.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../shell/domain/shell_tab.dart';

/// Where a task notification opens, for whoever is holding the phone
/// (mobile plan §5.10: "deep-links resolve against the active role's table").
///
/// A notification's payload carries a `taskId` and nothing about *which* task
/// screen to open — because that is not a property of the notification. The
/// same `TASK_ASSIGNED` row would be `/tasks/:id` for its author and
/// `/my-tasks/:id` for a recipient, and they are different endpoints behind
/// different role gates: routing both through one would `403` half the users.
///
/// So this asks the tab set, exactly as [AppShell] does for its profile action.
/// **It is not a second role check** — the decision still comes from
/// [shellTabsFor], the one function allowed to look at [MeEntity.role]; this
/// only reads which of the two Tasks destinations that function handed out.
///
/// A role with **neither** Tasks tab — the degraded [UserRole.unknown] shell —
/// gets the notification inbox itself, which is where they already are. §5.10's
/// rule is that a link a role cannot open falls back rather than erroring, and
/// pushing a task route such a user cannot read would be exactly the error it
/// forbids.
final Provider<String Function(String taskId)> notificationTaskPathProvider =
    Provider<String Function(String taskId)>((Ref ref) {
      final MeEntity? user = ref.watch(profileControllerProvider).value;
      final List<ShellTab> tabs = shellTabsFor(user?.role ?? UserRole.unknown);

      if (tabs.contains(ShellTab.teacherTasks)) {
        return AppRoutes.taskPath;
      }
      if (tabs.contains(ShellTab.studentTasks)) {
        return AppRoutes.studentTaskPath;
      }
      return (String _) => AppRoutes.notifications;
    });
