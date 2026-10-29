import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/progress_summary_entity.dart';
import 'progress_summary_controller.dart';

/// **Learning Progress** (student) / **My Preparation Progress** (teacher) —
/// mobile plan §5.3.
///
/// One widget, one endpoint, two headings. `GET /me/progress/summary` is
/// actor-scoped, so the only thing that differs is the wording — and that
/// wording matters: a teacher's own reading progress and their class's progress
/// are different notions, so the teacher's copy says *My preparation*
/// explicitly and this screen never sits on the same tab as a class report.
///
/// The caller supplies [isTeacherPreparation] rather than this reading the
/// role, keeping `shellTabsFor` the app's only role check.
class ProgressSummaryScreen extends ConsumerWidget {
  const ProgressSummaryScreen({
    this.isTeacherPreparation = false,
    this.showScaffold = true,
    super.key,
  });

  final bool isTeacherPreparation;

  /// Pushed routes want their own chrome; a shell tab must not bring one, or
  /// the shell's app bar would be doubled.
  final bool showScaffold;

  String get title =>
      isTeacherPreparation ? 'My preparation' : 'Learning progress';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget body = _ProgressSummaryBody(
      isTeacherPreparation: isTeacherPreparation,
    );
    if (!showScaffold) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: body),
    );
  }
}

class _ProgressSummaryBody extends ConsumerWidget {
  const _ProgressSummaryBody({required this.isTeacherPreparation});

  final bool isTeacherPreparation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<List<ProgressSummaryEntity>> summary = ref.watch(
      progressSummaryControllerProvider,
    );

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(progressSummaryControllerProvider.notifier).refresh(),
      child: summary.when(
        data: (List<ProgressSummaryEntity> rows) => rows.isEmpty
            ? _EmptySummary(isTeacherPreparation: isTeacherPreparation)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                itemCount: rows.length,
                itemBuilder: (BuildContext context, int index) =>
                    SubjectProgressCard(summary: rows[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(progressSummaryControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

/// One subject's card with the three-segment bar (mobile plan §5.3).
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({required this.summary, this.onTap, super.key});

  final ProgressSummaryEntity summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final (double notStarted, double inProgress, double completed) =
        summary.segments;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      summary.displayName,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${summary.percent}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              if (summary.isEmpty)
                Text(
                  'Nothing in this subject yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                )
              else ...<Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Row(
                      children: <Widget>[
                        // Order matters: completed last, so the bar reads
                        // left-to-right as "still to do → doing → done".
                        _Segment(
                          flex: notStarted,
                          color: colors.surfaceContainerHighest,
                        ),
                        _Segment(flex: inProgress, color: colors.tertiary),
                        _Segment(flex: completed, color: colors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Wrap(
                  spacing: AppConstants.spacingMd,
                  runSpacing: AppConstants.spacingXs,
                  children: <Widget>[
                    _LegendEntry(
                      color: colors.surfaceContainerHighest,
                      label: 'Not started',
                      count: summary.notStarted,
                    ),
                    _LegendEntry(
                      color: colors.tertiary,
                      label: 'In progress',
                      count: summary.inProgress,
                    ),
                    _LegendEntry(
                      color: colors.primary,
                      label: 'Completed',
                      count: summary.completed,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.flex, required this.color});

  final double flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Expanded's flex is an int, so a segment under half a percent would round
    // to zero and vanish. Scaling by 1000 keeps a one-in-a-thousand slice
    // visible, which is the difference between "none completed" and "one".
    final int weight = (flex * 1000).round();
    if (weight <= 0) {
      return const SizedBox.shrink();
    }
    return Expanded(flex: weight, child: ColoredBox(color: color));
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppConstants.spacingXs),
      Text(
        '$label · $count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

/// `200 []` — a real outcome, not a failure (PRD §6.4).
///
/// The copy names no cause: an unentitled school and a student with no active
/// enrollment both land here, and which one applies is a server-side fact this
/// screen cannot see.
class _EmptySummary extends StatelessWidget {
  const _EmptySummary({required this.isTeacherPreparation});

  final bool isTeacherPreparation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.insights_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'No subjects yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          isTeacherPreparation
              ? 'Once teaching material is available to you, your preparation '
                    'progress will show up here.'
              : "Your class hasn't been set up yet — ask your teacher.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
