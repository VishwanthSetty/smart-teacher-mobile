import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/role_selection_screen.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/teacher_assignment_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/current_user_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_screen.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/shell/domain/shell_tab.dart';
import 'package:smart_teacher_mobile/src/features/shell/presentation/app_shell.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_section_repository.dart';
import '../../support/fake_student_repository.dart';
import '../../support/fake_teacher_assignment_repository.dart';
import '../../support/fake_token_storage.dart';

/// Signing out and back in as somebody else within one process (PRD §5.7).
///
/// The shell reads its role off `profileControllerProvider`, which — like
/// every other session-scoped cache — is not auto-disposing, so nothing tore
/// it down when the first session ended. Without a reset, the second actor
/// inherited the first one's profile and a student landed in the teacher
/// shell.
void main() {
  testWidgets('a student signing in after a teacher gets the student shell',
      (WidgetTester tester) async {
    final FakeProfileRepository profile = FakeProfileRepository(
      user: buildMe(
        id: 'teacher-1',
        name: 'Asha Rao',
        email: 'asha@springfield.edu',
        role: UserRole.teacher,
      ),
    );
    final ProviderContainer container = await _pumpApp(tester, profile);

    await _signIn(tester, container, email: 'asha@springfield.edu');

    expect(find.byType(AppShell), findsOneWidget);
    expect(_tab(ShellTab.myClasses), findsOneWidget);
    expect(_tab(ShellTab.roster), findsOneWidget);

    await _signOut(tester);
    expect(find.byType(RoleSelectionScreen), findsOneWidget);

    profile.user = buildMe(
      id: 'student-1',
      name: 'Ravi Kumar',
      email: 'ravi@springfield.edu',
      role: UserRole.student,
    );

    await _signIn(tester, container, email: 'ravi@springfield.edu');

    expect(find.byType(AppShell), findsOneWidget);
    expect(container.read(currentUserProvider)?.role, UserRole.student);
    expect(container.read(profileControllerProvider).value?.id, 'student-1');
    // The teacher-only tabs are gone, not merely unselected.
    expect(_tab(ShellTab.myClasses), findsNothing);
    expect(_tab(ShellTab.roster), findsNothing);
    expect(_tab(ShellTab.library), findsOneWidget);
    expect(_tab(ShellTab.profile), findsOneWidget);
  });
}

/// A tab bar entry, as opposed to the same label appearing in the tab body.
Finder _tab(ShellTab tab) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(tab.label),
    );

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  FakeProfileRepository profile,
) async {
  final ProviderContainer container = ProviderContainer(
    // `Override` isn't exported by flutter_riverpod, so the list stays
    // inferred — matching the existing auth tests.
    overrides: [
      tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(profile),
      // Both shells build every tab up front, so an unoverridden repository
      // here would go to the network.
      curriculumRepositoryProvider.overrideWithValue(FakeCurriculumRepository()),
      teacherAssignmentRepositoryProvider.overrideWithValue(
        FakeTeacherAssignmentRepository(),
      ),
      studentRepositoryProvider.overrideWithValue(FakeStudentRepository()),
      sectionRepositoryProvider.overrideWithValue(FakeSectionRepository()),
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

  return container;
}

Future<void> _signIn(
  WidgetTester tester,
  ProviderContainer container, {
  required String email,
}) async {
  container.read(routerProvider).go(AppRoutes.login);
  await tester.pumpAndSettle();
  expect(find.byType(LoginScreen), findsOneWidget);

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    email,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'correct-horse',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'School code'),
    'springfield',
  );
  await tester.pump();

  await tester.tap(find.byType(FilledButton), warnIfMissed: false);
  await tester.pumpAndSettle();
}

/// Sign-out lives on the profile screen (PRD §5.2). The teacher shell has no
/// Profile tab, so the way there is the app-bar action.
Future<void> _signOut(WidgetTester tester) async {
  await tester.tap(find.widgetWithIcon(IconButton, ShellTab.profile.icon));
  await tester.pumpAndSettle();
  expect(find.byType(ProfileScreen), findsOneWidget);

  final Finder button = find.widgetWithText(FilledButton, 'Sign out');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
