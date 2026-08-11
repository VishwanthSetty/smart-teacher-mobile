import 'package:flutter/material.dart';

import '../../profile/domain/me_entity.dart';

/// A destination in the role-based navigation shell (PRD §5.7).
///
/// The enum is the full union of destinations across both shells; which of
/// them a given user actually sees is decided by [shellTabsFor].
enum ShellTab {
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
/// | Teacher | My Classes · Roster · Library |
/// | Student | Library · Profile |
///
/// [UserRole.unknown] is not in the PRD's table — it is what
/// [MeEntity.role] falls back to when the server sends a role this build
/// doesn't render (a `SCHOOL_ADMIN` signing in on mobile, or a role added
/// later). It gets a Profile-only shell: nothing is assumed about what such a
/// user may see, and sign-out stays reachable so they aren't stranded.
List<ShellTab> shellTabsFor(UserRole role) {
  return switch (role) {
    UserRole.teacher => const <ShellTab>[
        ShellTab.myClasses,
        ShellTab.roster,
        ShellTab.library,
      ],
    UserRole.student => const <ShellTab>[
        ShellTab.library,
        ShellTab.profile,
      ],
    UserRole.unknown => const <ShellTab>[ShellTab.profile],
  };
}
