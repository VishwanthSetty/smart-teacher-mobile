import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/classes_repository.dart';
import 'package:smart_teacher_mobile/src/features/classes/domain/class_model.dart';

/// A repository stub that returns immediately, so widget tests don't depend on
/// the mock's simulated network delay.
class _FakeClassesRepository implements ClassesRepository {
  @override
  Future<List<ClassModel>> fetchClasses() async => const [
        ClassModel(
          id: 'c1',
          name: 'Algebra I',
          subject: 'Mathematics',
          grade: 'Grade 8',
          studentCount: 28,
          room: 'Room 204',
          schedule: 'Mon, Wed · 09:00 AM',
        ),
      ];
}

void main() {
  testWidgets('Home renders greeting and loaded class data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classesRepositoryProvider.overrideWithValue(
            _FakeClassesRepository(),
          ),
        ],
        child: const SmartTeacherApp(),
      ),
    );

    // Greeting is shown immediately.
    expect(find.text('Good morning, Alex'), findsOneWidget);

    // Let the FutureProvider resolve, then the class should appear.
    await tester.pumpAndSettle();
    expect(find.text('Algebra I'), findsWidgets);
  });
}
