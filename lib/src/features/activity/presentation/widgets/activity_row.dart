import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/resource_activity_entity.dart';

/// The status chip on a history row (mobile plan §5.2).
///
/// Rendered from the server's [ActivityProgressStatus] and nothing else. The
/// completion threshold is server config (`VIDEO_COMPLETION_PERCENT`), so a
/// chip derived from a local percentage would disagree with the server the
/// moment that config changed — the plan is explicit that the client must not
/// hardcode 90%.
class ProgressStatusChip extends StatelessWidget {
  const ProgressStatusChip({required this.status, super.key});

  final ActivityProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final String? label = status.label;
    if (label == null) {
      return const SizedBox.shrink();
    }
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool done = status == ActivityProgressStatus.completed;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: done ? colors.secondaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            done ? Icons.check_circle_outline : Icons.play_circle_outline,
            size: 14,
            color: done
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: done
                  ? colors.onSecondaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the history feed (mobile plan §5.2).
///
/// Serves both tabs. The two differ only in the glyph and in the middle line —
/// a video shows a progress bar, a document shows `'page 7'` — so they are one
/// widget with a branch rather than two that drift apart.
///
/// The row is tappable and hands off to the player or reader; the caller
/// supplies [onTap] because routing is not this widget's business.
class ActivityRow extends StatelessWidget {
  const ActivityRow({required this.activity, this.onTap, super.key});

  final ResourceActivityEntity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double? fraction = activity.progressFraction;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        child: Icon(
          activity.isVideo
              ? Icons.play_circle_outline
              : Icons.picture_as_pdf_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        activity.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppConstants.spacingXs),
          if (activity.isVideo && fraction != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 4,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          // A document's position is a page number, not a bar: `pageCount` is
          // null for anything ingested before the backend started reading it,
          // and a bar with a guessed denominator would be a lie (mobile §4).
          if (activity.isDocument && activity.readingLabel != null)
            Text(
              activity.readingLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: AppConstants.spacingXs),
          Row(
            children: <Widget>[
              ProgressStatusChip(status: activity.status),
              if (_lastAccessedLabel case final String label) ...<Widget>[
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Relative wording, because "2 days ago" is what a history feed is read
  /// for. Falls back to nothing rather than to a raw timestamp.
  String? get _lastAccessedLabel {
    final DateTime? at = activity.lastAccessedAt;
    if (at == null) {
      return null;
    }
    final Duration since = DateTime.now().difference(at);
    if (since.isNegative || since.inMinutes < 1) {
      return 'Just now';
    }
    if (since.inHours < 1) {
      return '${since.inMinutes}m ago';
    }
    if (since.inDays < 1) {
      return '${since.inHours}h ago';
    }
    if (since.inDays < 7) {
      return '${since.inDays}d ago';
    }
    final int weeks = since.inDays ~/ 7;
    return weeks < 5 ? '${weeks}w ago' : '${since.inDays ~/ 30}mo ago';
  }
}
