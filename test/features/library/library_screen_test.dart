import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/curriculum_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/library_controller.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/library_screen.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/widgets/curriculum_card.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('the list (PRD §5.4.1)', () {
    testWidgets('renders a card per curriculum, with grade, subject and counts',
        (WidgetTester tester) async {
      await _pumpLibrary(
        tester,
        curricula: <CurriculumEntity>[
          buildCurriculum(
            subjectName: 'Mathematics',
            gradeLevelName: 'Grade 5',
            nodeCount: 12,
            videoCount: 8,
            documentCount: 3,
          ),
          buildCurriculum(
            id: 'curriculum-2',
            subjectName: 'Science',
            gradeLevelName: 'Grade 6',
            nodeCount: 4,
            videoCount: 2,
            documentCount: 0,
          ),
        ],
      );

      expect(find.byType(CurriculumCard), findsNWidgets(2));

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Grade 5'), findsOneWidget);
      expect(find.text('12 topics'), findsOneWidget);
      expect(find.text('8 videos'), findsOneWidget);
      expect(find.text('3 documents'), findsOneWidget);

      expect(find.text('Science'), findsOneWidget);
      expect(find.text('Grade 6'), findsOneWidget);
    });

    testWidgets('counts read singular when there is exactly one',
        (WidgetTester tester) async {
      await _pumpLibrary(
        tester,
        curricula: <CurriculumEntity>[
          buildCurriculum(nodeCount: 1, videoCount: 1, documentCount: 1),
        ],
      );

      expect(find.text('1 topic'), findsOneWidget);
      expect(find.text('1 video'), findsOneWidget);
      expect(find.text('1 document'), findsOneWidget);
    });

    testWidgets('a curriculum with no content says so, rather than three zeroes',
        (WidgetTester tester) async {
      await _pumpLibrary(
        tester,
        curricula: <CurriculumEntity>[
          buildCurriculum(nodeCount: 0, videoCount: 0, documentCount: 0),
        ],
      );

      // Distinct from an empty *library* — the school is entitled to this one,
      // it just has nothing in it yet.
      expect(find.text('No content in this curriculum yet.'), findsOneWidget);
      expect(find.text('0 topics'), findsNothing);
      expect(find.text('Your library is empty'), findsNothing);
    });

    testWidgets('renders every row the server returned, unfiltered (§4)',
        (WidgetTester tester) async {
      // A student session handed a TEACHER-audience row and a not-yet-published
      // one. Scoping is the server's job; re-deciding here would contradict a
      // list it has already narrowed — a teacher legitimately sees
      // STUDENT-audience curricula for grades they teach, and vice versa.
      await _pumpLibrary(
        tester,
        role: UserRole.student,
        curricula: <CurriculumEntity>[
          buildCurriculum(subjectName: 'Mathematics'),
          buildCurriculum(
            id: 'curriculum-2',
            subjectName: 'Pedagogy',
            audience: CurriculumAudience.teacher,
          ),
          buildCurriculum(
            id: 'curriculum-3',
            subjectName: 'History',
            status: CurriculumStatus.draft,
          ),
        ],
      );

      expect(find.byType(CurriculumCard), findsNWidgets(3));
      expect(find.text('Pedagogy'), findsOneWidget);
      // Not filtered out, but labelled — a draft is not live content.
      expect(find.text('Draft'), findsOneWidget);
    });
  });

  group('empty library (PRD §6.4)', () {
    testWidgets('an empty response is a designed state, not an error',
        (WidgetTester tester) async {
      await _pumpLibrary(tester, curricula: <CurriculumEntity>[]);

      expect(find.text('Your library is empty'), findsOneWidget);
      expect(
        find.textContaining('once your school has been given access'),
        findsOneWidget,
      );
      expect(find.byType(CurriculumCard), findsNothing);

      // The whole point of §6.4: none of the generic failure furniture.
      expect(find.textContaining('Something went wrong'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
    });

    testWidgets('the empty state can be pulled to refresh',
        (WidgetTester tester) async {
      // Both causes of an empty library are fixed by someone else in the admin
      // app, so re-checking without an app restart matters here.
      final FakeCurriculumRepository repository =
          FakeCurriculumRepository(curricula: <CurriculumEntity>[]);
      await _pumpLibrary(tester, repository: repository);

      expect(find.text('Your library is empty'), findsOneWidget);

      repository.curricula = <CurriculumEntity>[
        buildCurriculum(subjectName: 'Mathematics'),
      ];
      await _pullToRefresh(tester);

      expect(repository.callCount, 2);
      expect(find.text('Your library is empty'), findsNothing);
      expect(find.text('Mathematics'), findsOneWidget);
    });
  });

  group('failures', () {
    testWidgets('a failed load offers a retry, and recovers',
        (WidgetTester tester) async {
      final FakeCurriculumRepository repository = FakeCurriculumRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pumpLibrary(tester, repository: repository);

      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(find.byType(CurriculumCard), findsNothing);
      // A failure is not an empty library — the two must not share copy.
      expect(find.text('Your library is empty'), findsNothing);

      repository.error = null;
      repository.curricula = <CurriculumEntity>[
        buildCurriculum(subjectName: 'Mathematics'),
      ];
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Mathematics'), findsOneWidget);
    });

    testWidgets('a failed refresh keeps the rows on screen',
        (WidgetTester tester) async {
      final FakeCurriculumRepository repository = FakeCurriculumRepository(
        curricula: <CurriculumEntity>[
          buildCurriculum(subjectName: 'Mathematics'),
        ],
      );
      final ProviderContainer container =
          await _pumpLibrary(tester, repository: repository);

      repository.error = const NetworkError(message: 'Offline.');
      final Future<void> pending =
          container.read(libraryControllerProvider.notifier).refresh();
      await tester.pump();

      // Mid-flight: the list is still there rather than blanking out.
      expect(find.text('Mathematics'), findsOneWidget);

      await pending;
      await tester.pumpAndSettle();
      expect(find.text('Offline.'), findsOneWidget);
    });

    testWidgets('does not retry a failed load in the background',
        (WidgetTester tester) async {
      final FakeCurriculumRepository repository = FakeCurriculumRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pumpLibrary(tester, repository: repository);

      await tester.pump(const Duration(minutes: 1));

      expect(repository.callCount, 1);
    });
  });

  group('suspended school (PRD §5.2)', () {
    testWidgets('a suspension-flavoured 403 latches on the first answer',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpLibrary(
        tester,
        repository: FakeCurriculumRepository(
          error: const ForbiddenError(
            message: "Your school's access is suspended.",
            isSchoolSuspended: true,
          ),
        ),
        expectsLibrary: false,
      );

      // No corroborating second 403 needed: /curricula is already scoped to
      // exactly what this actor is entitled to, so there is no narrower
      // entitlement it could have been refused by.
      expect(container.read(schoolSuspensionProvider), isTrue);
      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(CurriculumCard), findsNothing);
    });

    testWidgets('an ordinary 403 is just an error, and does not latch',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpLibrary(
        tester,
        repository: FakeCurriculumRepository(
          error: const ForbiddenError(message: "You don't have access to this."),
        ),
      );

      expect(container.read(schoolSuspensionProvider), isFalse);
      expect(find.byType(SchoolSuspendedView), findsNothing);
      expect(find.text("You don't have access to this."), findsOneWidget);
    });
  });
}

/// Boots the real app on a restored session, which lands on `/home` — the
/// shell — through the router redirect. The student shell opens on Library, so
/// this returns with the library tab showing, exactly as production does.
Future<ProviderContainer> _pumpLibrary(
  WidgetTester tester, {
  List<CurriculumEntity>? curricula,
  FakeCurriculumRepository? repository,
  UserRole role = UserRole.student,
  // False only where the library is expected *not* to render — a confirmed
  // suspension replaces the whole shell, tab bodies included (§5.2).
  bool expectsLibrary = true,
}) async {
  assert(
    curricula == null || repository == null,
    'pass curricula or a repository, not both',
  );

  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(
        FakeProfileRepository(user: buildMe(role: role)),
      ),
      curriculumRepositoryProvider.overrideWithValue(
        repository ?? FakeCurriculumRepository(curricula: curricula),
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

  if (expectsLibrary) {
    expect(find.byType(LibraryScreen), findsOneWidget);
  }
  return container;
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.fling(
    find.byType(ListView).first,
    const Offset(0, 400),
    1000,
  );
  await tester.pumpAndSettle();
}
