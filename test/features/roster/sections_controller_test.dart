import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/section_entity.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/sections_controller.dart';

import '../../support/fake_section_repository.dart';

/// PRD §5.5.3 — the section lookup that populates the roster's filter picker.
void main() {
  ProviderContainer makeContainer(FakeSectionRepository repository) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        sectionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SectionEntity', () {
    test('prefers the server-composed label over the grade/name join', () {
      const SectionEntity section = SectionEntity(
        id: 'section-1',
        name: 'A',
        gradeLevelName: 'Grade 5',
        label: 'Grade V — A',
      );

      expect(section.displayLabel, 'Grade V — A');
    });

    test('falls back to grade and name when there is no label', () {
      expect(
        buildSection(label: null).displayLabel,
        'Grade 5 - A',
      );
    });

    test('renders the bare name when the row carries no grade', () {
      expect(
        buildSection(gradeLevelName: null, label: null).displayLabel,
        'A',
      );
    });

    test('survives a row missing everything but its id', () {
      // The id is the only field the picker strictly needs — it is the opaque
      // value `GET /students?sectionId=` takes.
      const SectionEntity section = SectionEntity(id: 'section-1', name: '  ');

      expect(section.displayLabel, 'section-1');
    });

    test('deserialises a row that carries only id and name', () {
      final SectionEntity section = SectionEntity.fromJson(
        <String, dynamic>{'id': 'section-1', 'name': 'A'},
      );

      expect(section.gradeLevelId, isNull);
      expect(section.label, isNull);
      expect(section.displayLabel, 'A');
    });
  });

  group('SectionsController', () {
    test('fetches the section list on build', () async {
      final FakeSectionRepository repository = FakeSectionRepository(
        sections: <SectionEntity>[
          buildSection(name: 'A'),
          buildSection(name: 'B', label: 'Grade 5 - B'),
        ],
      );
      final ProviderContainer container = makeContainer(repository);

      final List<SectionEntity> sections =
          await container.read(sectionsControllerProvider.future);

      expect(repository.callCount, 1);
      expect(
        sections.map((SectionEntity s) => s.displayLabel),
        <String>['Grade 5 - A', 'Grade 5 - B'],
      );
    });

    test('keeps server order rather than sorting the picker itself', () async {
      final FakeSectionRepository repository = FakeSectionRepository(
        sections: <SectionEntity>[
          buildSection(name: 'C', label: 'Grade 6 - C'),
          buildSection(name: 'A'),
        ],
      );
      final ProviderContainer container = makeContainer(repository);

      final List<SectionEntity> sections =
          await container.read(sectionsControllerProvider.future);

      expect(
        sections.map((SectionEntity s) => s.id),
        <String>['section-C', 'section-A'],
      );
    });

    test('an empty school is a value, not an error', () async {
      final FakeSectionRepository repository =
          FakeSectionRepository(sections: <SectionEntity>[]);
      final ProviderContainer container = makeContainer(repository);

      expect(
        await container.read(sectionsControllerProvider.future),
        isEmpty,
      );
    });

    test('surfaces an AppError as an error state', () async {
      final FakeSectionRepository repository = FakeSectionRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      final ProviderContainer container = makeContainer(repository);

      await expectLater(
        container.read(sectionsControllerProvider.future),
        throwsA(isA<NetworkError>()),
      );
      expect(container.read(sectionsControllerProvider), isA<AsyncError<void>>());
    });

    test('does not retry a failed load behind the user', () async {
      final FakeSectionRepository repository = FakeSectionRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      final ProviderContainer container = makeContainer(repository);

      await expectLater(
        container.read(sectionsControllerProvider.future),
        throwsA(isA<NetworkError>()),
      );
      // Riverpod's automatic retry is off; only an explicit refresh re-reads.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repository.callCount, 1);
    });

    test('refresh re-reads and recovers from an error state', () async {
      final FakeSectionRepository repository = FakeSectionRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      final ProviderContainer container = makeContainer(repository);

      await expectLater(
        container.read(sectionsControllerProvider.future),
        throwsA(isA<NetworkError>()),
      );

      repository
        ..error = null
        ..sections = <SectionEntity>[buildSection(name: 'B', label: null)];
      await container.read(sectionsControllerProvider.notifier).refresh();

      expect(repository.callCount, 2);
      expect(
        container.read(sectionsControllerProvider).value?.single.displayLabel,
        'Grade 5 - B',
      );
    });

    test('a second refresh mid-flight is dropped, not queued', () async {
      final FakeSectionRepository repository = FakeSectionRepository();
      final ProviderContainer container = makeContainer(repository);
      await container.read(sectionsControllerProvider.future);

      final SectionsController controller =
          container.read(sectionsControllerProvider.notifier);
      await Future.wait<void>(<Future<void>>[
        controller.refresh(),
        controller.refresh(),
      ]);

      expect(repository.callCount, 2);
    });

    test('holds the list for the session instead of auto-disposing', () async {
      final FakeSectionRepository repository = FakeSectionRepository();
      final ProviderContainer container = makeContainer(repository);

      // Stands in for the picker being opened, dismissed and opened again: a
      // dropped listener must not cost a request (§5.5.3).
      final ProviderSubscription<AsyncValue<List<SectionEntity>>> first =
          container.listen(
        sectionsControllerProvider,
        (_, _) {},
      );
      await container.read(sectionsControllerProvider.future);
      first.close();

      container.listen(sectionsControllerProvider, (_, _) {}).close();
      await container.read(sectionsControllerProvider.future);

      expect(repository.callCount, 1);
    });
  });
}
