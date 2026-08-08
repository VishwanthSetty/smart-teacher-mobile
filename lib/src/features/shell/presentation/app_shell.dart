import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

/// A navigation destination in the bottom bar, paired with its route.
class _Destination {
  const _Destination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _destinations = <_Destination>[
  _Destination(
    route: AppRoutes.home,
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Home',
  ),
  _Destination(
    route: AppRoutes.classes,
    icon: Icons.class_outlined,
    selectedIcon: Icons.class_,
    label: 'Classes',
  ),
  _Destination(
    route: AppRoutes.profile,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Profile',
  ),
];

/// Persistent scaffold that hosts the bottom navigation bar and the currently
/// active tab's [child].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  int _indexFor(String location) {
    final index =
        _destinations.indexWhere((d) => location.startsWith(d.route));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexFor(state.uri.path);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final route = _destinations[index].route;
          if (route != _destinations[currentIndex].route) {
            context.go(route);
          }
        },
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
