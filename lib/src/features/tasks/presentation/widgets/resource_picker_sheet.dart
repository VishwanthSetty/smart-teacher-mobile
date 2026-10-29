import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../activity/domain/resource_activity_entity.dart';
import '../../../library/domain/content_node_entity.dart';
import '../../../library/domain/curriculum_entity.dart';
import '../../../library/presentation/curriculum_tree_controller.dart';
import '../../../library/presentation/library_controller.dart';
import '../assign_task_controller.dart';

/// Picks the resource to assign (mobile plan §5.8, step 1).
///
/// A drill-down over the material the teacher can already reach: the curricula
/// from `GET /curricula`, then the tree from `GET /curricula/:id/tree`. Nothing
/// new is fetched and nothing is filtered client-side for *entitlement* — both
/// lists are already scoped server-side.
///
/// **Teacher-audience curricula are excluded**, and that one filter is not an
/// entitlement guess: `TasksService.create` refuses a non-`STUDENT`-audience
/// resource with a `400`, because assigning teacher material would hand
/// students a resource their own scope refuses to open (backend plan §4.3).
/// §5.8 is explicit that the picker should block it so the error is unreachable
/// in practice, rather than surfacing after three steps of a wizard.
Future<AssignableResource?> showResourcePickerSheet(BuildContext context) {
  return showModalBottomSheet<AssignableResource>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext context) => const FractionallySizedBox(
      heightFactor: 0.9,
      child: _CurriculumStep(),
    ),
  );
}

class _CurriculumStep extends ConsumerWidget {
  const _CurriculumStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CurriculumEntity>> curricula = ref.watch(
      libraryControllerProvider,
    );

    return _SheetScaffold(
      title: 'Choose material',
      child: curricula.when(
        data: (List<CurriculumEntity> rows) {
          final List<CurriculumEntity> assignable = rows
              .where(
                (CurriculumEntity row) =>
                    row.audience != CurriculumAudience.teacher && !row.isEmpty,
              )
              .toList(growable: false);

          if (assignable.isEmpty) {
            return const _NothingAssignable();
          }
          return ListView.separated(
            itemCount: assignable.length,
            separatorBuilder: (BuildContext context, int _) =>
                const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final CurriculumEntity curriculum = assignable[index];
              return ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(curriculum.subjectName),
                subtitle: Text(curriculum.gradeLevelName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => unawaited(
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          _NodeStep(curriculum: curriculum),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () =>
              unawaited(ref.read(libraryControllerProvider.notifier).refresh()),
        ),
      ),
    );
  }
}

class _NodeStep extends ConsumerWidget {
  const _NodeStep({required this.curriculum});

  final CurriculumEntity curriculum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ContentTreeEntity> tree = ref.watch(
      curriculumTreeControllerProvider(curriculum.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text(curriculum.subjectName)),
      body: SafeArea(
        child: tree.when(
          data: (ContentTreeEntity data) => data.isEmpty
              ? const _NothingAssignable()
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingSm,
                  ),
                  children: <Widget>[
                    for (final ContentNodeEntity node in data.nodes)
                      _NodeTile(node: node),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => ErrorRetryView(
            error: AppError.from(error),
            onRetry: () => unawaited(
              ref
                  .read(curriculumTreeControllerProvider(curriculum.id).notifier)
                  .refresh(),
            ),
          ),
        ),
      ),
    );
  }
}

/// A branch of the tree, recursively.
///
/// Empty branches are greyed out and refuse to expand, read from
/// [ContentNodeEntity.videoCountDeep] / [documentCountDeep] rather than by
/// walking `children` — the counts already describe the whole subtree, and
/// recomputing them would be a second, disagreeing source of truth.
class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node, this.depth = 0});

  final ContentNodeEntity node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (node.isEmptyDeep) {
      return Padding(
        padding: EdgeInsets.only(left: depth * AppConstants.spacingMd),
        child: ListTile(
          enabled: false,
          leading: const Icon(Icons.folder_open_outlined),
          title: Text(node.displayTitle),
          subtitle: const Text('Nothing in here'),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * AppConstants.spacingSm),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(node.displayTitle, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${node.videoCountDeep} videos · ${node.documentCountDeep} documents',
          style: theme.textTheme.bodySmall,
        ),
        children: <Widget>[
          for (final ContentItemEntity item in node.videos)
            _ItemTile(item: item, kind: ContentItemKind.video),
          for (final ContentItemEntity item in node.documents)
            _ItemTile(item: item, kind: ContentItemKind.document),
          for (final ContentNodeEntity child in node.children)
            _NodeTile(node: child, depth: depth + 1),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.kind});

  final ContentItemEntity item;
  final ContentItemKind kind;

  @override
  Widget build(BuildContext context) {
    final bool isVideo = kind == ContentItemKind.video;

    return ListTile(
      leading: Icon(
        isVideo ? Icons.play_circle_outline : Icons.picture_as_pdf_outlined,
      ),
      title: Text(item.displayTitle(kind)),
      onTap: () {
        final AssignableResource picked = AssignableResource(
          id: item.id,
          type: isVideo
              ? ActivityResourceType.video
              : ActivityResourceType.document,
          title: item.displayTitle(kind),
        );
        // Pops the pushed tree route and then the sheet itself, handing the
        // choice back to whoever opened it.
        Navigator.of(context)
          ..pop()
          ..pop(picked);
      },
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingSm,
          ),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

/// Nothing here can be assigned.
///
/// Two causes land here and the copy covers both without naming a role: the
/// teacher's library holds only teacher-audience material, or the
/// student-audience curricula it holds are empty. Which applies is a
/// server-side fact this sheet deliberately cannot see.
class _NothingAssignable extends StatelessWidget {
  const _NothingAssignable();

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
              Icons.library_books_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Nothing to assign here',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Only material published for students can be assigned, and there '
              'is none in this part of your library yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
