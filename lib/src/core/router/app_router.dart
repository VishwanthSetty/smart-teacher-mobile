import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/activity/domain/resource_activity_entity.dart';
import '../../features/activity/presentation/history_screen.dart';
import '../../features/activity/presentation/progress_summary_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/library/presentation/curriculum_tree_screen.dart';
import '../../features/library/presentation/document_reader_screen.dart';
import '../../features/library/presentation/video_player_screen.dart';
import '../../features/notifications/presentation/notification_inbox_screen.dart';
import '../../features/notifications/presentation/notification_preferences_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/saved/presentation/saved_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/tasks/presentation/class_progress_screen.dart';
import '../../features/tasks/presentation/student_task_detail_screen.dart';
import '../../features/tasks/presentation/student_task_report_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/tasks/presentation/task_progress_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../session/session_controller.dart';

/// Route path constants. Referencing these avoids stringly-typed navigation
/// scattered across the codebase.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';

  /// The learning-activity screens. Both are pushed over the shell rather than
  /// being tabs: each is a drill-down reached from a home rail or the profile,
  /// and the tab bar has nothing to offer while you are inside one.
  static const String history = '/history';
  static const String progress = '/progress';

  /// Phase 3–4 destinations that are pushed rather than tabbed.
  ///
  /// [saved] is a tab for the student shell and a pushed route for the
  /// teacher's, whose tab set has no room for it (mobile plan §1); [search] is
  /// a drill-down out of the Library tab's search field.
  static const String saved = '/saved';
  static const String search = '/search';

  /// The two task detail routes. Separate paths because they are separate
  /// endpoints with separate role gates and separate payloads — `/tasks/:id`
  /// returns a task with its assignments, `/me/tasks/:id` returns the one
  /// assignment that is yours. A single route that asked "which am I?" would
  /// put a role decision outside `shellTabsFor`.
  static const String task = '/tasks/:$idParam';
  static const String studentTask = '/my-tasks/:$idParam';

  /// The phase-5 teacher reports.
  ///
  /// Nested under the task they belong to, because both are scoped by it
  /// server-side: `/tasks/:id/progress` and `/tasks/:id/students/:studentId`
  /// are only answerable for a task this teacher created, and a student outside
  /// their class scope is a `404` on the second (backend plan §4.4).
  static const String taskProgress = '/tasks/:$idParam/progress';
  static const String studentReport =
      '/tasks/:$idParam/students/:$studentIdParam';
  static const String classProgress = '/class-progress';

  /// The notification inbox and its settings. Both are actor-scoped reads, so
  /// neither needs a role check to decide what to show.
  static const String notifications = '/notifications';
  static const String notificationPreferences = '/notification-preferences';

  /// The second path parameter, used only by [studentReport].
  static const String studentIdParam = 'studentId';

  /// Which history tab to open on — `video` or `document`. A query parameter
  /// rather than a path segment because it is a preference, not a resource: an
  /// absent or unrecognised value opens the default tab rather than 404ing.
  static const String historyTypeParam = 'type';

  static String historyPath(String type) =>
      '/history?$historyTypeParam=${Uri.encodeComponent(type)}';

  /// The curriculum tree and the video player/document reader it hands off to.
  /// Parameterised, so they are built with the `*Path` helpers below rather
  /// than interpolated at the call site.
  static const String curriculumTree = '/curricula/:$idParam/tree';
  static const String video = '/videos/:$idParam';
  static const String document = '/documents/:$idParam';

  /// The path parameter shared by all three: the record's id.
  static const String idParam = 'id';

  static String curriculumTreePath(String curriculumId) =>
      '/curricula/${Uri.encodeComponent(curriculumId)}/tree';

  static String videoPath(String videoId) =>
      '/videos/${Uri.encodeComponent(videoId)}';

  static String documentPath(String documentId) =>
      '/documents/${Uri.encodeComponent(documentId)}';

  static String taskPath(String taskId) =>
      '/tasks/${Uri.encodeComponent(taskId)}';

  static String studentTaskPath(String taskId) =>
      '/my-tasks/${Uri.encodeComponent(taskId)}';

  static String taskProgressPath(String taskId) =>
      '/tasks/${Uri.encodeComponent(taskId)}/progress';

  static String studentReportPath(String taskId, String studentId) =>
      '/tasks/${Uri.encodeComponent(taskId)}'
      '/students/${Uri.encodeComponent(studentId)}';

  static String loginPath(String role) =>
      '/login?role=${Uri.encodeComponent(role)}';

  /// Query parameter carrying the emailed reset token into
  /// [resetPassword] (PRD §5.1.4; the deep-link scheme itself is the open
  /// question in §9.2).
  static const String resetTokenParam = 'token';

  /// Query parameter used by [splash] to remember where the user was
  /// actually headed while the session is still being read. Without it, a
  /// deep link that lands before startup finishes is silently swallowed by
  /// the splash bounce.
  static const String pendingParam = 'from';

  /// Reachable without a session. Everything not listed here is gated.
  static const Set<String> public = <String>{
    roleSelection,
    login,
    forgotPassword,
    resetPassword,
  };
}

/// The app's router, built off the session gate (PRD §6.6).
///
/// The redirect is deliberately the *only* place navigation reacts to auth
/// state — screens never push `/login` themselves. A forced logout raised by
/// the Dio interceptor flips [sessionControllerProvider], the
/// [refreshListenable] below re-runs this redirect, and whatever screen the
/// user was on is replaced by `/login`.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final _SessionRefreshNotifier refresh = _SessionRefreshNotifier();

  // listen, not watch: a session change must re-run the redirect, not rebuild
  // the router (rebuilding would drop the whole navigation stack).
  ref.listen<SessionStatus>(
    sessionControllerProvider,
    (SessionStatus? previous, SessionStatus next) => refresh.notify(),
  );

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final SessionStatus status = ref.read(sessionControllerProvider);
      final String location = state.matchedLocation;

      // Still reading secure storage. Hold on the splash screen rather than
      // briefly showing the wrong side of the gate — but carry the intended
      // destination along, or a deep link arriving during startup is lost.
      if (status == SessionStatus.unknown) {
        return location == AppRoutes.splash ? null : _parkOnSplash(state.uri);
      }

      // Session resolved. Release whatever was parked on the splash screen,
      // re-checking it against the status we ended up with.
      if (location == AppRoutes.splash) {
        final String? pending =
            state.uri.queryParameters[AppRoutes.pendingParam];
        final String target =
            pending ??
            (status == SessionStatus.authenticated
                ? AppRoutes.home
                : AppRoutes.roleSelection);
        return _gate(status, Uri.parse(target).path) ?? target;
      }

      return _gate(status, location);
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (BuildContext context, GoRouterState state) =>
            const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            LoginScreen(role: state.uri.queryParameters['role'] ?? 'student'),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (BuildContext context, GoRouterState state) =>
            ResetPasswordScreen(
              token: state.uri.queryParameters[AppRoutes.resetTokenParam],
            ),
      ),
      // The role-based shell (§5.7). Its tabs are deliberately not routes —
      // see [AppShell] for why the tab set stays off the URL.
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const AppShell(),
      ),
      // Kept as a standalone route even though the student shell renders the
      // profile as a tab: it is where the teacher shell's profile action
      // pushes, and so the teacher's only path to sign-out.
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(),
      ),
      // History and progress. Both are actor-scoped reads (`/me/activity`,
      // `/me/progress/summary`), so neither needs a role check to decide what
      // to show — the server already answered for whoever is signed in.
      GoRoute(
        path: AppRoutes.history,
        builder: (BuildContext context, GoRouterState state) => HistoryScreen(
          initialType: _historyTypeFrom(
            state.uri.queryParameters[AppRoutes.historyTypeParam],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (BuildContext context, GoRouterState state) =>
            ProgressSummaryScreen(
              // `extra` is a nicety from the screen that pushed this, not a
              // dependency: it does not survive a deep link or a process
              // restart, so the heading falls back to the student wording,
              // which is the one that reads correctly for any actor.
              isTeacherPreparation: state.extra as bool? ?? false,
            ),
      ),
      // Saved and search (phase 3). Both are actor-scoped reads, so neither
      // needs a role check to decide what to show.
      //
      // `extra` carries the one thing each cannot derive: whether to draw the
      // teacher's collections, and whether the filter sheet offers an audience
      // control. It is a nicety, not a dependency — it does not survive a deep
      // link, and both fall back to the narrower, student-shaped variant, which
      // is the one that is correct for any actor.
      GoRoute(
        path: AppRoutes.saved,
        builder: (BuildContext context, GoRouterState state) =>
            SavedScreen(withCollections: state.extra as bool? ?? false),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (BuildContext context, GoRouterState state) =>
            SearchScreen(withAudience: state.extra as bool? ?? false),
      ),
      // The two task details (phase 4).
      GoRoute(
        path: AppRoutes.task,
        builder: (BuildContext context, GoRouterState state) =>
            TaskDetailScreen(
              taskId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
      GoRoute(
        path: AppRoutes.studentTask,
        builder: (BuildContext context, GoRouterState state) =>
            StudentTaskDetailScreen(
              taskId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
      // The phase-5 reports and the notification pair.
      //
      // `/tasks/:id/progress` is declared after `/tasks/:id` and does not
      // shadow it: go_router matches on the full path, so the two are distinct
      // routes rather than one with an optional tail.
      GoRoute(
        path: AppRoutes.taskProgress,
        builder: (BuildContext context, GoRouterState state) =>
            TaskProgressScreen(
              taskId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
      GoRoute(
        path: AppRoutes.studentReport,
        builder: (BuildContext context, GoRouterState state) =>
            StudentTaskReportScreen(
              taskId: state.pathParameters[AppRoutes.idParam] ?? '',
              studentId:
                  state.pathParameters[AppRoutes.studentIdParam] ?? '',
              // The student's name, handed over by the row that pushed this.
              // Like every other `extra` here it is a nicety: the screen falls
              // back to wording that is correct without it.
              studentName: state.extra as String?,
            ),
      ),
      GoRoute(
        path: AppRoutes.classProgress,
        builder: (BuildContext context, GoRouterState state) =>
            const ClassProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationInboxScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationPreferencesScreen(),
      ),
      // The tree and its two content leaves. Pushed over the shell
      // rather than nested in it: they are a drill-down out of the Library
      // tab, and the tab bar has nothing to offer while you are inside one.
      //
      // Each takes its label through `extra` — a nicety from the screen that
      // pushed it, not a dependency. `extra` does not survive a deep link or a
      // process restart, so every one of these screens falls back to a title
      // it can derive on its own.
      GoRoute(
        path: AppRoutes.curriculumTree,
        builder: (BuildContext context, GoRouterState state) =>
            CurriculumTreeScreen(
              curriculumId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
      GoRoute(
        path: AppRoutes.video,
        builder: (BuildContext context, GoRouterState state) =>
            VideoPlayerScreen(
              videoId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
      GoRoute(
        path: AppRoutes.document,
        builder: (BuildContext context, GoRouterState state) =>
            DocumentReaderScreen(
              documentId: state.pathParameters[AppRoutes.idParam] ?? '',
              title: state.extra as String?,
            ),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );

  // Router first: disposing it detaches its listener from [refresh], so the
  // notifier is only torn down once nothing is listening to it.
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});

/// The gate itself, for a session status that has already resolved. Returns
/// the path to redirect to, or `null` to allow [path] through.
String? _gate(SessionStatus status, String path) {
  final bool isPublic = AppRoutes.public.contains(path);

  return switch (status) {
    // Never reached — /splash handles the unresolved case before this.
    SessionStatus.unknown => AppRoutes.splash,

    // Reset-password is exempt: it arrives as an emailed deep link, and
    // completing it revokes every session server-side (PRD §5.1.4), so
    // bouncing a signed-in user to /home would strand them mid-reset.
    SessionStatus.authenticated when path == AppRoutes.resetPassword => null,
    SessionStatus.authenticated =>
      isPublic || path == AppRoutes.splash ? AppRoutes.home : null,

    SessionStatus.unauthenticated => isPublic ? null : AppRoutes.roleSelection,
  };
}

/// Parses `?type=` for the history route.
///
/// Anything unrecognised — including the enum's own `unknown` sentinel, which
/// is a parse fallback and not a tab — answers `null`, so the screen opens on
/// its default tab rather than on nothing.
ActivityResourceType? _historyTypeFrom(String? raw) =>
    switch (raw?.trim().toUpperCase()) {
      'VIDEO' => ActivityResourceType.video,
      'DOCUMENT' => ActivityResourceType.document,
      _ => null,
    };

/// `/splash?from=<the route the user actually wanted>`.
String _parkOnSplash(Uri intended) {
  return Uri(
    path: AppRoutes.splash,
    queryParameters: <String, String>{
      AppRoutes.pendingParam: intended.toString(),
    },
  ).toString();
}

/// Bridges Riverpod's session state to go_router's [Listenable]-based
/// refresh hook.
class _SessionRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
