import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../activity/domain/resource_activity_entity.dart';
import '../../../library/domain/curriculum_entity.dart';
import '../../../library/presentation/library_controller.dart';
import '../../domain/search_query.dart';
import '../search_controller.dart';

/// The filter bottom sheet (mobile plan §5.5).
///
/// Subject and grade come from `libraryControllerProvider` — the curricula this
/// actor can already reach — rather than from a separate lookup. That is not a
/// convenience: a filter offering a subject the search could never return would
/// be a client-side scope guess, and the library list is by definition exactly
/// the set the search is scoped to (§4.1).
///
/// [withAudience] is passed in, never derived from the role. A student's search
/// is pinned to their own entitlement scope server-side, so an audience control
/// would change nothing for them — and a control that does nothing is worse
/// than none.
class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({required this.withAudience, super.key});

  final bool withAudience;

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet> {
  /// Edited locally and applied on **Apply**, not per tap: each change is a
  /// request, and a sheet that re-queried on every chip would fire five for one
  /// visit.
  late SearchQuery _draft = ref.read(searchQueryProvider);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<CurriculumEntity> curricula =
        ref.watch(libraryControllerProvider).value ?? const <CurriculumEntity>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          AppConstants.spacingSm,
          AppConstants.spacingLg,
          AppConstants.spacingLg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Filters', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacingMd),

              _Group(
                label: 'Type',
                children: <Widget>[
                  _chip(
                    'All',
                    _draft.type == null,
                    () => setState(
                      () => _draft = _draft.copyWith(clearType: true),
                    ),
                  ),
                  _chip(
                    'Videos',
                    _draft.type == ActivityResourceType.video,
                    () => setState(
                      () => _draft = _draft.copyWith(
                        type: ActivityResourceType.video,
                      ),
                    ),
                  ),
                  _chip(
                    'Documents',
                    _draft.type == ActivityResourceType.document,
                    () => setState(
                      () => _draft = _draft.copyWith(
                        type: ActivityResourceType.document,
                      ),
                    ),
                  ),
                ],
              ),

              _Group(
                label: 'Progress',
                children: <Widget>[
                  _chip(
                    'Any',
                    _draft.progress == null,
                    () => setState(
                      () => _draft = _draft.copyWith(clearProgress: true),
                    ),
                  ),
                  _chip(
                    'Not started',
                    _draft.progress == ActivityProgressStatus.notStarted,
                    () => setState(
                      () => _draft = _draft.copyWith(
                        progress: ActivityProgressStatus.notStarted,
                      ),
                    ),
                  ),
                  _chip(
                    'In progress',
                    _draft.progress == ActivityProgressStatus.inProgress,
                    () => setState(
                      () => _draft = _draft.copyWith(
                        progress: ActivityProgressStatus.inProgress,
                      ),
                    ),
                  ),
                  _chip(
                    'Completed',
                    _draft.progress == ActivityProgressStatus.completed,
                    () => setState(
                      () => _draft = _draft.copyWith(
                        progress: ActivityProgressStatus.completed,
                      ),
                    ),
                  ),
                ],
              ),

              if (_subjects(curricula) case final List<_Option> subjects
                  when subjects.isNotEmpty)
                _Group(
                  label: 'Subject',
                  children: <Widget>[
                    _chip(
                      'Any',
                      _draft.subjectId == null,
                      () => setState(
                        () => _draft = _draft.copyWith(clearSubject: true),
                      ),
                    ),
                    for (final _Option subject in subjects)
                      _chip(
                        subject.label,
                        _draft.subjectId == subject.id,
                        () => setState(
                          () => _draft = _draft.copyWith(
                            subjectId: subject.id,
                          ),
                        ),
                      ),
                  ],
                ),

              // Grade is a teacher control in the plan's table because a
              // student has exactly one. It is shown whenever the actor's own
              // library spans more than one grade, which is the same fact
              // stated without reading the role.
              if (_grades(curricula) case final List<_Option> grades
                  when grades.length > 1)
                _Group(
                  label: 'Grade',
                  children: <Widget>[
                    _chip(
                      'Any',
                      _draft.gradeLevelId == null,
                      () => setState(
                        () => _draft = _draft.copyWith(clearGradeLevel: true),
                      ),
                    ),
                    for (final _Option grade in grades)
                      _chip(
                        grade.label,
                        _draft.gradeLevelId == grade.id,
                        () => setState(
                          () => _draft = _draft.copyWith(
                            gradeLevelId: grade.id,
                          ),
                        ),
                      ),
                  ],
                ),

              if (widget.withAudience)
                _Group(
                  label: 'Audience',
                  children: <Widget>[
                    _chip(
                      'Any',
                      _draft.audience == null,
                      () => setState(
                        () => _draft = _draft.copyWith(clearAudience: true),
                      ),
                    ),
                    _chip(
                      'For students',
                      _draft.audience == CurriculumAudience.student,
                      () => setState(
                        () => _draft = _draft.copyWith(
                          audience: CurriculumAudience.student,
                        ),
                      ),
                    ),
                    _chip(
                      'For teachers',
                      _draft.audience == CurriculumAudience.teacher,
                      () => setState(
                        () => _draft = _draft.copyWith(
                          audience: CurriculumAudience.teacher,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: AppConstants.spacingLg),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () =>
                        setState(() => _draft = _draft.withoutFilters()),
                    child: const Text('Clear all'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).apply(_draft);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (bool _) => onTap(),
  );

  /// De-duplicated, because one subject appears once per grade it is taught in.
  List<_Option> _subjects(List<CurriculumEntity> curricula) =>
      _distinct(<_Option>[
        for (final CurriculumEntity row in curricula)
          _Option(row.subjectId, row.subjectName),
      ]);

  List<_Option> _grades(List<CurriculumEntity> curricula) =>
      _distinct(<_Option>[
        for (final CurriculumEntity row in curricula)
          _Option(row.gradeLevelId, row.gradeLevelName),
      ]);

  List<_Option> _distinct(List<_Option> options) {
    final Set<String> seen = <String>{};
    return options
        .where((_Option option) => option.id.isNotEmpty && seen.add(option.id))
        .toList(growable: false);
  }
}

class _Option {
  const _Option(this.id, this.label);

  final String id;
  final String label;
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: AppConstants.spacingSm),
      Wrap(
        spacing: AppConstants.spacingSm,
        runSpacing: AppConstants.spacingSm,
        children: children,
      ),
      const SizedBox(height: AppConstants.spacingMd),
    ],
  );
}
