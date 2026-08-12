import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/pagination/paged_list_state.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/paginated_list_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/student_entity.dart';
import 'roster_controller.dart';
import 'roster_query.dart';
import 'widgets/roster_search_field.dart';
import 'widgets/section_filter_button.dart';
import 'widgets/student_card.dart';

/// The teacher's "Roster" tab (PRD §5.5.2) — `GET /students`, the app's one
/// paginated list (§6.5).
///
/// **Read-only, by design and by API.** There is no create, edit, deactivate or
/// reset-password affordance anywhere on this screen or its rows: those routes
/// are SCHOOL_ADMIN-only and out of mobile scope entirely (§5.5.2, §8.6). The
/// only interactions are the two filters.
///
/// Layout is a fixed filter bar over the paginated list rather than a header
/// row inside it, so the search box and the section chip stay put — and stay
/// usable — while the first page of a new query loads, while an empty result is
/// explained, and while an error offers its retry. A filter that scrolls away
/// with the result it produced is a filter the user has to hunt for to undo.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab bar
/// (see `AppShell`).
class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);

    // Pre-empts everything below: while a school is suspended every
    // authenticated call 403s, and one explanatory screen beats the same
    // generic error on every tab (§5.2).
    if (suspended) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<PagedListState<StudentEntity>> roster =
        ref.watch(rosterControllerProvider);
    final RosterController controller =
        ref.read(rosterControllerProvider.notifier);
    final bool isFiltered = ref.watch(
      rosterQueryProvider.select((RosterQuery query) => query.isFiltered),
    );

    return Column(
      children: <Widget>[
        const _FilterBar(),
        Expanded(
          child: PaginatedListView<StudentEntity>(
            state: roster,
            itemBuilder: (BuildContext context, StudentEntity student) =>
                StudentCard(student: student),
            emptyBuilder: (BuildContext context) =>
                _RosterEmptyView(isFiltered: isFiltered),
            onLoadMore: controller.loadMore,
            onRefresh: controller.refresh,
            onRetry: controller.refresh,
            endOfListLabel: _endOfListLabel(roster.value),
          ),
        ),
      ],
    );
  }

  /// Only once every page is in, and only when the server counted them: it is a
  /// reassurance ("you have seen all of them"), not a statistic, so a guess
  /// would be worse than silence.
  String? _endOfListLabel(PagedListState<StudentEntity>? state) {
    final int? total = state?.total;
    if (state == null || state.hasMore || total == null) {
      return null;
    }
    return total == 1 ? '1 student' : '$total students';
  }
}

/// Search and section, side by side and always visible.
class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RosterSearchField(),
          SizedBox(height: AppConstants.spacingSm),
          Align(
            alignment: Alignment.centerLeft,
            child: SectionFilterButton(),
          ),
        ],
      ),
    );
  }
}

/// No rows came back — a legitimate answer (§6.4), and two quite different
/// situations that must not share one message.
///
/// A *filtered* roster answering with nothing means the search or the section
/// found nobody, and the fix is right there: clear them. An *unfiltered* one
/// means the school genuinely has no students on it yet, which is an admin's
/// job elsewhere and nothing this teacher can act on. Telling someone who
/// searched for "zainab" that their school has no students would be a lie about
/// the school; offering "clear filters" to someone with no filters set would be
/// a button that does nothing.
class _RosterEmptyView extends ConsumerWidget {
  const _RosterEmptyView({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    // A ListView, not a Center: the pull-to-refresh above needs something
    // scrollable to receive the gesture, and an empty state is exactly where a
    // user will try it.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingLg),
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
                    isFiltered ? Icons.search_off_outlined : Icons.people_alt_outlined,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  isFiltered ? 'No students match' : 'No students yet',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  isFiltered
                      ? 'Nobody on your school\'s roster matches this search '
                          'and section. Try a different name, or widen the '
                          'filter.'
                      : 'Students appear here once your school admin has '
                          'added them. Everyone in your school shows up on '
                          'this list, not only the classes you teach.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                if (isFiltered)
                  FilledButton.tonal(
                    onPressed: () =>
                        ref.read(rosterQueryProvider.notifier).clear(),
                    child: const Text('Clear filters'),
                  )
                else
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
