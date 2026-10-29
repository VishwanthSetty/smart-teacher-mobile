import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../profile/presentation/profile_view.dart';
import 'task_progress_controller.dart';

/// One student's progress against one task's resource (mobile plan §5.9) —
/// `GET /tasks/:id/students/:studentId`.
///
/// Three answers, and they are deliberately three different screens:
///
/// * **a row** — the video's position and percentage, or the document's page
///   and whether it was marked read, plus the completion date;
/// * **`null`** — the student has never opened the resource. Rendered as an
///   explicit "hasn't opened this yet", not as a zeroed progress bar, which
///   would claim a measurement nobody took;
/// * **`404`** — the student is outside this teacher's class scope, or the task
///   isn't theirs. Rendered as [NotFoundView] with no retry and no wording that
///   reads as a refusal, because the endpoint answers `404` for both "no such
///   student" and "not yours" (backend plan §4.4).
///
/// This is read-only, and stays that way: a teacher cannot set a student's
/// progress, because progress is a projection of what the student actually did
/// (backend plan §6).
class StudentTaskReportScreen extends ConsumerWidget {
  const StudentTaskReportScreen({
    required this.taskId,
    required this.studentId,
    this.studentName,
    super.key,
  });

  final String taskId;
  final String studentId;

  /// Handed over by the row that pushed this. A nicety, not a dependency: it
  /// does not survive a deep link, and the heading falls back to wording that
  /// is correct without it.
  final String? studentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final StudentReportKey key = StudentReportKey(
      taskId: taskId,
      studentId: studentId,
    );
    final AsyncValue<ResourceActivityEntity?> activity = ref.watch(
      studentTaskActivityProvider(key),
    );

    return Scaffold(
      appBar: AppBar(title: Text(studentName?.trim().isNotEmpty ?? false
          ? studentName!.trim()
          : 'Student progress')),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : activity.when(
                data: (ResourceActivityEntity? data) => data == null
                    ? const _NotOpened()
                    : _ReportBody(activity: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) =>
                    _buildError(context, ref, key, error),
              ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    StudentReportKey key,
    Object error,
  ) {
    final AppError appError = AppError.from(error);
    if (appError is NotFoundError) {
      return NotFoundView(
        message: appError.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to progress',
      );
    }
    return ErrorRetryView(
      error: appError,
      onRetry: () => unawaited(
        ref.read(studentTaskActivityProvider(key).notifier).refresh(),
      ),
    );
  }
}

/// The `null` answer, said plainly.
class _NotOpened extends StatelessWidget {
  const _NotOpened();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.hourglass_empty_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              "This student hasn't opened the material yet.",
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.activity});

  final ResourceActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double? fraction = activity.progressFraction;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: <Widget>[
        Text(activity.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          activity.isVideo ? 'Video' : 'Document',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),

        if (fraction != null) ...<Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],

        // The **server's** percent and status, never a recomputed one: video
        // completion is unique coverage against a server-configured threshold,
        // and a client-side number would eventually disagree with the badge the
        // server renders (backend plan §3.1).
        _ReportTile(
          icon: Icons.flag_outlined,
          label: 'Status',
          value: activity.status.label ?? 'Not started',
        ),
        if (activity.isVideo) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.percent_outlined,
            label: 'Watched',
            value: '${activity.percent}%',
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.play_circle_outline,
            label: 'Last position',
            value: _clock(activity.positionSecs),
          ),
        ],
        if (activity.isDocument) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.menu_book_outlined,
            label: 'Reading position',
            // 'page 7' rather than 'page 7 of 24' when the count is unknown:
            // `Document.pageCount` is null for anything ingested before that
            // work landed, and guessing a denominator would be worse than
            // omitting it (mobile plan §4).
            value: activity.readingLabel ?? 'Not recorded',
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.task_alt_outlined,
            label: 'Marked as read',
            // The **only** way a document reaches COMPLETED. Reaching the last
            // page does not, and this screen must not imply it does.
            value: activity.markedCompleteAt == null
                ? 'No'
                : 'Yes, ${_date(activity.markedCompleteAt!)}',
          ),
        ],
        if (activity.completedAt case final DateTime completed) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.event_available_outlined,
            label: 'Completed',
            value: _date(completed),
          ),
        ],
        if (activity.lastAccessedAt case final DateTime seen) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          _ReportTile(
            icon: Icons.schedule_outlined,
            label: 'Last activity',
            value: _date(seen),
          ),
        ],
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `h:mm:ss`, dropping the hour when there isn't one.
String _clock(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  final String minutes = (safe ~/ 60 % 60).toString().padLeft(2, '0');
  final String secs = (safe % 60).toString().padLeft(2, '0');
  final int hours = safe ~/ 3600;
  return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
}

String _date(DateTime value) {
  final DateTime local = value.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}
