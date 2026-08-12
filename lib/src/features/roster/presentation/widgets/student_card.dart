import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/student_entity.dart';

/// One student on the roster (PRD §5.5.2).
///
/// **Read-only, and visibly so.** There is no tap target, no trailing chevron,
/// no overflow menu: `PATCH /students/:id` and the password routes are
/// SCHOOL_ADMIN-only and out of mobile scope entirely (§5.5.2, §8.6), and there
/// is no student-detail endpoint a TEACHER could open either. A row that
/// highlights but goes nowhere is worse than a row that plainly doesn't — the
/// same call [AssignmentCard] makes.
///
/// Three lines of information, each of which a teacher scanning a section
/// actually needs:
/// * the name, however much of one arrived ([StudentEntity.displayName]);
/// * the class — `'Grade 5 - A'`, or **Unassigned** for the unplaced student
///   §5.5.2 calls out, which is a real state and not missing data;
/// * the roll number and, only when it isn't the norm, the account status —
///   *Invite pending* is the row that explains why a student who exists has
///   never signed in.
class StudentCard extends StatelessWidget {
  const StudentCard({required this.student, super.key});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? email = student.email?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StudentAvatar(name: student.displayName),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    student.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (email != null && email.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacingSm),
                  _Tags(student: student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The class, the roll number, and the status when it is worth saying.
class _Tags extends StatelessWidget {
  const _Tags({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? roll = student.rollNumber;
    final String? status = student.status.label;

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingXs,
      children: <Widget>[
        // Unassigned is styled differently, not hidden: it is the thing a
        // teacher filtering by section needs to notice about this row.
        _Tag(
          label: student.sectionLabel ?? 'Unassigned',
          icon: student.isUnassigned
              ? Icons.help_outline
              : Icons.groups_outlined,
          background: student.isUnassigned
              ? colors.surfaceContainerHighest
              : colors.secondaryContainer,
          foreground: student.isUnassigned
              ? colors.onSurfaceVariant
              : colors.onSecondaryContainer,
        ),
        if (roll != null)
          _Tag(
            label: 'Roll no. $roll',
            icon: Icons.tag,
            background: colors.surfaceContainerHighest,
            foreground: colors.onSurfaceVariant,
          ),
        if (status != null)
          _Tag(
            label: status,
            icon: Icons.schedule_outlined,
            background: colors.tertiaryContainer,
            foreground: colors.onTertiaryContainer,
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// The student's initial, matching the library's and My Classes' cards: the API
/// carries no avatar (§8.5), and one generic glyph on every row is no help in
/// telling a screenful of students apart.
class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

  final String name;

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
    final String trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }
}
