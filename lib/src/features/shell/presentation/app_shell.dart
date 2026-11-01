import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/student_age_band.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../classes/presentation/my_classes_screen.dart';
import '../../home/presentation/student_home_screen.dart';
import '../../home/presentation/teacher_dashboard_screen.dart';
import '../../library/presentation/library_screen.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../profile/domain/me_entity.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/profile_view.dart';
import '../../roster/presentation/roster_screen.dart';
import '../../saved/presentation/saved_screen.dart';
import '../../tasks/presentation/my_tasks_screen.dart';
import '../../tasks/presentation/teacher_tasks_screen.dart';
import '../domain/shell_tab.dart';

/// The role-based navigation shell (PRD §5.7) — what `/home` actually is.
///
/// There is one shell widget, not two: the *only* thing that differs between
/// the teacher and student experiences is the list [shellTabsFor] returns, and
/// that function is the single place in the app allowed to look at
/// `MeEntity.role`. Adding a role branch anywhere else — a tab body, a route
/// guard, an app-bar action — reintroduces exactly the scattered assumption
/// §5.7 forbids.
///
/// The role comes from [profileControllerProvider], which serves the actor
/// login already cached and only hits the network on a restored session. So on
/// the normal path this paints the right tab set on its first frame, and the
/// loading state below is the restored-session case.
///
/// Tab selection is local widget state over an [IndexedStack] rather than
/// go_router branches. A `StatefulShellRoute` needs its branch list fixed when
/// the router is built, but the tab set isn't known until `/users/me` answers
/// — and a per-tab route reachable by URL would have to answer "what does a
/// student who deep-links to `/roster` see?" with a role check *outside*
/// [shellTabsFor]. Keeping the tabs off the URL keeps the rule intact. Per-tab
/// deep links can come back with the branches if the PRD ever asks for them.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// Index into the *visible* tab list, not into [ShellTab]. Clamped on every
  /// build, because a pull-to-refresh on the profile can change the role — and
  /// so the tab count — under a selection that was valid a moment ago.
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<MeEntity> profile = ref.watch(profileControllerProvider);

    // Pre-empts everything, including the tab bar: while a school is
    // suspended every authenticated call 403s, so there is nothing behind any
    // of the tabs to navigate to (§5.2).
    if (suspended) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appName)),
        body: SafeArea(
          child: SchoolSuspendedView(
            schoolName: profile.value?.school.name,
            onSignOut: () => signOut(ref),
          ),
        ),
      );
    }

    return profile.when(
      data: _buildShell,
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object error, StackTrace _) => _RoleUnavailable(
        error: AppError.from(error),
        onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        onSignOut: () => signOut(ref),
      ),
    );
  }

  Widget _buildShell(MeEntity user) {
    final List<ShellTab> tabs = shellTabsFor(user.role);
    final int index = _selected.clamp(0, tabs.length - 1);
    final ShellTab current = tabs[index];
    final bool isStudentShell =
        tabs.contains(ShellTab.library) &&
        tabs.contains(ShellTab.profile) &&
        !tabs.contains(ShellTab.myClasses) &&
        !tabs.contains(ShellTab.roster);
    final StudentAgeBand? studentAgeBand = isStudentShell
        ? StudentAgeBand.fromGradeRank(user.enrollment?.gradeLevelRank)
        : null;
    // The Play register (Pre-primary to Grade 5) gets the floating clay tab
    // bar; Focus and Teach share the flat one from the theme.
    final bool isPlay =
        studentAgeBand == StudentAgeBand.explorers ||
        studentAgeBand == StudentAgeBand.learners;
    // Home tabs draw their own greeting header — bell and, for the teacher,
    // the profile button included — so the shell draws no app bar over them.
    final bool ownHeader =
        current == ShellTab.studentHome || current == ShellTab.teacherHome;

    return Scaffold(
      backgroundColor: isPlay ? AppColors.cloud : null,
      appBar: ownHeader
          ? null
          : AppBar(
              title: Text(current.label),
              actions: <Widget>[
                // The notification inbox (mobile plan §5.10). An app-bar action for
                // **both** shells rather than a tab: every tab set is already at five
                // destinations, which is a bottom bar's limit, and the inbox is a
                // place you visit when the badge says to rather than one you navigate
                // between. It is not a role branch — both roles get the same action,
                // because `/me/notifications` is actor-scoped and answers for
                // whoever is signed in.
                const NotificationBell.appBar(),
                // Only for a tab set that has no Profile tab of its own — i.e. the
                // teacher's. Without it a teacher could never reach sign-out, which
                // lives on the profile screen (§5.1.3). Derived from the tab list,
                // so it is still not a role check.
                if (!tabs.contains(ShellTab.profile))
                  IconButton(
                    icon: Icon(ShellTab.profile.icon),
                    tooltip: ShellTab.profile.label,
                    onPressed: () => context.push(AppRoutes.profile),
                  ),
              ],
            ),
      // IndexedStack, so switching tabs keeps each one's scroll position and
      // loaded data instead of rebuilding it from scratch every tap.
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: <Widget>[
            for (final ShellTab tab in tabs)
              _bodyFor(
                tab,
                user: user,
                studentAgeBand: studentAgeBand,
                studentName: isStudentShell ? user.name : null,
              ),
          ],
        ),
      ),
      // A one-tab shell gets no tab bar: `NavigationBar` asserts on fewer than
      // two destinations, and a bar with a single always-selected item is
      // nothing to navigate anyway. Only the degraded [UserRole.unknown] set
      // is that short today.
      bottomNavigationBar: tabs.length < 2
          ? null
          : _ShellNavigationBar(
              tabs: tabs,
              index: index,
              isPlay: isPlay,
              onSelected: (int next) => setState(() => _selected = next),
            ),
    );
  }

  /// Bodies, not `Scaffold`s — the shell above owns the app bar and the tab
  /// bar, so a tab that brought its own would stack two app bars.
  ///
  /// Exhaustive over [ShellTab]: a new destination is an analyzer error here
  /// until it has something to render.
  Widget _bodyFor(
    ShellTab tab, {
    required MeEntity user,
    required StudentAgeBand? studentAgeBand,
    required String? studentName,
  }) => switch (tab) {
    ShellTab.studentHome => StudentHomeScreen(
      studentName: studentName,
      ageBand: studentAgeBand,
      classLabel: _classLabelOf(user.enrollment),
    ),
    ShellTab.teacherHome => TeacherDashboardScreen(teacherName: user.name),
    ShellTab.myClasses => const MyClassesScreen(),
    ShellTab.roster => const RosterScreen(),
    ShellTab.library => LibraryScreen(
      studentAgeBand: studentAgeBand,
      studentName: studentName,
    ),
    ShellTab.studentTasks => const MyTasksScreen(),
    ShellTab.teacherTasks => const TeacherTasksScreen(),
    // Collections are teacher-only, and the student shell is the only place
    // this tab appears — so the flat variant is the right one here, and the
    // flag is still passed in rather than read from the role.
    ShellTab.saved => const SavedView(),
    ShellTab.profile => const ProfileView(),
  };
}

/// `'Grade 8 · Section B'`, preferring the server-composed label; null for an
/// unplaced student, whose header then has no caption rather than a blank one.
String? _classLabelOf(StudentEnrollmentSummary? enrollment) {
  if (enrollment == null) {
    return null;
  }
  final String composed = enrollment.sectionLabel.trim();
  if (composed.isNotEmpty) {
    return composed;
  }
  final String label = <String>[
    enrollment.gradeLevelName.trim(),
    enrollment.sectionName.trim(),
  ].where((String part) => part.isNotEmpty).join(' · ');
  return label.isEmpty ? null : label;
}

/// The bottom tab bar, in the register's look.
///
/// Always a [NavigationBar] of [NavigationDestination]s — only the chrome
/// differs. Focus and Teach use the flat white bar from the theme (top
/// hairline, Mist pill). Play floats it as a rounded white clay slab with a
/// Brinda Blue blob behind the selected icon, per the Little Learners design.
class _ShellNavigationBar extends StatelessWidget {
  const _ShellNavigationBar({
    required this.tabs,
    required this.index,
    required this.isPlay,
    required this.onSelected,
  });

  final List<ShellTab> tabs;
  final int index;
  final bool isPlay;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Widget bar = NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelected,
      backgroundColor: isPlay ? Colors.transparent : null,
      indicatorColor: isPlay ? AppColors.brindaBlue : null,
      indicatorShape: isPlay
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
          : null,
      height: isPlay ? 76 : null,
      destinations: <Widget>[
        for (final ShellTab tab in tabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(
              tab.selectedIcon,
              color: isPlay ? AppColors.white : null,
            ),
            label: tab.label,
          ),
      ],
    );

    if (!isPlay) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkOutline : AppColors.line,
            ),
          ),
        ),
        child: bar,
      );
    }

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: <BoxShadow>[
            const BoxShadow(color: AppColors.playLip, offset: Offset(0, 6)),
            BoxShadow(
              color: AppColors.deepBlueDark.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: bar,
        ),
      ),
    );
  }
}

/// Shown when `GET /users/me` failed on a restored session, so there is no
/// role and therefore no tab set to render.
///
/// Sign-out sits next to the retry because this state can be terminal — if the
/// call keeps failing there is no other way out of the app, and for a teacher
/// the profile screen (the usual home of sign-out) is behind an app-bar action
/// that this state never gets to draw.
class _RoleUnavailable extends StatelessWidget {
  const _RoleUnavailable({
    required this.error,
    required this.onRetry,
    required this.onSignOut,
  });

  final AppError error;
  final Future<void> Function() onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    error.displayMessage,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  FilledButton.tonal(
                    onPressed: () => onRetry(),
                    child: const Text('Try again'),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  TextButton(
                    onPressed: onSignOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
