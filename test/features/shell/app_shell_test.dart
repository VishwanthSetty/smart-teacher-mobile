import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/classes/presentation/my_classes_screen.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/library_screen.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_screen.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_view.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/roster_screen.dart';
import 'package:smart_teacher_mobile/src/features/shell/domain/shell_tab.dart';
import 'package:smart_teacher_mobile/src/features/shell/presentation/app_shell.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('tab set selection (PRD §5.7)', () {
    test('teacher gets My Classes · Roster · Library', () {
      expect(shellTabsFor(UserRole.teacher), <ShellTab>[
        ShellTab.myClasses,
        ShellTab.roster,
        ShellTab.library,
      ]);
    });

    test('student gets Library · Profile', () {
      expect(shellTabsFor(UserRole.student), <ShellTab>[
        ShellTab.library,
        ShellTab.profile,
      ]);
    });

    test('an unrecognised role degrades to a profile-only shell', () {
      // Not in the PRD's table — the point is that it can't crash and can't
      // silently hand out another role's tabs.
      expect(shellTabsFor(UserRole.unknown), <ShellTab>[ShellTab.profile]);
    });
  });

  group('teacher shell', () {
    testWidgets('renders the three teacher tabs and opens on My Classes',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.teacher);

      expect(_destinationLabels(tester), <String>[
        'My Classes',
        'Roster',
        'Library',
      ]);
      expect(find.byType(MyClassesScreen), findsOneWidget);
      // The app bar names the current tab.
      expect(find.widgetWithText(AppBar, 'My Classes'), findsOneWidget);
    });

    testWidgets('tapping through the tabs swaps the body',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.teacher);

      await _tapTab(tester, 'Roster');
      expect(find.widgetWithText(AppBar, 'Roster'), findsOneWidget);
      expect(find.textContaining('Search and browse the students'),
          findsOneWidget);

      await _tapTab(tester, 'Library');
      expect(find.widgetWithText(AppBar, 'Library'), findsOneWidget);
      expect(
        find.textContaining('Browse the curricula'),
        findsOneWidget,
      );

      await _tapTab(tester, 'My Classes');
      expect(find.widgetWithText(AppBar, 'My Classes'), findsOneWidget);
    });

    testWidgets('has no Profile tab, but reaches the profile from the app bar',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.teacher, name: 'Asha Rao');

      expect(_destinationLabels(tester), isNot(contains('Profile')));

      await tester.tap(find.widgetWithIcon(IconButton, ShellTab.profile.icon));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Asha Rao'), findsOneWidget);
    });

    testWidgets('sign-out stays reachable for a teacher',
        (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpShell(tester, role: UserRole.teacher);

      await tester.tap(find.widgetWithIcon(IconButton, ShellTab.profile.icon));
      await tester.pumpAndSettle();
      await _tapSignOut(tester);

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('no student-only tab is built at all',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.teacher);

      // skipOffstage: false, because the shell's IndexedStack keeps the
      // unselected tabs in the tree — so this checks the tab was never built,
      // not merely that it isn't painted.
      expect(find.byType(ProfileView, skipOffstage: false), findsNothing);
      // Library is a teacher tab too — built, just not the one showing.
      expect(find.byType(LibraryScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(LibraryScreen), findsNothing);
    });
  });

  group('student shell', () {
    testWidgets('renders Library · Profile and opens on Library',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.student);

      expect(_destinationLabels(tester), <String>['Library', 'Profile']);
      expect(find.widgetWithText(AppBar, 'Library'), findsOneWidget);
      expect(find.byType(MyClassesScreen), findsNothing);
      expect(find.byType(RosterScreen), findsNothing);
    });

    testWidgets('the Profile tab shows the profile inline, with one app bar',
        (WidgetTester tester) async {
      await _pumpShell(
        tester,
        role: UserRole.student,
        name: 'Ravi Kumar',
      );

      await _tapTab(tester, 'Profile');

      expect(find.byType(ProfileView), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      // The shell owns the chrome — the tab must not stack a second app bar.
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('signs out from the Profile tab', (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpShell(tester, role: UserRole.student);

      await _tapTab(tester, 'Profile');
      await _tapSignOut(tester);

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('there is no profile app-bar action — Profile is a tab',
        (WidgetTester tester) async {
      await _pumpShell(tester, role: UserRole.student);

      expect(
        find.widgetWithIcon(IconButton, ShellTab.profile.icon),
        findsNothing,
      );
    });
  });

  group('degraded shell', () {
    testWidgets('an unrecognised role still gets a usable shell',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpShell(
        tester,
        // What MeEntity falls back to for a role this build doesn't render.
        role: UserRole.unknown,
      );

      // One tab is nothing to navigate between, so there is no tab bar — but
      // the shell still renders, and sign-out is still reachable.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(ProfileView), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

      await _tapSignOut(tester);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });
  });

  group('role not yet known', () {
    testWidgets('a failed /users/me offers a retry and a way out',
        (WidgetTester tester) async {
      final FakeProfileRepository profile = FakeProfileRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pumpShell(tester, profile: profile);

      // No tab bar: there is no role, so there is no tab set to guess at.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Sign out'), findsOneWidget);

      profile.error = null;
      profile.user = buildMe(role: UserRole.student);
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(_destinationLabels(tester), <String>['Library', 'Profile']);
    });

    testWidgets('the tab set follows the role a refresh returns',
        (WidgetTester tester) async {
      final FakeProfileRepository profile =
          FakeProfileRepository(user: buildMe(role: UserRole.teacher));
      final ProviderContainer container =
          await _pumpShell(tester, profile: profile);

      // Sitting on the third tab, which the student shell doesn't have — the
      // selection has to be clamped rather than blow up on rebuild.
      await _tapTab(tester, 'Library');
      expect(find.widgetWithText(AppBar, 'Library'), findsOneWidget);

      profile.user = buildMe(role: UserRole.student);
      await container.read(profileControllerProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(_destinationLabels(tester), <String>['Library', 'Profile']);
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    });
  });

  group('suspended school (PRD §5.2)', () {
    testWidgets('replaces the whole shell, tab bar included',
        (WidgetTester tester) async {
      await _pumpShell(
        tester,
        profile: FakeProfileRepository(
          user: buildMe(schoolStatus: SchoolStatus.suspended),
        ),
      );

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      // Nothing behind any tab works while the school is suspended, so
      // offering the tabs would only hand out four ways to hit the same 403.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.textContaining('Springfield High'), findsOneWidget);
    });

    testWidgets('takes over an already-open shell mid-session',
        (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpShell(tester, role: UserRole.teacher);
      expect(find.byType(NavigationBar), findsOneWidget);

      final SchoolSuspensionController suspension =
          container.read(schoolSuspensionProvider.notifier);
      suspension.reportSuspendedForbidden();
      suspension.reportSuspendedForbidden();
      await tester.pumpAndSettle();

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('signs out from the suspended shell',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpShell(
        tester,
        profile: FakeProfileRepository(
          user: buildMe(schoolStatus: SchoolStatus.suspended),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

/// Boots the real app on a restored session, which lands on `/home` — i.e. the
/// shell — through the router redirect, exactly as production does.
Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  UserRole? role,
  String name = 'Asha Rao',
  FakeProfileRepository? profile,
}) async {
  assert(
    role == null || profile == null,
    'pass a role or a repository, not both',
  );

  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(
        profile ??
            FakeProfileRepository(
              user: buildMe(role: role ?? UserRole.teacher, name: name),
            ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SmartTeacherApp(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(AppShell), findsOneWidget);
  return container;
}

/// The tab bar's labels, in order — the visible proof of which shell is up.
List<String> _destinationLabels(WidgetTester tester) {
  final Finder bar = find.byType(NavigationBar);
  if (bar.evaluate().isEmpty) {
    return <String>[];
  }

  return tester
      .widget<NavigationBar>(bar)
      .destinations
      .cast<NavigationDestination>()
      .map((NavigationDestination destination) => destination.label)
      .toList();
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}

/// The profile's sign-out button sits below the fold on the test surface —
/// scroll it in rather than tapping at an offset that misses.
Future<void> _tapSignOut(WidgetTester tester) async {
  final Finder button = find.widgetWithText(OutlinedButton, 'Sign out');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
