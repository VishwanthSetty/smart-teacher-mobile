import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/theme/student_age_band.dart';
import 'package:smart_teacher_mobile/src/core/widgets/brand/owl_buddy.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/progress_summary_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/progress_summary_screen.dart';
import 'package:smart_teacher_mobile/src/features/home/domain/home_entity.dart';
import 'package:smart_teacher_mobile/src/features/home/presentation/student_home_screen.dart';
import 'package:smart_teacher_mobile/src/features/home/presentation/teacher_dashboard_screen.dart';
import 'package:smart_teacher_mobile/src/features/home/presentation/widgets/continue_rail.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/curriculum_entity.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_home_repository.dart';
import '../../support/fake_progress_repository.dart';

void main() {
  group('student home (mobile plan §5.1)', () {
    testWidgets('the newest resource leads the hero, the rest are a rail', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const StudentHomeScreen(studentName: 'Ravi Kumar'),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            continueLearning: <ResourceActivityEntity>[
              buildActivity(
                id: 'a',
                videoId: 'v1',
                title: 'Photosynthesis',
                positionSecs: 412,
              ),
              buildActivity(id: 'b', videoId: 'v2', title: 'Respiration'),
            ],
          ),
        ),
      );

      // The hero is not a rail card: only the second resource is.
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.text('Photosynthesis'), findsOneWidget);
      // With a known duration the hero says how far through it is
      // ('6:52 of … watched'); without one it falls back to 'Resume at 6:52'.
      expect(find.textContaining('6:52'), findsOneWidget);
      expect(find.text('Continue learning'), findsOneWidget);
      expect(find.byType(ContinueCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ContinueCard),
          matching: find.text('Respiration'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a document card shows a page, not a timestamp', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const StudentHomeScreen(),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            continueLearning: <ResourceActivityEntity>[
              buildActivity(
                id: 'a',
                documentId: 'd1',
                title: 'Worksheet 3',
                lastPage: 7,
                pageCount: 24,
              ),
            ],
          ),
        ),
      );

      expect(find.text('page 7 of 24'), findsOneWidget);
    });

    testWidgets('greets by first name only', (WidgetTester tester) async {
      await _pump(
        tester,
        const StudentHomeScreen(studentName: 'Ravi Kumar'),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            recent: <ResourceActivityEntity>[
              buildActivity(id: 'a', videoId: 'v1'),
            ],
          ),
        ),
      );

      expect(
        find.textContaining(
          RegExp(r'^Good (morning|afternoon|evening), Ravi$'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Kumar'), findsNothing);
    });

    testWidgets('lists the subjects with their item counts', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const StudentHomeScreen(),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            recent: <ResourceActivityEntity>[
              buildActivity(id: 'a', videoId: 'v1'),
            ],
          ),
        ),
        curricula: FakeCurriculumRepository(
          curricula: <CurriculumEntity>[
            buildCurriculum(subjectName: 'Science'),
          ],
        ),
      );

      expect(find.text('Subjects'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
      // No progress summary row for it, so no percentage is invented.
      expect(find.text('11 items'), findsOneWidget);
    });

    testWidgets('a student who has started nothing still sees their subjects', (
      WidgetTester tester,
    ) async {
      // `/home/student` is all-empty for a brand-new student, but the library
      // is not — Home must offer the subjects, not "Nothing here yet".
      await _pump(
        tester,
        const StudentHomeScreen(
          studentName: 'nursery',
          ageBand: StudentAgeBand.explorers,
        ),
        home: FakeHomeRepository(),
        curricula: FakeCurriculumRepository(
          curricula: <CurriculumEntity>[
            buildCurriculum(id: 'c1', subjectName: 'EVS'),
            buildCurriculum(id: 'c2', subjectName: 'English'),
          ],
        ),
      );

      expect(find.text('Let’s learn'), findsOneWidget);
      expect(find.text('EVS'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsNothing);
    });

    testWidgets('the Focus register does the same', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const StudentHomeScreen(),
        home: FakeHomeRepository(),
        curricula: FakeCurriculumRepository(
          curricula: <CurriculumEntity>[
            buildCurriculum(subjectName: 'Science'),
          ],
        ),
      );

      expect(find.text('Science'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsNothing);
    });

    testWidgets('the Play register greets with the owl and clay subjects', (
      WidgetTester tester,
    ) async {
      // Pre-primary to Grade 5 (StudentAgeBand.explorers / learners).
      await _pump(
        tester,
        const StudentHomeScreen(
          studentName: 'Ravi Kumar',
          ageBand: StudentAgeBand.explorers,
          classLabel: 'LKG · Sunflower',
        ),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            continueLearning: <ResourceActivityEntity>[
              buildActivity(id: 'a', videoId: 'v1', title: 'Shapes Song'),
            ],
          ),
        ),
        curricula: FakeCurriculumRepository(
          curricula: <CurriculumEntity>[buildCurriculum(subjectName: 'Rhymes')],
        ),
      );

      expect(find.text('Hi, Ravi!'), findsOneWidget);
      expect(find.text('LKG · Sunflower'), findsOneWidget);
      expect(find.byType(OwlBuddy), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Shapes Song'), findsOneWidget);
      expect(find.text('Rhymes'), findsOneWidget);
      // Progress is never a percentage in this register.
      expect(find.textContaining('%'), findsNothing);

      // Tapping the owl changes what it says.
      final String before = tester
          .widget<Text>(
            find.descendant(
              of: find.byType(AnimatedSwitcher),
              matching: find.byType(Text),
            ),
          )
          .data!;
      await tester.tap(find.byType(OwlBuddy));
      await tester.pumpAndSettle();
      expect(find.text(before), findsNothing);
    });

    testWidgets('an empty home says the class is not set up, not an error', (
      WidgetTester tester,
    ) async {
      // A student with no active enrollment has an empty library by design.
      await _pump(
        tester,
        const StudentHomeScreen(),
        home: FakeHomeRepository(),
      );

      expect(
        find.textContaining("Your class hasn't been set up yet"),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
    });

    testWidgets('a failed load offers a retry', (WidgetTester tester) async {
      final FakeHomeRepository home = FakeHomeRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pump(tester, const StudentHomeScreen(), home: home);

      expect(find.text('Could not reach the server.'), findsOneWidget);

      home.error = null;
      home.student = StudentHomeEntity(
        recent: <ResourceActivityEntity>[
          buildActivity(id: 'a', videoId: 'v1', title: 'Photosynthesis'),
        ],
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Photosynthesis'), findsOneWidget);
    });

    testWidgets('a confirmed suspension replaces the body', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await _pump(
        tester,
        const StudentHomeScreen(),
        home: FakeHomeRepository(
          student: StudentHomeEntity(
            recent: <ResourceActivityEntity>[
              buildActivity(id: 'a', videoId: 'v1'),
            ],
          ),
        ),
      );

      container.read(schoolSuspensionProvider.notifier).confirm();
      await tester.pumpAndSettle();

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
    });
  });

  group('teacher dashboard (mobile plan §5.7)', () {
    testWidgets('lists the sections the teacher can act on', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const TeacherDashboardScreen(),
        home: FakeHomeRepository(
          teacher: const TeacherHomeEntity(
            classes: <HomeClassEntity>[
              HomeClassEntity(id: 's1', name: 'A', gradeLevelName: 'Grade 5'),
            ],
          ),
        ),
      );

      expect(find.text('Grade 5 - A'), findsOneWidget);
    });

    testWidgets('a teacher with no section-bearing assignment is told so', (
      WidgetTester tester,
    ) async {
      // `TeacherClassScopeService` fails closed by design — an empty list here
      // is a legitimate state, not a loading bug.
      await _pump(
        tester,
        const TeacherDashboardScreen(),
        home: FakeHomeRepository(),
      );

      expect(
        find.textContaining("aren't assigned to a class yet"),
        findsOneWidget,
      );
    });

    testWidgets('shows task completion counts when there are active tasks', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const TeacherDashboardScreen(),
        home: FakeHomeRepository(
          teacher: const TeacherHomeEntity(
            activeTaskCount: 3,
            completionSummary: TaskCompletionSummary(
              notStarted: 12,
              inProgress: 5,
              completed: 8,
            ),
          ),
        ),
      );

      expect(find.text('Across 3 active tasks'), findsOneWidget);
      expect(find.text('8 done'), findsOneWidget);
      expect(find.text('5 started'), findsOneWidget);
      expect(find.text('12 not yet'), findsOneWidget);
      expect(find.text('See class progress'), findsOneWidget);
    });

    testWidgets('greets the teacher and offers the one Assign action', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const TeacherDashboardScreen(teacherName: 'Sunita Rao'),
        home: FakeHomeRepository(),
      );

      expect(
        find.textContaining(
          RegExp(r'^Good (morning|afternoon|evening), Sunita$'),
        ),
        findsOneWidget,
      );
      expect(find.text('SR'), findsOneWidget);
      expect(find.text('Assign task'), findsOneWidget);
    });

    testWidgets('hides the completion card when nothing is assigned', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const TeacherDashboardScreen(),
        home: FakeHomeRepository(),
      );

      expect(find.text('Task completion'), findsNothing);
    });

    testWidgets('labels its own progress "My preparation"', (
      WidgetTester tester,
    ) async {
      // Kept distinct from class reports so the two progress notions are never
      // confused on screen.
      await _pump(
        tester,
        const TeacherDashboardScreen(),
        home: FakeHomeRepository(),
      );

      expect(find.text('My preparation'), findsOneWidget);
    });

    testWidgets('calls the teacher endpoint, never the student one', (
      WidgetTester tester,
    ) async {
      final FakeHomeRepository home = FakeHomeRepository();
      await _pump(tester, const TeacherDashboardScreen(), home: home);

      expect(home.teacherCalls, 1);
      expect(home.studentCalls, 0);
    });
  });

  group('progress summary (mobile plan §5.3)', () {
    testWidgets('renders a per-subject card with its counts', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const ProgressSummaryScreen(showScaffold: false),
        progress: FakeProgressRepository(
          summary: <ProgressSummaryEntity>[
            buildSummary(subjectName: 'Mathematics', percent: 20),
          ],
        ),
      );

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('Not started · 5'), findsOneWidget);
      expect(find.text('Completed · 2'), findsOneWidget);
    });

    testWidgets('one widget, two headings', (WidgetTester tester) async {
      await _pump(
        tester,
        const ProgressSummaryScreen(),
        progress: FakeProgressRepository(),
      );
      expect(find.widgetWithText(AppBar, 'Learning progress'), findsOneWidget);

      await _pump(
        tester,
        const ProgressSummaryScreen(isTeacherPreparation: true),
        progress: FakeProgressRepository(),
      );
      expect(find.widgetWithText(AppBar, 'My preparation'), findsOneWidget);
    });

    testWidgets('an empty summary names no cause', (WidgetTester tester) async {
      // Which of "unentitled school" or "no enrollment" applies is a
      // server-side fact this screen cannot see.
      await _pump(
        tester,
        const ProgressSummaryScreen(showScaffold: false),
        progress: FakeProgressRepository(),
      );

      expect(find.text('No subjects yet'), findsOneWidget);
    });
  });
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget screen, {
  FakeHomeRepository? home,
  FakeProgressRepository? progress,
  FakeCurriculumRepository? curricula,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...activityOverrides(home: home, progress: progress),
      // The student home's subject rows read the library list.
      curriculumRepositoryProvider.overrideWithValue(
        curricula ?? FakeCurriculumRepository(curricula: <CurriculumEntity>[]),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: screen)),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
