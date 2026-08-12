import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/core/widgets/coming_soon_view.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/teacher_assignment_repository.dart';
import 'package:smart_teacher_mobile/src/features/classes/domain/teacher_assignment_entity.dart';
import 'package:smart_teacher_mobile/src/features/classes/presentation/my_classes_screen.dart';
import 'package:smart_teacher_mobile/src/features/classes/presentation/widgets/assignment_card.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_controller.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_section_repository.dart';
import '../../support/fake_student_repository.dart';
import '../../support/fake_teacher_assignment_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('scoping to the signed-in teacher (PRD §5.5.1)', () {
    testWidgets("passes the teacher's own id from the cached /users/me",
        (WidgetTester tester) async {
      final FakeTeacherAssignmentRepository assignments =
          FakeTeacherAssignmentRepository();

      await _pumpMyClasses(
        tester,
        assignments: assignments,
        me: buildMe(id: 'teacher-42'),
      );

      // The entire point of the screen. A call without this returns every
      // assignment in the school, with a 200 — nothing downstream could tell.
      expect(assignments.teacherIds, <String>['teacher-42']);
    });

    testWidgets('re-reads for the new actor when the profile changes',
        (WidgetTester tester) async {
      final FakeTeacherAssignmentRepository assignments =
          FakeTeacherAssignmentRepository();
      final FakeProfileRepository profile =
          FakeProfileRepository(user: buildMe(id: 'teacher-42'));

      final ProviderContainer container = await _pumpMyClasses(
        tester,
        assignments: assignments,
        profile: profile,
      );

      profile.user = buildMe(id: 'teacher-99');
      await container.read(profileControllerProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(assignments.teacherIds, <String>['teacher-42', 'teacher-99']);
    });

    testWidgets('an identical profile refresh does not re-fetch',
        (WidgetTester tester) async {
      final FakeTeacherAssignmentRepository assignments =
          FakeTeacherAssignmentRepository();
      final FakeProfileRepository profile = FakeProfileRepository();

      final ProviderContainer container = await _pumpMyClasses(
        tester,
        assignments: assignments,
        profile: profile,
      );

      await container.read(profileControllerProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(assignments.callCount, 1);
    });
  });

  group('the two row forms (PRD §5.5.1)', () {
    testWidgets('a normal assignment reads subject — grade - section',
        (WidgetTester tester) async {
      await _pumpMyClasses(
        tester,
        assignments: FakeTeacherAssignmentRepository(
          assignments: <TeacherAssignmentEntity>[
            buildAssignment(
              subjectName: 'Mathematics',
              gradeLevelName: 'Grade 5',
              sectionName: 'A',
            ),
          ],
        ),
      );

      expect(find.text('Mathematics — Grade 5 - A'), findsOneWidget);
    });

    testWidgets('a legacy school-wide grant reads subject — all sections',
        (WidgetTester tester) async {
      await _pumpMyClasses(
        tester,
        assignments: FakeTeacherAssignmentRepository(
          assignments: <TeacherAssignmentEntity>[
            buildAssignment(subjectName: 'Mathematics', schoolWide: true),
          ],
        ),
      );

      expect(find.text('Mathematics — all sections'), findsOneWidget);
      // "all sections" alone reads as "you teach every section" — the caption
      // is what says this is a subject-level grant instead.
      expect(find.textContaining('whole school'), findsOneWidget);
    });

    testWidgets('renders both forms side by side', (WidgetTester tester) async {
      await _pumpMyClasses(
        tester,
        assignments: FakeTeacherAssignmentRepository(
          assignments: <TeacherAssignmentEntity>[
            buildAssignment(
              subjectName: 'Mathematics',
              gradeLevelName: 'Grade 5',
              sectionName: 'A',
            ),
            buildAssignment(
              id: 'assignment-2',
              subjectName: 'Science',
              schoolWide: true,
            ),
          ],
        ),
      );

      expect(find.byType(AssignmentCard), findsNWidgets(2));
      expect(find.text('Mathematics — Grade 5 - A'), findsOneWidget);
      expect(find.text('Science — all sections'), findsOneWidget);
    });
  });

  group('the other two answers', () {
    testWidgets('no assignments gets a designed empty state, not a placeholder',
        (WidgetTester tester) async {
      await _pumpMyClasses(
        tester,
        assignments: FakeTeacherAssignmentRepository(
          assignments: <TeacherAssignmentEntity>[],
        ),
      );

      expect(find.text('No classes assigned yet'), findsOneWidget);
      // §4: this teacher falls back to the school's *full* entitlement set, so
      // the copy has to explain why the Library tab is not empty too.
      expect(find.textContaining('Library still shows'), findsOneWidget);
      // "Coming soon" means not built yet — a real zero state is not that.
      expect(find.byType(ComingSoonView), findsNothing);
    });

    testWidgets('a failure offers a retry that re-issues the scoped call',
        (WidgetTester tester) async {
      final FakeTeacherAssignmentRepository assignments =
          FakeTeacherAssignmentRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );

      await _pumpMyClasses(
        tester,
        assignments: assignments,
        me: buildMe(id: 'teacher-42'),
      );

      expect(find.text('Could not reach the server.'), findsOneWidget);

      assignments.error = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentCard), findsOneWidget);
      expect(assignments.teacherIds, <String>['teacher-42', 'teacher-42']);
    });

    testWidgets('pull-to-refresh picks up a new assignment',
        (WidgetTester tester) async {
      final FakeTeacherAssignmentRepository assignments =
          FakeTeacherAssignmentRepository(
        assignments: <TeacherAssignmentEntity>[
          buildAssignment(subjectName: 'Mathematics'),
        ],
      );

      await _pumpMyClasses(tester, assignments: assignments);

      assignments.assignments = <TeacherAssignmentEntity>[
        buildAssignment(subjectName: 'Mathematics'),
        buildAssignment(id: 'assignment-2', subjectName: 'Science'),
      ];

      await tester.fling(
        find.byType(AssignmentCard).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentCard), findsNWidgets(2));
    });
  });

  group('suspended school (PRD §5.2)', () {
    testWidgets('replaces the tab body with the one explanatory screen',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpMyClasses(tester);
      expect(find.byType(AssignmentCard), findsOneWidget);

      final SchoolSuspensionController suspension =
          container.read(schoolSuspensionProvider.notifier);
      suspension.reportSuspendedForbidden();
      suspension.reportSuspendedForbidden();
      await tester.pumpAndSettle();

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(AssignmentCard), findsNothing);
    });

    testWidgets('a single suspension-flavoured 403 here does not latch the app',
        (WidgetTester tester) async {
      // Unlike the library, this screen doesn't confirm the latch itself: the
      // interceptor already observes this call, so self-reporting would make
      // one 403 look like the two-in-a-row corroboration. The error state is
      // the right answer until a second call agrees.
      final ProviderContainer container = await _pumpMyClasses(
        tester,
        assignments: FakeTeacherAssignmentRepository(
          error: const ForbiddenError(
            message: "Your school's access is suspended.",
            isSchoolSuspended: true,
          ),
        ),
      );

      expect(container.read(schoolSuspensionProvider), isFalse);
      expect(find.byType(SchoolSuspendedView), findsNothing);
      expect(find.textContaining('suspended'), findsOneWidget);
    });
  });
}

/// Boots the real app on a restored teacher session, which lands on the shell's
/// first tab — My Classes — through the router redirect, exactly as production
/// does.
Future<ProviderContainer> _pumpMyClasses(
  WidgetTester tester, {
  FakeTeacherAssignmentRepository? assignments,
  FakeProfileRepository? profile,
  MeEntity? me,
}) async {
  assert(me == null || profile == null, 'pass a user or a repository, not both');

  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(
        profile ??
            FakeProfileRepository(
              user: me ?? buildMe(role: UserRole.teacher),
            ),
      ),
      teacherAssignmentRepositoryProvider.overrideWithValue(
        assignments ?? FakeTeacherAssignmentRepository(),
      ),
      // The teacher shell's Library and Roster tabs are built up front by the
      // shell's IndexedStack, so without these they would go to the network.
      curriculumRepositoryProvider.overrideWithValue(FakeCurriculumRepository()),
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

  expect(find.byType(MyClassesScreen), findsOneWidget);
  return container;
}
