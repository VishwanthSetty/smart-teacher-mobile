import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/bookmark_entity.dart';
import '../saved_controller.dart';

/// One saved item (mobile plan §5.4).
///
/// Videos and documents share one card with a branch, for the same reason the
/// history row does: they differ only in the glyph and in the caption line.
///
/// A **pending** row — one saved while offline and not yet acknowledged — is
/// labelled rather than hidden. Hiding it would make the star and the grid
/// disagree; dimming it without saying why would look like a rendering bug.
class SavedCard extends StatelessWidget {
  const SavedCard({
    required this.bookmark,
    this.onTap,
    this.onRemove,
    this.onFile,
    this.collectionName,
    super.key,
  });

  final BookmarkEntity bookmark;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// Teacher only — "File into…". Absent for a student, whose Saved list is by
  /// definition the bookmarks with no collection.
  final VoidCallback? onFile;

  final String? collectionName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool pending = isPendingBookmark(bookmark);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: colors.surfaceContainerHighest,
                child: Icon(
                  bookmark.isVideo
                      ? Icons.play_circle_outline
                      : Icons.picture_as_pdf_outlined,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bookmark.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (_caption case final String caption) ...<Widget>[
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        caption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (pending) ...<Widget>[
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Saving…',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _Overflow(
                // Filing needs the server's bookmark id, which a pending row
                // does not have yet. Removing does not — the queued add it
                // cancels never left this device.
                onFile: pending ? null : onFile,
                onRemove: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? get _caption {
    final String? collection = collectionName?.trim();
    if (collection != null && collection.isNotEmpty) {
      return collection;
    }
    final int? pages = bookmark.document?.pageCount;
    if (bookmark.isDocument && pages != null && pages > 0) {
      return '$pages pages';
    }
    final int? seconds = bookmark.video?.durationSecs;
    if (bookmark.isVideo && seconds != null && seconds > 0) {
      final int minutes = seconds ~/ 60;
      return minutes < 1 ? '${seconds}s' : '${minutes}m';
    }
    return null;
  }
}

class _Overflow extends StatelessWidget {
  const _Overflow({this.onFile, this.onRemove});

  final VoidCallback? onFile;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (onFile == null && onRemove == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<VoidCallback>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert),
      onSelected: (VoidCallback action) => action(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<VoidCallback>>[
        if (onFile case final VoidCallback file)
          PopupMenuItem<VoidCallback>(
            value: file,
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.folder_outlined),
              title: Text('File into…'),
            ),
          ),
        if (onRemove case final VoidCallback remove)
          PopupMenuItem<VoidCallback>(
            value: remove,
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.bookmark_remove_outlined),
              title: Text('Remove'),
            ),
          ),
      ],
    );
  }
}
