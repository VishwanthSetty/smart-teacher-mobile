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
import '../../profile/presentation/profile_view.dart';
import '../domain/curriculum_entity.dart';
import 'library_controller.dart';
import 'widgets/curriculum_card.dart';

/// The Library tab (PRD §5.4.1) — the list of curricula this actor can open,
/// and the only tab both shells have in common (§5.7).
///
/// The list arrives **already scoped server-side** by role and entitlement
/// (§4). There is no client-side filtering here of any kind, and this screen
/// never reads `MeEntity.role`: what `GET /curricula` returns is what it draws.
///
/// Three answers, three distinct states:
/// * rows → the cards;
/// * `200 []` → [_LibraryEmptyView], a designed empty state — an unentitled
///   school and a student with no active enrollment both legitimately land
///   here, and neither is an error (§6.4);
/// * a thrown [AppError] → [ErrorRetryView], with a retry.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab bar
/// (see `AppShell`).
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<List<CurriculumEntity>> curricula = ref.watch(
      libraryControllerProvider,
    );

    // Pre-empts everything below: while a school is suspended every
    // authenticated call 403s, and one explanatory screen beats the same
    // generic error on every tab (§5.2).
    if (suspended) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(libraryControllerProvider.notifier).refresh(),
      child: curricula.when(
        data: (List<CurriculumEntity> items) => items.isEmpty
            ? const _LibraryEmptyView()
            : _CurriculumList(curricula: items),
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

class _CurriculumList extends StatelessWidget {
  const _CurriculumList({required this.curricula});

  final List<CurriculumEntity> curricula;

  @override
  Widget build(BuildContext context) {
    // `.builder`, and no pagination affordance: `/curricula` returns a flat,
    // unpaginated array (§6.5), but it is a whole school's catalogue in the
    // no-assignments teacher case, so the rows are still built lazily.
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: curricula.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppConstants.spacingMd),
      itemBuilder: (BuildContext context, int index) {
        final CurriculumEntity curriculum = curricula[index];

        return CurriculumCard(
          curriculum: curriculum,
          // Pushed, not switched to a tab: the tree (§5.4.2) is a drill-down
          // out of this list, and `push` is what gives it a back button.
          // The subject name rides along so the tree can title itself without
          // waiting for its own fetch.
          onTap: () => context.push(
            AppRoutes.curriculumTreePath(curriculum.id),
            extra: curriculum.subjectName,
          ),
        );
      },
    );
  }
}

/// `200 []` — the library is genuinely empty (PRD §6.4).
///
/// This is an *expected* answer, not a failure, so it gets its own copy rather
/// than "something went wrong": the school may not be entitled to any curricula
/// yet, or the account may not be placed in a grade or class yet (§4). The
/// wording covers both without naming a role — which reason applies is a
/// server-side fact this screen deliberately cannot see, and guessing at it
/// from the role would be exactly the client-side scoping §4 forbids.
///
/// It offers a refresh because both causes are fixed by someone else, off in
/// the admin app: coming back to a screen that can't be re-checked would mean
/// restarting the app to find out.
class _LibraryEmptyView extends StatelessWidget {
  const _LibraryEmptyView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    // A ListView, not a Center: the pull-to-refresh above needs something
    // scrollable to receive the gesture, and an empty state is exactly where a
    // user will try it.
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
                    Icons.local_library_outlined,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Your library is empty',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Curricula appear here once your school has been given '
                  'access to them, and once your account has been placed in a '
                  'grade or class. Your school admin can set both up.',
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
