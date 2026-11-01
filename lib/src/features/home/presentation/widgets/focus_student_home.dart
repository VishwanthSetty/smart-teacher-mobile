import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand/brinda_wave.dart';
import '../../../../core/widgets/brand/clay.dart';
import '../../../activity/domain/progress_summary_entity.dart';
import '../../../activity/domain/resource_activity_entity.dart';
import '../../../activity/presentation/progress_summary_controller.dart';
import '../../../activity/presentation/widgets/activity_row.dart';
import '../../../library/domain/curriculum_entity.dart';
import '../../../library/presentation/library_controller.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../tasks/domain/task_entity.dart';
import '../../../tasks/presentation/my_tasks_controller.dart';
import '../../domain/home_entity.dart';
import 'continue_rail.dart';
import 'home_header.dart';
import 'subject_glyph.dart';

/// Student Home in the **Focus** register — Grade 6 to 10 (design canvas:
/// "Students · Home").
///
/// Flat cards with a soft shadow, 48 px targets, the Brinda wave only on the
/// navy hero, progress as bars, rings and percentages. Each section is drawn
/// only when it has real data behind it: the hero is the first in-progress
/// resource, tasks come from `/me/tasks`, and the subject rings come from
/// `/me/progress/summary` matched onto the student's curricula.
class FocusStudentHome extends ConsumerWidget {
  const FocusStudentHome({
    required this.home,
    this.studentName,
    this.classLabel,
    super.key,
  });

  final StudentHomeEntity home;
  final String? studentName;
  final String? classLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CurriculumEntity> subjects =
        ref.watch(libraryControllerProvider).value ??
        const <CurriculumEntity>[];
    final List<ProgressSummaryEntity> progress =
        ref.watch(progressSummaryControllerProvider).value ??
        const <ProgressSummaryEntity>[];
    final List<ResourceActivityEntity> moreToContinue = home.continueLearning
        .skip(1)
        .toList(growable: false);
    final List<ResourceActivityEntity> recent = home.recent
        .take(5)
        .toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 28),
      children: <Widget>[
        HomeHeader(
          leading: HomeAvatar(name: studentName),
          title: greetingFor(DateTime.now(), studentName),
          subtitle: classLabel,
          trailing: const <Widget>[NotificationBell()],
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: _SearchEntry(),
        ),
        if (home.continueLearning.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ContinueHero(activity: home.continueLearning.first),
          ),
        if (moreToContinue.isNotEmpty) ...<Widget>[
          const FocusSectionHeading(title: 'Continue learning'),
          ContinueRail(items: moreToContinue),
        ],
        const _MyTasksSection(),
        if (subjects.isNotEmpty) ...<Widget>[
          FocusSectionHeading(
            title: 'Subjects',
            actionLabel: 'My progress',
            onAction: () => context.push(AppRoutes.progress),
          ),
          _SubjectScroller(subjects: subjects, progress: progress),
        ],
        if (recent.isNotEmpty) ...<Widget>[
          FocusSectionHeading(
            title: 'Recently viewed',
            actionLabel: 'View all',
            onAction: () => context.push(AppRoutes.history),
          ),
          for (final ResourceActivityEntity activity in recent)
            ActivityRow(
              activity: activity,
              onTap: () => openActivity(context, activity),
            ),
        ],
      ],
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Search the library',
      child: PressScale(
        onTap: () => context.push(AppRoutes.search),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.fieldBorder,
              width: 1.5,
            ),
          ),
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search videos, notes, chapters',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The navy **Continue** hero, with the wave along its foot.
class _ContinueHero extends StatelessWidget {
  const _ContinueHero({required this.activity});

  final ResourceActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final double? fraction = activity.progressFraction;
    final String kind = activity.isVideo ? 'Video' : 'Document';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: AppColors.brandNavy,
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: -20,
              right: -20,
              bottom: -36,
              height: 120,
              child: BrindaWave(withSky: false, opacity: 0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'CONTINUE',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        kind,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onNavyMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              activity.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              watchedLabelFor(activity),
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onNavyMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Material(
                        color: AppColors.sun,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => openActivity(context, activity),
                          child: SizedBox.square(
                            dimension: 56,
                            child: Icon(
                              activity.isVideo
                                  ? Icons.play_arrow_rounded
                                  : Icons.menu_book_rounded,
                              color: AppColors.focusText,
                              size: 30,
                              semanticLabel: activity.isVideo
                                  ? 'Resume video'
                                  : 'Continue reading',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (fraction != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Semantics(
                      label: '${(fraction * 100).round()} percent',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: fraction),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder:
                              (BuildContext context, double value, Widget? _) =>
                                  LinearProgressIndicator(
                                    value: value,
                                    minHeight: 8,
                                    color: AppColors.sun,
                                    backgroundColor: AppColors.white.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TaskFilter { due, done }

/// **My tasks** with the Due / Done segment. Shows the first three of either;
/// the full list (and its Overdue / Due soon split) is the My Tasks tab.
///
/// No section at all while the list is loading, failed, or empty — the tab
/// owns those states, and a home screen full of spinners and retry buttons
/// would bury the hero.
class _MyTasksSection extends ConsumerStatefulWidget {
  const _MyTasksSection();

  @override
  ConsumerState<_MyTasksSection> createState() => _MyTasksSectionState();
}

class _MyTasksSectionState extends ConsumerState<_MyTasksSection> {
  _TaskFilter _filter = _TaskFilter.due;

  @override
  Widget build(BuildContext context) {
    final List<StudentTaskEntity> rows =
        ref.watch(myTasksControllerProvider).value ??
        const <StudentTaskEntity>[];
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final DateTime now = DateTime.now();
    final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
        groupStudentTasks(rows, now);
    final List<StudentTaskEntity> shown = switch (_filter) {
      _TaskFilter.due => <StudentTaskEntity>[
        ...grouped[StudentTaskGroup.overdue]!,
        ...grouped[StudentTaskGroup.dueSoon]!,
      ],
      _TaskFilter.done => grouped[StudentTaskGroup.completed]!,
    }.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FocusSectionHeading(
          title: 'My tasks',
          trailing: SegmentedButton<_TaskFilter>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.padded,
              textStyle: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            segments: const <ButtonSegment<_TaskFilter>>[
              ButtonSegment<_TaskFilter>(
                value: _TaskFilter.due,
                label: Text('Due'),
              ),
              ButtonSegment<_TaskFilter>(
                value: _TaskFilter.done,
                label: Text('Done'),
              ),
            ],
            selected: <_TaskFilter>{_filter},
            onSelectionChanged: (Set<_TaskFilter> next) =>
                setState(() => _filter = next.first),
          ),
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _filter == _TaskFilter.due
                  ? 'Nothing due — nice work.'
                  : 'Nothing finished yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final StudentTaskEntity row in shown)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _TaskRow(row: row, now: now),
            ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.row, required this.now});

  final StudentTaskEntity row;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TaskEntity? task = row.task;
    final bool video = task?.isVideo ?? false;
    final (String tag, Color tagBg, Color tagInk) = _tagFor(row, now);
    final String meta = <String>[
      if (video) 'Video' else 'Document',
      if (task?.resourceTitle case final String title
          when title.trim().isNotEmpty && title != row.displayTitle)
        title,
    ].join(' · ');

    return PressScale(
      onTap: task == null
          ? null
          : () => context.push(
              AppRoutes.studentTaskPath(task.id),
              extra: row.displayTitle,
            ),
      child: Semantics(
        button: task != null,
        label: '${row.displayTitle}, $tag',
        child: ExcludeSemantics(
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _cardDecoration(context),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: row.isCompleted
                        ? AppColors.doneTint
                        : video
                        ? AppColors.videoTint
                        : AppColors.docTint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    video
                        ? Icons.ondemand_video_rounded
                        : Icons.description_outlined,
                    size: 22,
                    color: row.isCompleted
                        ? AppColors.doneInk
                        : video
                        ? AppColors.deepBlue
                        : AppColors.grapeLip,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        row.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: tagInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static (String, Color, Color) _tagFor(StudentTaskEntity row, DateTime now) {
    if (row.isCompleted) {
      return ('Done', AppColors.doneTint, AppColors.doneInk);
    }
    if (row.isOverdueAt(now)) {
      return ('Overdue', AppColors.overdueTint, AppColors.overdueInk);
    }
    final DateTime? due = row.dueAt?.toLocal();
    if (due == null) {
      return ('Open', AppColors.videoTint, AppColors.deepBlueDark);
    }
    return (
      'Due ${shortDueLabel(due, now)}',
      AppColors.sunPale,
      AppColors.sunInk,
    );
  }
}

/// `'today'`, `'tomorrow'`, `'Thu'` within the week, else `'12 Nov'`.
String shortDueLabel(DateTime due, DateTime now) {
  const List<String> days = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final DateTime today = DateTime(now.year, now.month, now.day);
  final int delta = DateTime(
    due.year,
    due.month,
    due.day,
  ).difference(today).inDays;
  if (delta == 0) {
    return 'today';
  }
  if (delta == 1) {
    return 'tomorrow';
  }
  if (delta > 1 && delta < 7) {
    return days[due.weekday - 1];
  }
  return '${due.day} ${months[due.month - 1]}';
}

class _SubjectScroller extends StatelessWidget {
  const _SubjectScroller({required this.subjects, required this.progress});

  final List<CurriculumEntity> subjects;
  final List<ProgressSummaryEntity> progress;

  /// The summary row for a curriculum: same subject, and the same grade when
  /// the summary names one. No match means no ring, never a guessed 0%.
  ProgressSummaryEntity? _progressFor(CurriculumEntity curriculum) {
    for (final ProgressSummaryEntity row in progress) {
      if (row.subjectId == curriculum.subjectId &&
          (row.gradeLevelId == null ||
              row.gradeLevelId == curriculum.gradeLevelId) &&
          !row.isEmpty) {
        return row;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        itemCount: subjects.length,
        separatorBuilder: (BuildContext context, int _) =>
            const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) => _SubjectCard(
          curriculum: subjects[index],
          index: index,
          progress: _progressFor(subjects[index]),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.curriculum,
    required this.index,
    required this.progress,
  });

  final CurriculumEntity curriculum;
  final int index;
  final ProgressSummaryEntity? progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (Color tint, Color ink) = SubjectSwatch.focusAt(index);
    final SubjectGlyph glyph = SubjectGlyph.forSubject(curriculum.subjectName);
    final int items = curriculum.videoCount + curriculum.documentCount;
    final String name = curriculum.subjectName.trim().isEmpty
        ? 'Subject'
        : curriculum.subjectName.trim();
    final int? percent = progress?.percent;
    final String caption = <String>[
      if (percent != null) '$percent%',
      if (items == 1) '1 item' else '$items items',
    ].join(' · ');

    return PressScale(
      onTap: () => context.push(
        AppRoutes.curriculumTreePath(curriculum.id),
        extra: curriculum.subjectName,
      ),
      child: Semantics(
        button: true,
        label: percent == null
            ? '$name, $caption'
            : '$name, $percent percent complete',
        child: ExcludeSemantics(
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox.square(
                  dimension: 46,
                  child: CustomPaint(
                    painter: _RingPainter(
                      fraction: percent == null ? null : percent / 100,
                      color: ink,
                      track: theme.brightness == Brightness.dark
                          ? AppColors.darkOutline
                          : AppColors.line,
                      fill: percent == null ? tint : null,
                    ),
                    child: Center(
                      child: glyph.build(
                        color: ink,
                        iconSize: 20,
                        textStyle: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      caption,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A progress ring, or — with no progress data — a plain tinted disc.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    this.fill,
  });

  final double? fraction;
  final Color color;
  final Color track;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - 2.5;
    if (fill case final Color tint) {
      canvas.drawCircle(centre, size.shortestSide / 2, Paint()..color = tint);
      return;
    }
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(centre, radius, base..color = track);
    final double value = (fraction ?? 0).clamp(0, 1);
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}

BoxDecoration _cardDecoration(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColors.darkSurface : AppColors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: isDark
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: AppColors.brandNavy.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
  );
}
