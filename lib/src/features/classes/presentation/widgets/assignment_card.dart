import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/teacher_assignment_entity.dart';

/// One assignment in My Classes (PRD §5.5.1): the subject, and the class it is
/// taught to.
///
/// The two forms §5.5.1 requires are one string on the entity
/// ([TeacherAssignmentEntity.displayLabel]) rather than a layout branch here —
/// `'Mathematics — Grade 5 - A'` and `'Mathematics — all sections'` are the
/// same sentence with a different second half, and splitting them across two
/// widget shapes would make the school-wide row read as a broken version of
/// the normal one instead of a different, valid kind of grant.
///
/// The caption underneath is what actually distinguishes them: a school-wide
/// grant gets a line saying so, because "all sections" on its own invites the
/// reading "you teach every section", which is not what a legacy CSV grant
/// means.
///
/// Not tappable. §5.5.1 specifies a list and nothing behind it, and the roster
/// (§5.5.2) — the one screen that consumes these rows' `sectionId` — is still
/// a placeholder. A row that highlights but goes nowhere is worse than a row
/// that plainly doesn't.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({required this.assignment, super.key});

  final TeacherAssignmentEntity assignment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? code = assignment.subjectCode?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SubjectAvatar(subjectName: assignment.subjectName),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    assignment.displayLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (assignment.classLabel == null) ...<Widget>[
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      'Assigned for the whole school — this subject is not '
                      'tied to a section.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ] else if (code != null && code.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The subject's initial, matching the library's cards: the API carries no
/// per-subject icon or colour (§8.4), and one generic glyph on every row is no
/// help in telling a screenful of subjects apart.
class _SubjectAvatar extends StatelessWidget {
  const _SubjectAvatar({required this.subjectName});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return CircleAvatar(
      radius: 22,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  String get _initial {
    final String trimmed = subjectName.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }
}
