import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/classes/domain/class_model.dart';
import '../../features/classes/presentation/class_detail_screen.dart';
import '../../features/classes/presentation/classes_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

/// Route path constants. Referencing these avoids stringly-typed navigation
/// scattered across the codebase.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String classes = '/classes';
  static const String profile = '/profile';
  static const String classDetail = 'detail'; // relative to /classes
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// The single source of truth for navigation in the app.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(state: state, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.classes,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ClassesScreen()),
          routes: [
            GoRoute(
              path: AppRoutes.classDetail,
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) =>
                  ClassDetailScreen(classItem: state.extra as ClassModel),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
