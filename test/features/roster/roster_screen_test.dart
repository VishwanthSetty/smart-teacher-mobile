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
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/section_entity.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/student_entity.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/roster_controller.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/roster_screen.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/widgets/roster_search_field.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/widgets/student_card.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_section_repository.dart';
import '../../support/fake_student_repository.dart';
import '../../support/fake_teacher_assignment_repository.dart';
import '../../support/fake_token_storage.dart';

/// PRD §5.5.2 — the roster: paginated, searchable, section-filterable, and
/// strictly read-only.
void main() {
  group('the list', () {
    testWidgets('renders a student with their class and roll number',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(
          students: <StudentEntity>[
            buildStudent(name: 'Zainab Ali', rollNumber: '12'),
          ],
        ),
      );

      expect(find.text('Zainab Ali'), findsOneWidget);
      expect(find.text('zainab@example.com'), findsOneWidget);
      expect(find.text('Grade 5 - A'), findsOneWidget);
      expect(find.text('Roll no. 12'), findsOneWidget);
      // The placeholder this screen replaced.
      expect(find.byType(ComingSoonView), findsNothing);
    });

    testWidgets('labels an unplaced student Unassigned',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(
          students: <StudentEntity>[
            buildStudent(name: 'Ravi Kumar', unassigned: true),
          ],
        ),
      );

      // `enrollment: null` is a documented, legitimate state (§5.5.2) — the row
      // has to say so rather than render a blank where the class goes.
      expect(find.text('Unassigned'), findsOneWidget);
    });

    testWidgets('flags a pending invite, and only the exceptions',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(
          students: <StudentEntity>[
            buildStudent(name: 'Zainab Ali'),
            buildStudent(name: 'Ravi Kumar', status: StudentStatus.pending),
          ],
        ),
      );

      expect(find.text('Invite pending'), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });
  });

  group('read-only (PRD §5.5.2)', () {
    testWidgets('offers no way to edit, deactivate or reset a password',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(students: buildStudents(3)),
      );

      // Every write route for a student is SCHOOL_ADMIN-only (§8.6), so none of
      // these may exist here — not disabled, not hidden behind a menu.
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      expect(find.textContaining('Reset password'), findsNothing);
    });

    testWidgets('rows are not tappable — there is nothing behind them',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(students: buildStudents(1)),
      );

      expect(
        find.descendant(
          of: find.byType(StudentCard),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });

  group('pagination (PRD §6.5)', () {
    testWidgets('loads the first page of 20 and asks for the next on scroll',
        (WidgetTester tester) async {
      final FakeStudentRepository students =
          FakeStudentRepository(students: buildStudents(45));

      final ProviderContainer container =
          await _pumpRoster(tester, students: students);

      expect(students.calls.single.page, 1);
      expect(students.calls.single.limit, 20);
      expect(find.text('Student 1'), findsOneWidget);
      expect(_rows(container), hasLength(20));

      await _scrollToBottom(tester);

      // Page 2 was asked for — and, since the fling lands at the bottom of the
      // list with more still behind it, the widget keeps going rather than
      // waiting for another gesture.
      expect(
        students.calls.map((StudentQuery call) => call.page),
        containsAllInOrder(<int>[1, 2]),
      );
      expect(_rows(container).length, greaterThan(20));
      expect(_rows(container).first.displayName, 'Student 1');
    });

    testWidgets('stops at the last page and says how many there were',
        (WidgetTester tester) async {
      final FakeStudentRepository students =
          FakeStudentRepository(students: buildStudents(25));

      await _pumpRoster(tester, students: students);
      await _scrollToBottom(tester);

      expect(find.text('25 students', skipOffstage: false), findsOneWidget);

      // Bumping against the end must not keep firing requests.
      await _scrollToBottom(tester);
      expect(students.callCount, 2);
    });

    testWidgets('a failed later page keeps the rows already on screen',
        (WidgetTester tester) async {
      final FakeStudentRepository students = FakeStudentRepository(
        students: buildStudents(45),
        laterPageError: const NetworkError(message: 'Could not reach.'),
      );

      final ProviderContainer container =
          await _pumpRoster(tester, students: students);
      await _scrollToBottom(tester);

      expect(find.text('Could not reach.', skipOffstage: false), findsOneWidget);
      // The rows are still there, not replaced by the error — the failure is a
      // footer under a list that still works.
      expect(find.byType(StudentCard), findsWidgets);
      expect(_rows(container), hasLength(20));

      // And the failure stops the automatic trigger: only the tap retries.
      final int afterFailure = students.callCount;
      await _scrollToBottom(tester);
      expect(students.callCount, afterFailure);

      students.laterPageError = null;
      await tester.tap(find.widgetWithText(TextButton, 'Load more'));
      await tester.pumpAndSettle();

      expect(_rows(container).length, greaterThan(20));
    });
  });

  group('search', () {
    testWidgets('sends the typed term once the typing stops',
        (WidgetTester tester) async {
      final FakeStudentRepository students = FakeStudentRepository(
        students: <StudentEntity>[
          buildStudent(name: 'Zainab Ali'),
          buildStudent(name: 'Ravi Kumar'),
        ],
      );

      await _pumpRoster(tester, students: students);
      await tester.enterText(find.byType(RosterSearchField), 'zainab');

      // Debounced: the keystroke alone must not have hit the network.
      expect(students.callCount, 1);

      await tester.pump(RosterSearchField.debounce);
      await tester.pumpAndSettle();

      expect(students.lastCall?.search, 'zainab');
      expect(students.lastCall?.page, 1);
      expect(find.text('Zainab Ali'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsNothing);
    });

    testWidgets('a search matching nobody explains itself and offers a way out',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(students: buildStudents(3)),
      );

      await tester.enterText(find.byType(RosterSearchField), 'nobody');
      await tester.pump(RosterSearchField.debounce);
      await tester.pumpAndSettle();

      // Not "your school has no students" — that would be a lie about the
      // school (§6.4).
      expect(find.text('No students match'), findsOneWidget);
      expect(find.text('No students yet'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Student 1'), findsOneWidget);
      expect(find.byType(StudentCard), findsNWidgets(3));
    });

    testWidgets('an empty roster with no filters reads differently',
        (WidgetTester tester) async {
      await _pumpRoster(
        tester,
        students: FakeStudentRepository(students: <StudentEntity>[]),
      );

      expect(find.text('No students yet'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Clear filters'), findsNothing);
      expect(find.byType(ComingSoonView), findsNothing);
    });
  });

  group('section filter (PRD §5.5.2, §5.5.3)', () {
    testWidgets('picks a section and re-queries from page one',
        (WidgetTester tester) async {
      final FakeStudentRepository students = FakeStudentRepository(
        students: <StudentEntity>[
          buildStudent(name: 'Zainab Ali', sectionName: 'A'),
          buildStudent(name: 'Ravi Kumar', sectionName: 'B'),
        ],
      );
      final FakeSectionRepository sections = FakeSectionRepository(
        sections: <SectionEntity>[
          buildSection(name: 'A'),
          buildSection(name: 'B', label: 'Grade 5 - B'),
        ],
      );

      await _pumpRoster(tester, students: students, sections: sections);

      await tester.tap(find.text('All sections'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grade 5 - B').last);
      await tester.pumpAndSettle();

      // The id is an opaque filter (§5.5.3) — passed through untouched.
      expect(students.lastCall?.sectionId, 'section-B');
      expect(students.lastCall?.page, 1);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Zainab Ali'), findsNothing);
      // The chip names the active filter rather than still saying "all".
      expect(find.text('Grade 5 - B'), findsWidgets);
    });

    testWidgets('the sections load only when the picker is opened',
        (WidgetTester tester) async {
      final FakeSectionRepository sections = FakeSectionRepository();

      await _pumpRoster(tester, sections: sections);
      expect(sections.callCount, 0);

      await tester.tap(find.text('All sections'));
      await tester.pumpAndSettle();

      expect(sections.callCount, 1);
    });

    testWidgets('a failed section list leaves the roster alone',
        (WidgetTester tester) async {
      final FakeSectionRepository sections = FakeSectionRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );

      await _pumpRoster(
        tester,
        students: FakeStudentRepository(students: buildStudents(2)),
        sections: sections,
      );

      await tester.tap(find.text('All sections'));
      await tester.pumpAndSettle();

      // The picker explains itself; the students behind it are a different
      // call and are still listed.
      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.byType(StudentCard), findsNWidgets(2));
    });
  });

  group('the other answers', () {
    testWidgets('a failed first page offers a retry',
        (WidgetTester tester) async {
      final FakeStudentRepository students = FakeStudentRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );

      await _pumpRoster(tester, students: students);

      expect(find.text('Could not reach the server.'), findsOneWidget);
      // The filters stay usable while the list is broken.
      expect(find.byType(RosterSearchField), findsOneWidget);

      students
        ..error = null
        ..students = buildStudents(2);
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(StudentCard), findsNWidgets(2));
    });

    testWidgets('a suspended school replaces the tab body',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpRoster(tester);
      expect(find.byType(StudentCard), findsOneWidget);

      final SchoolSuspensionController suspension =
          container.read(schoolSuspensionProvider.notifier);
      suspension.reportSuspendedForbidden();
      suspension.reportSuspendedForbidden();
      await tester.pumpAndSettle();

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(StudentCard), findsNothing);
      expect(find.byType(RosterSearchField), findsNothing);
    });

    testWidgets('a single suspension-flavoured 403 does not latch the app',
        (WidgetTester tester) async {
      // Like My Classes and unlike the library: the interceptor already
      // observes this call, so self-reporting would fake the corroboration.
      final ProviderContainer container = await _pumpRoster(
        tester,
        students: FakeStudentRepository(
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

/// Boots the real app on a restored teacher session and switches to the Roster
/// tab, exactly as production does — router redirect, shell and all.
Future<ProviderContainer> _pumpRoster(
  WidgetTester tester, {
  FakeStudentRepository? students,
  FakeSectionRepository? sections,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(
        FakeProfileRepository(user: buildMe(role: UserRole.teacher)),
      ),
      studentRepositoryProvider.overrideWithValue(
        students ?? FakeStudentRepository(),
      ),
      sectionRepositoryProvider.overrideWithValue(
        sections ?? FakeSectionRepository(),
      ),
      // The teacher shell's other two tabs are built up front by its
      // IndexedStack, so without these they would go to the network.
      curriculumRepositoryProvider.overrideWithValue(FakeCurriculumRepository()),
      teacherAssignmentRepositoryProvider.overrideWithValue(
        FakeTeacherAssignmentRepository(),
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

  await tester.tap(find.widgetWithText(NavigationDestination, 'Roster'));
  await tester.pumpAndSettle();

  expect(find.byType(RosterScreen), findsOneWidget);
  return container;
}

/// The rows the list is actually holding.
///
/// Asserted through the controller rather than by finding text: a `ListView`
/// disposes the rows scrolled far off screen, so "is Student 40 in the list?"
/// and "is Student 40 painted?" are different questions, and appending a page
/// is the first of them.
List<StudentEntity> _rows(ProviderContainer container) =>
    container.read(rosterControllerProvider).value!.items;

/// Flings the list to its end, which is what triggers the next page.
Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.fling(find.byType(StudentCard).first, const Offset(0, -3000), 4000);
  await tester.pumpAndSettle();
}
