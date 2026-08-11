import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../session/session_controller.dart';

/// Route path constants. Referencing these avoids stringly-typed navigation
/// scattered across the codebase.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';

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
        final String? pending = state.uri.queryParameters[AppRoutes.pendingParam];
        final String target = pending ??
            (status == SessionStatus.authenticated
                ? AppRoutes.home
                : AppRoutes.login);
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
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
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
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
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

    SessionStatus.unauthenticated => isPublic ? null : AppRoutes.login,
  };
}

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
