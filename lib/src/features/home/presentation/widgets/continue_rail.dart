import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../activity/domain/resource_activity_entity.dart';

/// A titled section of the home screen, with an optional "View all" affordance.
///
/// The action is optional because phases 3 and 4 add the destinations for the
/// Tasks and Saved rails; a header that linked nowhere would be worse than one
/// that is simply a heading.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.title,
    required this.child,
    this.onViewAll,
    this.viewAllLabel = 'View all',
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onViewAll;
  final String viewAllLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingLg,
            AppConstants.spacingSm,
            AppConstants.spacingSm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              if (onViewAll != null)
                TextButton(onPressed: onViewAll, child: Text(viewAllLabel)),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// The **Continue Learning** rail (mobile plan §5.1) — and, on the teacher's
/// dashboard, **Continue Preparation**.
///
/// One widget for both: they are the same `/me/continue` shape answered for a
/// different actor, and the only difference is the heading above them.
class ContinueRail extends StatelessWidget {
  const ContinueRail({required this.items, super.key});

  final List<ResourceActivityEntity> items;

  static const double _cardWidth = 210;
  static const double _railHeight = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int _) =>
            const SizedBox(width: AppConstants.spacingSm),
        itemBuilder: (BuildContext context, int index) => SizedBox(
          width: _cardWidth,
          child: ContinueCard(activity: items[index]),
        ),
      ),
    );
  }
}

/// One card in the continue rail: a progress bar and a "resume at" label.
class ContinueCard extends StatelessWidget {
  const ContinueCard({required this.activity, super.key});

  final ResourceActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double? fraction = activity.progressFraction;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                activity.isVideo
                    ? Icons.play_circle_outline
                    : Icons.picture_as_pdf_outlined,
                color: colors.primary,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  activity.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              if (fraction != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 4,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                _resumeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _resumeLabel => resumeLabelFor(activity);

  void _open(BuildContext context) => openActivity(context, activity);
}

/// `'Resume at 6:52'` for a video, `'page 7 of 24'` for a document.
///
/// Falls back to a neutral prompt rather than inventing a position — a row can
/// exist with no position at all, and "Resume at 0:00" would be a worse answer
/// than none.
String resumeLabelFor(ResourceActivityEntity activity) {
  if (activity.isDocument) {
    return activity.readingLabel ?? 'Continue reading';
  }
  final int seconds = activity.positionSecs;
  if (seconds <= 0) {
    return 'Start watching';
  }
  return 'Resume at ${formatPlaybackTime(seconds)}';
}

/// `'12:40 of 19:50 watched'` when both halves are known, otherwise the plain
/// [resumeLabelFor] — the total is never guessed.
String watchedLabelFor(ResourceActivityEntity activity) {
  final int? total = activity.durationSecs;
  final int position = activity.positionSecs;
  if (activity.isVideo && total != null && total > 0 && position > 0) {
    return '${formatPlaybackTime(position)} of ${formatPlaybackTime(total)} '
        'watched';
  }
  return resumeLabelFor(activity);
}

/// Opens the player or the reader for [activity]. A row with no resource id
/// (a malformed payload) does nothing rather than pushing a broken route.
void openActivity(BuildContext context, ResourceActivityEntity activity) {
  final String id = activity.resourceId;
  if (id.isEmpty) {
    return;
  }
  context.push(
    activity.isVideo ? AppRoutes.videoPath(id) : AppRoutes.documentPath(id),
    extra: activity.title,
  );
}

String formatPlaybackTime(int seconds) =>
    _formatDuration(Duration(seconds: seconds));

String _formatDuration(Duration duration) {
  final int totalSeconds = duration.inSeconds;
  final int hours = totalSeconds ~/ Duration.secondsPerHour;
  final int minutes =
      (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  final int seconds = totalSeconds % Duration.secondsPerMinute;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
