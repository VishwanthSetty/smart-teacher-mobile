import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/student_age_band.dart';
import '../../../core/widgets/brand/owl_buddy.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../library/domain/curriculum_entity.dart';
import '../../library/presentation/library_controller.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/home_entity.dart';
import 'home_controller.dart';
import 'widgets/focus_student_home.dart';
import 'widgets/home_header.dart';
import 'widgets/play_student_home.dart';

/// Student **Home** (mobile plan §5.1), in one of the design's two student
/// registers:
///
/// * **Play** — Little Learners, Pre-primary to Grade 5
///   ([StudentAgeBand.explorers] and [StudentAgeBand.learners]): clay tiles,
///   the owl buddy, a subject per colour. See [PlayStudentHome].
/// * **Focus** — Grade 6 to 10 ([StudentAgeBand.scholars]): flat cards, a navy
///   continue hero, tasks and subject progress rings. See [FocusStudentHome].
///
/// The band is passed **in** by the shell, derived from the enrollment's grade
/// rank — this screen never reads the role. With no band (a test, or any
/// caller that doesn't know the grade) it renders Focus, the register that
/// carries the most information.
///
/// A bare body, not a `Scaffold`. The shell draws no app bar over the Home tab,
/// so this screen draws its own header, including the notifications bell.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({
    this.studentName,
    this.ageBand,
    this.classLabel,
    super.key,
  });

  final String? studentName;
  final StudentAgeBand? ageBand;

  /// `'Grade 8 · Section B'`, from the enrollment; null for an unplaced
  /// student, who gets no caption rather than a blank one.
  final String? classLabel;

  bool get _isPlay =>
      ageBand == StudentAgeBand.explorers || ageBand == StudentAgeBand.learners;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<StudentHomeEntity> home = ref.watch(
      studentHomeControllerProvider,
    );
    final AsyncValue<List<CurriculumEntity>> library = ref.watch(
      libraryControllerProvider,
    );
    final bool noSubjects =
        library.hasError || (library.hasValue && library.value!.isEmpty);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(studentHomeControllerProvider.notifier).refresh(),
      child: home.when(
        data: (StudentHomeEntity data) {
          // `/home/student` is empty for a student who simply hasn't started
          // anything yet — but their subjects are still there to start from.
          // So "nothing here" needs *both* answers empty: the aggregate, and a
          // library that has loaded (or failed) with no curricula in it.
          // Play always renders its own home: its header, owl and empty copy
          // are the register, and it explains an empty home in its own words.
          if (!_isPlay && data.isEmpty && noSubjects) {
            return _StudentHomeEmptyState(
              isPlay: _isPlay,
              studentName: studentName,
              classLabel: classLabel,
            );
          }
          if (_isPlay) {
            return PlayStudentHome(
              home: data,
              ageBand: ageBand!,
              studentName: studentName,
              classLabel: classLabel,
            );
          }
          return FocusStudentHome(
            home: data,
            studentName: studentName,
            classLabel: classLabel,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(studentHomeControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

/// A student with no active enrollment has an empty library **by design**
/// (mobile plan §5.1). This is the copy that case is owed — never an error.
///
/// It keeps the register's header (and, in Play, the owl) so the screen still
/// reads as *home* rather than as a dead end.
class _StudentHomeEmptyState extends StatelessWidget {
  const _StudentHomeEmptyState({
    required this.isPlay,
    required this.studentName,
    required this.classLabel,
  });

  final bool isPlay;
  final String? studentName;
  final String? classLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ColoredBox(
      color: isPlay ? AppColors.cloud : Colors.transparent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          HomeHeader(
            leading: HomeAvatar(name: studentName),
            title: isPlay
                ? (firstNameOf(studentName).isEmpty
                      ? 'Hi there!'
                      : 'Hi, ${firstNameOf(studentName)}!')
                : greetingFor(DateTime.now(), studentName),
            subtitle: classLabel,
            trailing: const <Widget>[NotificationBell()],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          if (isPlay)
            const Center(child: OwlBuddy())
          else
            Icon(
              Icons.school_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Nothing here yet',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
            ),
            child: Text(
              "Your class hasn't been set up yet — ask your teacher.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
