import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/domain/resource_activity_entity.dart';
import '../saved_controller.dart';

/// The save toggle (mobile plan §5.4).
///
/// One widget for all three of its homes — the player app bar, the reader app
/// bar and a list row's trailing slot — because the control is the same
/// assertion everywhere and three copies would drift.
///
/// It renders **nothing** until the saved list has loaded. "Not saved" and "we
/// haven't asked yet" are different answers, and a hollow star that filled
/// itself a moment later would read as the app changing its mind; the same
/// reason the reader's *Mark as read* action waits for its cache read.
///
/// The toggle itself is optimistic and goes through the outbox, so the icon
/// flips under the finger and the request is durable before it is sent.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    required this.resourceId,
    required this.resourceType,
    this.title = '',
    this.isCompact = false,
    super.key,
  });

  final String resourceId;
  final ActivityResourceType resourceType;

  /// Captions the optimistic row until a refresh replaces it with the server's.
  final String title;

  /// A list row's trailing icon rather than an app-bar action — same behaviour,
  /// tighter hit area.
  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the whole controller rather than a `select`: the list is short,
    // and a selector over "does this id appear" rebuilds on the same changes.
    final AsyncValue<dynamic> saved = ref.watch(savedControllerProvider);
    if (saved.value == null ||
        resourceId.isEmpty ||
        resourceType == ActivityResourceType.unknown) {
      return const SizedBox.shrink();
    }
    final bool isSaved =
        ref.read(savedControllerProvider.notifier).isSaved(resourceId) ?? false;

    return IconButton(
      key: const ValueKey<String>('bookmark-toggle'),
      tooltip: isSaved ? 'Remove from Saved' : 'Save',
      visualDensity: isCompact ? VisualDensity.compact : null,
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: isSaved ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () => unawaited(
        ref
            .read(savedControllerProvider.notifier)
            .toggle(
              resourceId: resourceId,
              resourceType: resourceType,
              title: title,
            ),
      ),
    );
  }
}
