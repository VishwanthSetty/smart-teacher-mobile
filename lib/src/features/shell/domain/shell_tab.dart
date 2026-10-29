import 'package:flutter/material.dart';

import '../../profile/domain/me_entity.dart';

/// A destination in the role-based navigation shell (PRD §5.7).
///
/// The enum is the full union of destinations across both shells; which of
/// them a given user actually sees is decided by [shellTabsFor].
enum ShellTab {
  /// Two Home destinations, not one with a branch behind it.
  ///
  /// `/home/student` and `/home/teacher` are different endpoints returning
  /// different shapes, so *something* has to choose between them. Making that
  /// choice here — as two tab values [shellTabsFor] picks between — keeps it
  /// inside the one function allowed to look at the role. A single `home` tab
  /// whose body asked "am I in the student shell?" would put a role decision
  /// back in the widget layer, which is exactly what §5.7 forbids.
  studentHome(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  teacherHome(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  myClasses(
    label: 'My Classes',
    icon: Icons.class_outlined,
    selectedIcon: Icons.class_,
  ),
  roster(
    label: 'Roster',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  library(
    label: 'Library',
    icon: Icons.local_library_outlined,
    selectedIcon: Icons.local_library,
  ),
  /// Two Tasks destinations, not one — for exactly the reason the two Home
  /// values exist. `/me/tasks` and `/tasks` are different endpoints returning
  /// different shapes (assignments with the task nested, versus tasks with the
  /// assignments nested), so something has to choose; making that choice a tab
  /// value keeps it inside [shellTabsFor].
  studentTasks(
    label: 'My Tasks',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
  ),
  teacherTasks(
    label: 'Tasks',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
  ),
  saved(
    label: 'Saved',
    icon: Icons.bookmark_border,
    selectedIcon: Icons.bookmark,
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  );

  const ShellTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// **The one and only role check in the app** (PRD §5.7).
///
/// Everything downstream — the tab bar, the tab bodies, whether the profile
/// needs an app-bar action to stay reachable — is derived from the list this
/// returns, so no other file has to ask what role the actor has. If a screen
/// ever needs to branch on `UserRole`, that is a signal the branch belongs
/// here as a different tab set instead.
///
/// | Role | Tabs |
/// |---|---|
/// | Teacher | Home · My Classes · Library · Tasks · Roster |
/// | Student | Home · Library · My Tasks · Saved · Profile |
///
/// These are the mobile plan's target tab sets (§1) with two deliberate
/// differences. **Roster** is kept for the teacher — it is PRD §5.5.2 and
/// predates the plan — and **Saved** is not a teacher tab, because a sixth
/// destination would not fit a bottom bar; the teacher reaches Saved and its
/// Collections from the dashboard and the profile, as a pushed `/saved` route.
/// The student's Saved *is* a tab, since their list is the plan's flat grid and
/// they have room for it.
///
/// [UserRole.unknown] is not in the PRD's table — it is what
/// [MeEntity.role] falls back to when the server sends a role this build
/// doesn't render (a `SCHOOL_ADMIN` signing in on mobile, or a role added
/// later). It gets a Profile-only shell: nothing is assumed about what such a
/// user may see, and sign-out stays reachable so they aren't stranded.
List<ShellTab> shellTabsFor(UserRole role) {
  return switch (role) {
    UserRole.teacher => const <ShellTab>[
        ShellTab.teacherHome,
        ShellTab.myClasses,
        ShellTab.library,
        ShellTab.teacherTasks,
        ShellTab.roster,
      ],
    UserRole.student => const <ShellTab>[
        ShellTab.studentHome,
        ShellTab.library,
        ShellTab.studentTasks,
        ShellTab.saved,
        ShellTab.profile,
      ],
    UserRole.unknown => const <ShellTab>[ShellTab.profile],
  };
}
