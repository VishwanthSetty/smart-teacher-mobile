import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/content_node_entity.dart';

/// One node of the curriculum tree, and — through itself — everything under it
/// (PRD §5.4.2).
///
/// Chapters and sub-topics are the same widget at every depth, because they are
/// the same entity at every depth; only [depth] differs, and it only affects
/// indentation and the type scale.
///
/// **Empty branches are decided by the server's counts, never by looking
/// inside.** `videoCountDeep`/`documentCountDeep` already cover the whole
/// subtree, so [ContentNodeEntity.isEmptyDeep] is a field read, not a walk. An
/// empty branch renders greyed out and refuses to expand: the only thing
/// opening it could reveal is more empty branches, and letting a user drill
/// three levels into nothing is worse than saying so on the first row.
///
/// Non-empty branches start collapsed. This is a drill-down (§5.4.2), and a
/// curriculum expanded to its leaves on arrival is a wall of rows rather than a
/// table of contents.
class ContentNodeTile extends StatelessWidget {
  const ContentNodeTile({
    required this.node,
    required this.onItemTap,
    this.depth = 0,
    super.key,
  });

  final ContentNodeEntity node;

  /// Handed up rather than navigated here, so the tile stays a pure rendering
  /// of the tree and the route lives with the screen.
  final void Function(ContentItemEntity item, ContentItemKind kind) onItemTap;

  final int depth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final TextStyle? titleStyle = depth == 0
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyLarge;

    if (node.isEmptyDeep) {
      return ListTile(
        // No expansion arrow and no tap target: there is provably nothing
        // below this, so an affordance here would lead nowhere.
        leading: Icon(Icons.folder_off_outlined, color: colors.onSurfaceVariant),
        title: Text(
          node.displayTitle,
          style: titleStyle?.copyWith(color: colors.onSurfaceVariant),
        ),
        subtitle: Text(
          'Nothing here yet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        enabled: false,
      );
    }

    return ExpansionTile(
      leading: Icon(Icons.folder_outlined, color: colors.primary),
      title: Text(node.displayTitle, style: titleStyle),
      subtitle: Text(
        _countSummary,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      // Nested tiles indent themselves one step per level, so depth stays
      // readable without every level re-deriving its own inset.
      childrenPadding: const EdgeInsets.only(left: AppConstants.spacingMd),
      shape: const Border(),
      collapsedShape: const Border(),
      children: <Widget>[
        // This node's own content first, then the sub-topics: the items
        // directly attached to a chapter belong to the chapter, and burying
        // them under its children would misrepresent the structure.
        for (final ContentItemEntity video in node.videos)
          ContentItemRow(
            item: video,
            kind: ContentItemKind.video,
            onTap: () => onItemTap(video, ContentItemKind.video),
          ),
        for (final ContentItemEntity document in node.documents)
          ContentItemRow(
            item: document,
            kind: ContentItemKind.document,
            onTap: () => onItemTap(document, ContentItemKind.document),
          ),
        for (final ContentNodeEntity child in node.children)
          ContentNodeTile(
            node: child,
            onItemTap: onItemTap,
            depth: depth + 1,
          ),
      ],
    );
  }

  /// What is in this branch, straight from the deep counts. A count of zero is
  /// left out entirely rather than shown as "0 videos" — the row already says
  /// there is something here, and the interesting part is what.
  String get _countSummary {
    final List<String> parts = <String>[
      if (node.videoCountDeep > 0)
        '${node.videoCountDeep} '
            '${node.videoCountDeep == 1 ? 'video' : 'videos'}',
      if (node.documentCountDeep > 0)
        '${node.documentCountDeep} '
            '${node.documentCountDeep == 1 ? 'document' : 'documents'}',
    ];

    return parts.join(' · ');
  }
}

/// A playable or readable leaf (PRD §5.4.2).
///
/// Tapping hands off to the native player or the still-stubbed reader.
class ContentItemRow extends StatelessWidget {
  const ContentItemRow({
    required this.item,
    required this.kind,
    required this.onTap,
    super.key,
  });

  final ContentItemEntity item;
  final ContentItemKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? subtitle = _subtitle;

    return ListTile(
      // PRD §B1: this is deliberately static. `posterUrl` is available only
      // after minting a playback token, which belongs to the opened player and
      // must never be requested once per visible list row.
      leading: Icon(
        switch (kind) {
          ContentItemKind.video => Icons.play_circle_outline,
          ContentItemKind.document => Icons.description_outlined,
        },
        color: colors.onSurfaceVariant,
      ),
      title: Text(item.displayTitle(kind), style: theme.textTheme.bodyMedium),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
      trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      onTap: onTap,
    );
  }

  /// Only when the payload actually carried something worth showing — an empty
  /// second line is worse than one line.
  String? get _subtitle => switch (kind) {
        ContentItemKind.video => _duration,
        ContentItemKind.document => item.fileName?.trim().isEmpty ?? true
            ? null
            : item.fileName,
      };

  String? get _duration {
    final int? secs = item.durationSecs;
    if (secs == null || secs <= 0) {
      return null;
    }

    final int minutes = secs ~/ 60;
    final int seconds = secs % 60;
    return minutes >= 60
        ? '${minutes ~/ 60}h ${minutes % 60}m'
        : '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
