import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand/clay.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../profile/presentation/profile_view.dart';
import '../../tasks/presentation/assign_task_sheet.dart';
import '../domain/home_entity.dart';
import 'home_controller.dart';
import 'widgets/continue_rail.dart';
import 'widgets/home_header.dart';

/// Teacher **Dashboard** (mobile plan §5.7), in the design's **Teach**
/// register: data first — stat tiles, class chips, a stacked completion bar —
/// navy and Deep Blue leading, and exactly one yellow action, *Assign task*.
///
/// A bare body, not a `Scaffold`. The shell draws no app bar over the Home
/// tab, so the header here carries the notifications bell and the profile
/// button (the teacher's tab set has no Profile tab, and sign-out lives on the
/// profile screen).
///
/// What the design shows but the API cannot fill is left out rather than
/// faked: `/home/teacher` has no per-class task breakdown (the bar is the
/// aggregate across active tasks, which the endpoint computes), no "due this
/// week" count, and no per-student "needs a nudge" list — those live behind
/// *Class progress* and each task's own progress screen, where *Remind
/// pending* already exists.
///
/// Class chips are not tappable. There is no per-class detail endpoint to open
/// — `/teacher/class-progress` is a rollup *by task*, not by section, and it is
/// reached from the completion card, where it can be filtered by class.
class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({this.teacherName, super.key});

  final String? teacherName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<TeacherHomeEntity> home = ref.watch(
      teacherHomeControllerProvider,
    );

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: () =>
              ref.read(teacherHomeControllerProvider.notifier).refresh(),
          child: home.when(
            data: (TeacherHomeEntity data) =>
                _TeacherDashboardBody(home: data, teacherName: teacherName),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => ErrorRetryView(
              error: AppError.from(error),
              onRetry: () => unawaited(
                ref.read(teacherHomeControllerProvider.notifier).refresh(),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: _AssignTaskButton(
            onCreated: () => unawaited(
              ref.read(teacherHomeControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherDashboardBody extends StatelessWidget {
  const _TeacherDashboardBody({required this.home, this.teacherName});

  final TeacherHomeEntity home;
  final String? teacherName;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Clears the floating Assign button.
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        HomeHeader(
          eyebrow: longDateLabel(now),
          title: greetingFor(now, teacherName),
          trailing: <Widget>[
            const NotificationBell(),
            _ProfileButton(name: teacherName),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _StatTiles(home: home),
        ),
        const FocusSectionHeading(title: 'My classes'),
        if (home.classes.isEmpty)
          const _NoClassesNotice()
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final HomeClassEntity section in home.classes)
                  _ClassChip(label: section.displayLabel),
              ],
            ),
          ),
        if (!home.completionSummary.isEmpty) ...<Widget>[
          const FocusSectionHeading(title: 'Task completion'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CompletionSummaryCard(
              summary: home.completionSummary,
              activeTaskCount: home.activeTaskCount,
            ),
          ),
        ],
        const FocusSectionHeading(title: 'Shortcuts'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _ShortcutsCard(),
        ),
        if (home.continuePreparation.isNotEmpty) ...<Widget>[
          const FocusSectionHeading(title: 'Continue preparation'),
          ContinueRail(items: home.continuePreparation),
        ],
      ],
    );
  }
}

/// `'Saturday, 31 October'`.
String longDateLabel(DateTime date) {
  const List<String> days = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}

/// The navy initials tile that opens the profile — the teacher's route to
/// sign-out from Home.
class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Profile',
      child: Material(
        color: AppColors.brandNavy,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppRoutes.profile),
          child: Semantics(
            button: true,
            label: 'Profile',
            child: HomeAvatar(
              name: name,
              initialsColor: AppColors.waveSky,
              twoLetters: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.home});

  final TeacherHomeEntity home;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            value: home.classes.length,
            label: 'My classes',
            background: AppColors.brandNavy,
            valueColor: AppColors.white,
            labelColor: AppColors.onNavyMuted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: home.activeTaskCount,
            label: 'Active tasks',
            background: isDark ? AppColors.darkSurface : AppColors.white,
            valueColor: isDark ? AppColors.darkText : AppColors.focusText,
            labelColor: isDark ? AppColors.sky200 : AppColors.focusTextMuted,
            shadow: !isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: home.completionSummary.notStarted,
            label: 'Not started',
            background: AppColors.sunPale,
            valueColor: AppColors.sunInk,
            labelColor: AppColors.sunInk,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
    required this.labelColor,
    this.shadow = false,
  });

  final int value;
  final String label;
  final Color background;
  final Color valueColor;
  final Color labelColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadow
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.brandNavy.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$value',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  const _ClassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.fieldBorder,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// The aggregate across active tasks as one stacked bar — done, started, not
/// yet — with its legend, and the way into the per-task rollups (§5.9).
class _CompletionSummaryCard extends StatelessWidget {
  const _CompletionSummaryCard({
    required this.summary,
    required this.activeTaskCount,
  });

  final TaskCompletionSummary summary;
  final int activeTaskCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String description =
        '${summary.completed} done, ${summary.inProgress} started, '
        '${summary.notStarted} not yet';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.docTint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppColors.grapeLip,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'All active tasks',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        activeTaskCount == 1
                            ? 'Across 1 active task'
                            : 'Across $activeTaskCount active tasks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: description,
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: <Widget>[
                      _BarSegment(
                        flex: summary.completed,
                        color: AppColors.doneGreen,
                        first: true,
                        last: summary.inProgress + summary.notStarted == 0,
                      ),
                      _BarSegment(
                        flex: summary.inProgress,
                        color: AppColors.sun,
                        first: summary.completed == 0,
                        last: summary.notStarted == 0,
                      ),
                      _BarSegment(
                        flex: summary.notStarted,
                        color: AppColors.track,
                        first: summary.completed + summary.inProgress == 0,
                        last: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: <Widget>[
                _LegendItem(
                  color: AppColors.doneGreen,
                  label: '${summary.completed} done',
                ),
                _LegendItem(
                  color: AppColors.sun,
                  label: '${summary.inProgress} started',
                ),
                _LegendItem(
                  color: AppColors.track,
                  label: '${summary.notStarted} not yet',
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.deepBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.push(AppRoutes.classProgress),
              icon: const Icon(Icons.query_stats_rounded, size: 20),
              label: const Text('See class progress'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({
    required this.flex,
    required this.color,
    required this.first,
    required this.last,
  });

  final int flex;
  final Color color;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    if (flex <= 0) {
      return const SizedBox.shrink();
    }
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(right: last ? 0 : 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(first ? 7 : 0),
              right: Radius.circular(last ? 7 : 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// My preparation, Saved & collections and Class progress, in one card.
///
/// *My preparation* keeps that exact label so the teacher's own reading
/// progress is never confused with a class report. `/saved` is the teacher's
/// only way into Saved and Collections — their tab set has no room for a sixth
/// destination — and `extra: true` asks for the Collections variant, a nicety
/// the screen falls back from.
class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: <Widget>[
          _ShortcutTile(
            icon: Icons.insights_outlined,
            tint: AppColors.videoTint,
            ink: AppColors.deepBlue,
            title: 'My preparation',
            subtitle: 'How far you are through your own teaching material',
            onTap: () => context.push(AppRoutes.progress),
          ),
          const Divider(indent: 70),
          _ShortcutTile(
            icon: Icons.bookmark_border_rounded,
            tint: AppColors.overdueTint,
            ink: AppColors.overdueInk,
            title: 'Saved & collections',
            subtitle: 'Material you bookmarked, grouped for a lesson',
            onTap: () => context.push(AppRoutes.saved, extra: true),
          ),
          const Divider(indent: 70),
          _ShortcutTile(
            icon: Icons.query_stats_outlined,
            tint: AppColors.doneTint,
            ink: AppColors.doneInk,
            title: 'Class progress',
            subtitle: 'How your classes are doing on what you assigned',
            onTap: () => context.push(AppRoutes.classProgress),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.tint,
    required this.ink,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color ink;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: ink, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

/// The one yellow action in the Teach register.
class _AssignTaskButton extends StatelessWidget {
  const _AssignTaskButton({required this.onCreated});

  final VoidCallback onCreated;

  Future<void> _open(BuildContext context) async {
    final bool created = await showAssignTaskSheet(context);
    if (created) {
      onCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: () => unawaited(_open(context)),
      child: Semantics(
        button: true,
        label: 'Assign a task',
        child: ExcludeSemantics(
          child: Container(
            height: 56,
            padding: const EdgeInsets.fromLTRB(16, 0, 20, 0),
            decoration: BoxDecoration(
              color: AppColors.sun,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.sunLip.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.focusText,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assign task',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.focusText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A teacher with no **section-bearing** assignment (backend plan §4.2).
///
/// This is a legitimate state, not an error: `TeacherClassScopeService` fails
/// closed by design, and such a teacher can assign nothing and see no student
/// report. The copy says so plainly rather than showing an empty list that
/// looks like a loading bug. It deliberately does not contradict My Classes,
/// which reads the broader `/teacher-assignments` and may well show rows —
/// that endpoint includes the school-wide legacy grant, which carries no
/// section and therefore reaches no class here.
class _NoClassesNotice extends StatelessWidget {
  const _NoClassesNotice();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  "You aren't assigned to a class yet. Ask your school admin "
                  'to add you to a section.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
