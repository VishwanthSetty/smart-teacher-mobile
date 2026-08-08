import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/class_model.dart';

/// Abstraction over the source of [ClassModel] data.
///
/// Presentation code depends on this interface, not on the concrete source, so
/// the mock below can later be replaced by an API- or database-backed
/// implementation without changing any screen.
abstract class ClassesRepository {
  Future<List<ClassModel>> fetchClasses();
}

/// In-memory implementation with representative sample data. Simulates network
/// latency so loading states are exercised during development.
class MockClassesRepository implements ClassesRepository {
  const MockClassesRepository();

  @override
  Future<List<ClassModel>> fetchClasses() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const [
      ClassModel(
        id: 'c1',
        name: 'Algebra I',
        subject: 'Mathematics',
        grade: 'Grade 8',
        studentCount: 28,
        room: 'Room 204',
        schedule: 'Mon, Wed · 09:00 AM',
      ),
      ClassModel(
        id: 'c2',
        name: 'World History',
        subject: 'Social Studies',
        grade: 'Grade 9',
        studentCount: 32,
        room: 'Room 118',
        schedule: 'Tue, Thu · 10:30 AM',
      ),
      ClassModel(
        id: 'c3',
        name: 'Biology',
        subject: 'Science',
        grade: 'Grade 10',
        studentCount: 26,
        room: 'Lab 3',
        schedule: 'Mon, Fri · 01:00 PM',
      ),
      ClassModel(
        id: 'c4',
        name: 'English Literature',
        subject: 'English',
        grade: 'Grade 9',
        studentCount: 30,
        room: 'Room 212',
        schedule: 'Wed, Fri · 11:15 AM',
      ),
    ];
  }
}

final classesRepositoryProvider = Provider<ClassesRepository>(
  (ref) => const MockClassesRepository(),
);

/// Exposes the list of classes to the UI as an async value, handling the
/// loading and error states for free.
final classesProvider = FutureProvider<List<ClassModel>>((ref) {
  return ref.watch(classesRepositoryProvider).fetchClasses();
});
