import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/section_entity.dart';
import '../roster_query.dart';
import '../sections_controller.dart';

/// The roster's "filter by section" control (PRD §5.5.2), populated from
/// `GET /sections` (§5.5.3).
///
/// The whole reason §5.5.3 exists: `GET /students` takes `sectionId` as an
/// **opaque filter** and returns no joined section list, so the ids this hands
/// back have to come from somewhere else. Nothing here parses or interprets an
/// id — it is passed through to the query untouched.
///
/// A sheet rather than a dropdown, because the list can fail. A school's
/// sections are one more network call, and the three answers it can give —
/// rows, none, or an error — each need a sentence; a `DropdownButton` has
/// nowhere to put one, and an empty menu that silently does nothing is the
/// worst of the three.
///
/// The button itself never disables: the sections load lazily when the sheet is
/// first opened (the controller is held for the session, §5.5.3, so it loads
/// once), which keeps a section list the teacher may never touch off the
/// roster's first paint.
class SectionFilterButton extends ConsumerWidget {
  const SectionFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selectedId = ref.watch(
      rosterQueryProvider.select((RosterQuery query) => query.sectionId),
    );
    // Watched only once a section is actually selected, so the chip alone
    // doesn't pull the section list onto the roster's first paint — nothing
    // can be selected before the sheet has been opened, and opening it is what
    // loads the list. A selected section missing from that list still labels
    // itself sensibly below: the fallback names it as *a* filter rather than
    // claiming there is none.
    final List<SectionEntity> sections = selectedId == null
        ? const <SectionEntity>[]
        : ref.watch(sectionsControllerProvider).value ??
              const <SectionEntity>[];

    final String label = switch (selectedId) {
      null => 'All sections',
      final String id =>
        sections
                .where((SectionEntity section) => section.id == id)
                .map((SectionEntity section) => section.displayLabel)
                .firstOrNull ??
            'Filtered by section',
    };

    return ActionChip(
      avatar: Icon(
        selectedId == null ? Icons.filter_list : Icons.filter_alt,
        size: 18,
      ),
      label: Text(label),
      tooltip: 'Filter by section',
      onPressed: () => unawaited(_open(context, ref)),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => const _SectionSheet(),
    );
  }
}

class _SectionSheet extends ConsumerWidget {
  const _SectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String? selectedId = ref.watch(
      rosterQueryProvider.select((RosterQuery query) => query.sectionId),
    );
    final AsyncValue<List<SectionEntity>> sections = ref.watch(
      sectionsControllerProvider,
    );

    void select(String? sectionId) {
      ref.read(rosterQueryProvider.notifier).setSection(sectionId);
      Navigator.of(context).pop();
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
              child: Text(
                'Filter by section',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: sections.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingXl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object error, StackTrace _) => _SectionsUnavailable(
                  error: AppError.from(error),
                  onRetry: () => unawaited(
                    ref.read(sectionsControllerProvider.notifier).refresh(),
                  ),
                ),
                data: (List<SectionEntity> rows) => RadioGroup<String?>(
                  groupValue: selectedId,
                  onChanged: select,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      // Always first, always available: clearing the filter
                      // must not depend on the list that failed to load.
                      const RadioListTile<String?>(
                        value: null,
                        title: Text('All sections'),
                      ),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppConstants.spacingLg),
                          child: Text(
                            'Your school has no sections set up yet, so there '
                            'is nothing to filter by. Every student shows as '
                            'Unassigned until an admin places them.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        for (final SectionEntity section in rows)
                          RadioListTile<String?>(
                            value: section.id,
                            title: Text(section.displayLabel),
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

/// The section list itself failed. The roster behind the sheet is unaffected —
/// it is a separate call — so this explains the picker, not the screen.
class _SectionsUnavailable extends StatelessWidget {
  const _SectionsUnavailable({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

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
        ],
      ),
    );
  }
}
