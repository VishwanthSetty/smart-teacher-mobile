import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/bookmark_entity.dart';
import '../../domain/collection_entity.dart';
import '../collections_controller.dart';

/// "File into…" — moves one saved item in or out of a collection
/// (mobile plan §5.4).
///
/// A sheet rather than a dropdown, for the same reason the roster's section
/// picker is one: the collection list is a network call whose three answers —
/// rows, none, or an error — each need a sentence, and a menu has nowhere to
/// put one.
///
/// **Unfiled is the first option and always available**, even when the list
/// failed: taking something *out* of a collection must not depend on being able
/// to read the collections.
Future<void> showCollectionPickerSheet(
  BuildContext context,
  BookmarkEntity bookmark,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => _CollectionPickerSheet(
      bookmark: bookmark,
    ),
  );
}

class _CollectionPickerSheet extends ConsumerWidget {
  const _CollectionPickerSheet({required this.bookmark});

  final BookmarkEntity bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<CollectionEntity>> collections = ref.watch(
      collectionsControllerProvider,
    );
    final String? currentId = bookmark.collectionId ?? bookmark.collection?.id;

    Future<void> select(String? collectionId) async {
      final NavigatorState navigator = Navigator.of(context);
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      if (collectionId == currentId) {
        navigator.pop();
        return;
      }
      try {
        // Out of the old one first, then into the new. Two calls because the
        // endpoint is a move *per collection*, not a "set the field" — and
        // doing them in this order means a failure halfway leaves the item
        // unfiled rather than in two places.
        if (currentId != null) {
          await ref
              .read(collectionsControllerProvider.notifier)
              .moveBookmark(
                collectionId: currentId,
                bookmarkId: bookmark.id,
                isAdding: false,
              );
        }
        if (collectionId != null) {
          await ref
              .read(collectionsControllerProvider.notifier)
              .moveBookmark(
                collectionId: collectionId,
                bookmarkId: bookmark.id,
                isAdding: true,
              );
        }
      } on AppError catch (error) {
        messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
      }
      navigator.pop();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingSm,
              ),
              child: Text('File into', style: theme.textTheme.titleMedium),
            ),
            Flexible(
              child: collections.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingXl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object error, StackTrace _) => _Unavailable(
                  error: AppError.from(error),
                  onRetry: () => unawaited(
                    ref.read(collectionsControllerProvider.notifier).refresh(),
                  ),
                  onUnfile: () => unawaited(select(null)),
                ),
                data: (List<CollectionEntity> rows) => RadioGroup<String?>(
                  groupValue: currentId,
                  onChanged: (String? id) => unawaited(select(id)),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      const RadioListTile<String?>(
                        value: null,
                        title: Text('Unfiled'),
                      ),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppConstants.spacingLg),
                          child: Text(
                            'You have no collections yet. Create one from the '
                            'Collections tab, then file items into it.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        for (final CollectionEntity collection in rows)
                          RadioListTile<String?>(
                            value: collection.id,
                            title: Text(collection.displayName),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The collection list itself failed. The saved item behind the sheet is
/// unaffected — a different call — so this explains the picker, not the screen,
/// and still offers the one move that needs no list.
class _Unavailable extends StatelessWidget {
  const _Unavailable({
    required this.error,
    required this.onRetry,
    required this.onUnfile,
  });

  final AppError error;
  final VoidCallback onRetry;
  final VoidCallback onUnfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            error.displayMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
          TextButton(onPressed: onUnfile, child: const Text('Unfile')),
        ],
      ),
    );
  }
}
