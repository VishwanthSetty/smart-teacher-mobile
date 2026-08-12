import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/content_node_entity.dart';
import 'curriculum_tree_controller.dart';
import 'widgets/content_node_tile.dart';

/// The curriculum tree (PRD §5.4.2) — chapters, their sub-topics, and the
/// videos and documents at each level, behind one library card.
///
/// A pushed route rather than a shell tab, so unlike [LibraryScreen] this one
/// brings its own `Scaffold`: it sits *over* the shell, and its back button is
/// the way out.
///
/// Four outcomes, and the `404` is the one with a rule attached:
/// * nodes → the drill-down;
/// * an empty tree → a designed empty state (§6.4), because a published,
///   entitled curriculum with nothing authored in it yet is a real state;
/// * `404` → [NotFoundView], the *same* generic state the rest of the app uses.
///   The backend answers `404` both for "no such curriculum" and for "exists,
///   but not yours" (§4), on purpose, and this screen must not narrow that
///   down. Phrasing it as a refusal would confirm the record exists to exactly
///   the user who isn't allowed to know;
/// * anything else → an error with a retry.
class CurriculumTreeScreen extends ConsumerWidget {
  const CurriculumTreeScreen({
    required this.curriculumId,
    this.title,
    super.key,
  });

  final String curriculumId;

  /// The subject name, handed over by the card that was tapped. Absent when the
  /// route was reached directly, in which case the tree's own echo of it — or
  /// failing that a generic title — stands in.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<ContentTreeEntity> tree = ref.watch(
      curriculumTreeControllerProvider(curriculumId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? tree.value?.subjectName ?? 'Curriculum'),
      ),
      body: SafeArea(
        child: suspended
            // As everywhere else (§5.2): while a school is suspended every
            // authenticated call 403s, so one explanatory screen beats a
            // generic error on each one.
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(
                      curriculumTreeControllerProvider(curriculumId).notifier,
                    )
                    .refresh(),
                child: tree.when(
                  data: (ContentTreeEntity data) => data.isEmpty
                      ? const _EmptyCurriculumView()
                      : _TreeList(
                          nodes: data.nodes,
                          onItemTap:
                              (ContentItemEntity item, ContentItemKind kind) =>
                                  _openItem(context, item, kind),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace _) =>
                      _buildError(context, ref, AppError.from(error)),
                ),
              ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, AppError error) {
    // The one branch this screen makes on an error variant, and the reason
    // is §4 rather than presentation: a 404 is a final answer that must read
    // as "not found", never as "not allowed", and re-asking it would be
    // pointless as well as misleading.
    if (error is NotFoundError) {
      return NotFoundView(
        message: error.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to library',
      );
    }

    return ErrorRetryView(
      error: error,
      onRetry: () => unawaited(
        ref
            .read(curriculumTreeControllerProvider(curriculumId).notifier)
            .refresh(),
      ),
    );
  }

  /// The handoff to the player/reader, both of which are out of scope this
  /// phase (§5.4.2): the stub route carries the item id, so the real screen can
  /// drop in behind it without the tree changing.
  void _openItem(
    BuildContext context,
    ContentItemEntity item,
    ContentItemKind kind,
  ) {
    final String path = switch (kind) {
      ContentItemKind.video => AppRoutes.videoPath(item.id),
      ContentItemKind.document => AppRoutes.documentPath(item.id),
    };

    context.push(path, extra: item.displayTitle(kind));
  }
}

class _TreeList extends StatelessWidget {
  const _TreeList({required this.nodes, required this.onItemTap});

  final List<ContentNodeEntity> nodes;
  final void Function(ContentItemEntity item, ContentItemKind kind) onItemTap;

  @override
  Widget build(BuildContext context) {
    // `.builder` over the root chapters; everything deeper is built by the
    // expansion tiles only once a branch is actually opened, so a large
    // curriculum costs one row per chapter on arrival.
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      itemCount: nodes.length,
      itemBuilder: (BuildContext _, int index) =>
          ContentNodeTile(node: nodes[index], onItemTap: onItemTap),
    );
  }
}

/// The curriculum opened, and has no chapters at all (PRD §6.4).
///
/// Not an error and not a "not found": the actor is entitled to this
/// curriculum, the server said so by answering at all — there is simply nothing
/// authored in it yet. Distinct in copy from an empty *library*, which means
/// the actor is entitled to nothing.
class _EmptyCurriculumView extends StatelessWidget {
  const _EmptyCurriculumView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    // Scrollable, so the pull-to-refresh above still has a gesture target —
    // content arriving is exactly what this state is waiting for.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_off_outlined,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Nothing in this curriculum yet',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Chapters, videos and documents appear here as they are '
                  'published.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Pull down to check again.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
