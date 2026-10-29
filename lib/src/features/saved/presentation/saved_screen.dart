import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/bookmark_entity.dart';
import '../domain/collection_entity.dart';
import 'collections_controller.dart';
import 'saved_controller.dart';
import 'widgets/collection_picker_sheet.dart';
import 'widgets/saved_card.dart';

/// **Saved** (mobile plan §5.4), as a bare body.
///
/// One widget for both roles, with the difference passed **in** rather than
/// read from `MeEntity.role` — the same arrangement `ProgressSummaryScreen`
/// uses. The student shell drops this straight into its Saved tab; the teacher
/// reaches [SavedScreen] below, which wraps it with its own chrome.
///
/// [withCollections] is what separates the two experiences:
/// * `false` — a flat list of saved items with a type filter. A student's saved
///   list *is* the bookmarks with no collection, because students never create
///   one (backend plan §1.2).
/// * `true` — a **Collections** tab plus an **Unfiled** tab, and the
///   create/rename/delete controls. `/me/collections` is role-gated to
///   `TEACHER`, so a student shell simply never calls it.
class SavedView extends ConsumerWidget {
  const SavedView({this.withCollections = false, super.key});

  final bool withCollections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }
    return withCollections
        ? const _TeacherSaved()
        : const _StudentSaved();
  }
}

/// The `/saved` route — the teacher's way in, since their tab set has no Saved
/// tab of its own (mobile plan §1).
class SavedScreen extends StatelessWidget {
  const SavedScreen({this.withCollections = true, super.key});

  final bool withCollections;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Saved')),
    body: SafeArea(child: SavedView(withCollections: withCollections)),
  );
}

/// The student's flat list plus its type filter.
class _StudentSaved extends ConsumerStatefulWidget {
  const _StudentSaved();

  @override
  ConsumerState<_StudentSaved> createState() => _StudentSavedState();
}

class _StudentSavedState extends ConsumerState<_StudentSaved> {
  /// Local, not a notifier: unlike the roster's filters this one changes no
  /// request — `/me/bookmarks` takes no parameters at all, so the narrowing is
  /// purely a view over rows already held.
  ActivityResourceType? _type;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BookmarkEntity>> saved = ref.watch(
      savedControllerProvider,
    );

    return Column(
      children: <Widget>[
        _TypeFilterChips(
          selected: _type,
          onSelected: (ActivityResourceType? type) =>
              setState(() => _type = type),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(savedControllerProvider.notifier).refresh(),
            child: saved.when(
              data: (List<BookmarkEntity> rows) => _SavedList(
                bookmarks: _filtered(rows),
                isFiltered: _type != null,
                onClearFilter: () => setState(() => _type = null),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace _) => ErrorRetryView(
                error: AppError.from(error),
                onRetry: () => unawaited(
                  ref.read(savedControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BookmarkEntity> _filtered(List<BookmarkEntity> rows) {
    final ActivityResourceType? type = _type;
    if (type == null) {
      return rows;
    }
    return rows
        .where((BookmarkEntity row) => row.kind == type)
        .toList(growable: false);
  }
}

/// The teacher's two tabs (mobile plan §5.4).
class _TeacherSaved extends ConsumerStatefulWidget {
  const _TeacherSaved();

  @override
  ConsumerState<_TeacherSaved> createState() => _TeacherSavedState();
}

class _TeacherSavedState extends ConsumerState<_TeacherSaved>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Collections'),
            Tab(text: 'Unfiled'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[_CollectionsTab(), _UnfiledTab()],
          ),
        ),
      ],
    );
  }
}

class _CollectionsTab extends ConsumerWidget {
  const _CollectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CollectionEntity>> collections = ref.watch(
      collectionsControllerProvider,
    );

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: () =>
              ref.read(collectionsControllerProvider.notifier).refresh(),
          child: collections.when(
            data: (List<CollectionEntity> rows) => rows.isEmpty
                ? const _NoCollections()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spacingMd,
                      AppConstants.spacingMd,
                      AppConstants.spacingMd,
                      // Room for the FAB, which would otherwise sit on the
                      // last row.
                      AppConstants.spacingXl * 2,
                    ),
                    itemCount: rows.length,
                    separatorBuilder: (BuildContext context, int _) =>
                        const SizedBox(height: AppConstants.spacingSm),
                    itemBuilder: (BuildContext context, int index) =>
                        _CollectionTile(collection: rows[index]),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => ErrorRetryView(
              error: AppError.from(error),
              onRetry: () => unawaited(
                ref.read(collectionsControllerProvider.notifier).refresh(),
              ),
            ),
          ),
        ),
        Positioned(
          right: AppConstants.spacingMd,
          bottom: AppConstants.spacingMd,
          child: FloatingActionButton.extended(
            heroTag: 'new-collection',
            onPressed: () => unawaited(showCollectionNameDialog(context, ref)),
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('New'),
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  const _CollectionTile({required this.collection});

  final CollectionEntity collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookmarkEntity> items =
        ref
            .watch(savedControllerProvider)
            .value
            ?.where(
              (BookmarkEntity row) =>
                  (row.collectionId ?? row.collection?.id) == collection.id,
            )
            .toList(growable: false) ??
        const <BookmarkEntity>[];

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(Icons.folder_outlined),
        title: Text(collection.displayName),
        subtitle: Text(
          items.length == 1 ? '1 item' : '${items.length} items',
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'More',
          onSelected: (String action) => unawaited(
            switch (action) {
              'rename' => showCollectionNameDialog(
                context,
                ref,
                existing: collection,
              ),
              _ => _confirmDelete(context, ref),
            },
          ),
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
            PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
          ],
        ),
        children: <Widget>[
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppConstants.spacingMd),
              child: Text('Nothing filed here yet.'),
            )
          else
            for (final BookmarkEntity bookmark in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingMd,
                  0,
                  AppConstants.spacingMd,
                  AppConstants.spacingSm,
                ),
                child: SavedCard(
                  bookmark: bookmark,
                  onTap: () => _open(context, bookmark),
                  onFile: () =>
                      unawaited(showCollectionPickerSheet(context, bookmark)),
                  onRemove: () => unawaited(
                    ref
                        .read(savedControllerProvider.notifier)
                        .remove(bookmark.resourceId),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// Deleting **un-files** the items rather than unsaving them (backend plan
  /// §1.2). The dialog says so, because the two are easy to confuse and only
  /// one of them is recoverable by pulling to refresh.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete "${collection.displayName}"?'),
        content: const Text(
          'The items in it stay saved — they just move back to Unfiled.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await _run(
        context,
        ref,
        () => ref
            .read(collectionsControllerProvider.notifier)
            .delete(collection.id),
      );
    }
  }
}

class _UnfiledTab extends ConsumerWidget {
  const _UnfiledTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookmarkEntity>> saved = ref.watch(
      savedControllerProvider,
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(savedControllerProvider.notifier).refresh(),
      child: saved.when(
        data: (List<BookmarkEntity> rows) => _SavedList(
          bookmarks: rows
              .where((BookmarkEntity row) => row.isUnfiled)
              .toList(growable: false),
          isFiltered: false,
          onClearFilter: () {},
          withFiling: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () =>
              unawaited(ref.read(savedControllerProvider.notifier).refresh()),
        ),
      ),
    );
  }
}

class _SavedList extends ConsumerWidget {
  const _SavedList({
    required this.bookmarks,
    required this.isFiltered,
    required this.onClearFilter,
    this.withFiling = false,
  });

  final List<BookmarkEntity> bookmarks;
  final bool isFiltered;
  final VoidCallback onClearFilter;
  final bool withFiling;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookmarks.isEmpty) {
      return _SavedEmptyState(
        isFiltered: isFiltered,
        onClearFilter: onClearFilter,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: bookmarks.length,
      separatorBuilder: (BuildContext context, int _) =>
          const SizedBox(height: AppConstants.spacingSm),
      itemBuilder: (BuildContext context, int index) {
        final BookmarkEntity bookmark = bookmarks[index];
        return SavedCard(
          bookmark: bookmark,
          onTap: () => _open(context, bookmark),
          onFile: withFiling
              ? () => unawaited(showCollectionPickerSheet(context, bookmark))
              : null,
          onRemove: () => unawaited(
            ref
                .read(savedControllerProvider.notifier)
                .remove(bookmark.resourceId),
          ),
        );
      },
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({required this.selected, required this.onSelected});

  final ActivityResourceType? selected;
  final ValueChanged<ActivityResourceType?> onSelected;

  static const List<(String, ActivityResourceType?)> _options =
      <(String, ActivityResourceType?)>[
        ('All', null),
        ('Videos', ActivityResourceType.video),
        ('Documents', ActivityResourceType.document),
      ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingMd,
      vertical: AppConstants.spacingSm,
    ),
    child: Row(
      children: <Widget>[
        for (final (String label, ActivityResourceType? type)
            in _options) ...<Widget>[
          ChoiceChip(
            label: Text(label),
            selected: selected == type,
            onSelected: (bool _) => onSelected(type),
          ),
          const SizedBox(width: AppConstants.spacingSm),
        ],
      ],
    ),
  );
}

/// `200 []` — nothing saved (PRD §6.4).
///
/// Splits in two for the same reason the roster's and history's do: "nothing
/// matches this filter" needs a way back out, and "you haven't saved anything"
/// needs none.
class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState({
    required this.isFiltered,
    required this.onClearFilter,
  });

  final bool isFiltered;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.bookmark_border,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          isFiltered ? 'Nothing matches this filter' : 'Nothing saved yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          isFiltered
              ? 'Try a different type, or clear the filter to see everything.'
              : 'Tap the bookmark icon on a video or document and it will '
                    'show up here.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (isFiltered) ...<Widget>[
          const SizedBox(height: AppConstants.spacingLg),
          Center(
            child: FilledButton.tonal(
              onPressed: onClearFilter,
              child: const Text('Clear filter'),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoCollections extends StatelessWidget {
  const _NoCollections();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.folder_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'No collections yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Group saved material for a lesson — "Plants — Monday", say — then '
          'file items into it from the Unfiled tab.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Create or rename, in one dialog — the two differ only in their title and in
/// whether the field starts populated.
Future<void> showCollectionNameDialog(
  BuildContext context,
  WidgetRef ref, {
  CollectionEntity? existing,
}) async {
  final TextEditingController controller = TextEditingController(
    text: existing?.name ?? '',
  );

  final String? name = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(existing == null ? 'New collection' : 'Rename collection'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (String value) => Navigator.of(context).pop(value),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();

  final String trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty || !context.mounted) {
    return;
  }

  await _run(
    context,
    ref,
    () => existing == null
        ? ref.read(collectionsControllerProvider.notifier).create(trimmed)
        : ref
              .read(collectionsControllerProvider.notifier)
              .rename(id: existing.id, name: trimmed),
  );
}

/// Runs a collection mutation and reports its failure in place.
///
/// A snackbar rather than an error state, because the list behind it is still
/// correct: the create or delete simply didn't happen. A duplicate name arrives
/// as a `409`, and the server's own wording is what the teacher needs to read.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on AppError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
  }
}

void _open(BuildContext context, BookmarkEntity bookmark) {
  final String id = bookmark.resourceId;
  if (id.isEmpty) {
    return;
  }
  context.push(
    bookmark.isVideo ? AppRoutes.videoPath(id) : AppRoutes.documentPath(id),
    extra: bookmark.title,
  );
}
