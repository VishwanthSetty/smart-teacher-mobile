import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/student_age_band.dart';
import '../../domain/curriculum_entity.dart';

/// One curriculum in the library list (PRD §5.4.1): the grade × subject
/// pairing, and the node/video/document counts that say how much is inside.
///
/// Opens the curriculum tree (§5.4.2). [onTap] is a callback rather than a
/// route push in here, so the card stays a rendering of one row and the
/// navigation stays with the screen that owns the list.
///
/// A curriculum whose counts are all zero is still tappable. Its tree has a
/// designed empty state of its own, and the counts are a snapshot the server
/// sent when the list loaded — refusing the tap on the strength of them would
/// lock a user out of content that has since been published.
class CurriculumCard extends StatelessWidget {
  const CurriculumCard({
    required this.curriculum,
    this.onTap,
    this.studentAgeBand,
    super.key,
  });

  final CurriculumEntity curriculum;
  final VoidCallback? onTap;
  final StudentAgeBand? studentAgeBand;

  @override
  Widget build(BuildContext context) {
    if (studentAgeBand case final StudentAgeBand ageBand) {
      return _StudentCurriculumCard(
        curriculum: curriculum,
        ageBand: ageBand,
        onTap: onTap,
      );
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SubjectAvatar(subjectName: curriculum.subjectName),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          curriculum.subjectName,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          curriculum.gradeLevelName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_statusLabel != null) ...<Widget>[
                    const SizedBox(width: AppConstants.spacingSm),
                    _StatusChip(label: _statusLabel!),
                  ],
                  // Says the row goes somewhere. Only drawn when it does, so
                  // the card can still be rendered inert.
                  if (onTap != null) ...<Widget>[
                    const SizedBox(width: AppConstants.spacingXs),
                    Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                  ],
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              // A curriculum with nothing in it is a real state, and three
              // zeroes in a row is a worse way to say so than one sentence.
              if (curriculum.isEmpty)
                Text(
                  'No content in this curriculum yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                )
              else
                // Wraps rather than overflows: three counts plus a long
                // subject name do not fit one line on a small phone.
                Wrap(
                  spacing: AppConstants.spacingMd,
                  runSpacing: AppConstants.spacingSm,
                  children: <Widget>[
                    _CountChip(
                      icon: Icons.account_tree_outlined,
                      count: curriculum.nodeCount,
                      singular: 'topic',
                      plural: 'topics',
                    ),
                    _CountChip(
                      icon: Icons.play_circle_outline,
                      count: curriculum.videoCount,
                      singular: 'video',
                      plural: 'videos',
                    ),
                    _CountChip(
                      icon: Icons.description_outlined,
                      count: curriculum.documentCount,
                      singular: 'document',
                      plural: 'documents',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Only for a curriculum that isn't live. `PUBLISHED` is the norm and needs
  /// no badge, and [CurriculumStatus.unknown] is a value this build doesn't
  /// understand — inventing a label for it would be worse than staying quiet.
  String? get _statusLabel => switch (curriculum.status) {
    CurriculumStatus.draft => 'Draft',
    CurriculumStatus.archived => 'Archived',
    CurriculumStatus.published || CurriculumStatus.unknown => null,
  };
}

class _StudentCurriculumCard extends StatelessWidget {
  const _StudentCurriculumCard({
    required this.curriculum,
    required this.ageBand,
    required this.onTap,
  });

  final CurriculumEntity curriculum;
  final StudentAgeBand ageBand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isRow = ageBand == StudentAgeBand.scholars;
    final double radius = switch (ageBand) {
      StudentAgeBand.explorers => 28,
      StudentAgeBand.learners => 24,
      StudentAgeBand.scholars => 20,
    };

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.sky50),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: isRow ? _rowBody(context) : _gridBody(context),
        ),
      ),
    );
  }

  Widget _gridBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final double iconSize = ageBand == StudentAgeBand.explorers ? 64 : 52;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SubjectIconTile(
              subjectName: curriculum.subjectName,
              size: iconSize,
            ),
            const Spacer(),
            if (_statusLabel case final String label) _StatusChip(label: label),
          ],
        ),
        const Spacer(),
        Text(
          curriculum.subjectName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          curriculum.gradeLevelName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _CompactCounts(curriculum: curriculum),
      ],
    );
  }

  Widget _rowBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: <Widget>[
        _SubjectIconTile(subjectName: curriculum.subjectName, size: 52),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(curriculum.subjectName, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                curriculum.gradeLevelName,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              _CompactCounts(curriculum: curriculum),
            ],
          ),
        ),
        if (_statusLabel case final String label) ...<Widget>[
          const SizedBox(width: AppConstants.spacingSm),
          _StatusChip(label: label),
        ],
        if (onTap != null) Icon(Icons.chevron_right, color: muted),
      ],
    );
  }

  String? get _statusLabel => switch (curriculum.status) {
    CurriculumStatus.draft => 'Draft',
    CurriculumStatus.archived => 'Archived',
    CurriculumStatus.published || CurriculumStatus.unknown => null,
  };
}

class _SubjectIconTile extends StatelessWidget {
  const _SubjectIconTile({required this.subjectName, required this.size});

  final String subjectName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final List<Color> tints = <Color>[
      AppColors.sky50,
      AppColors.sky100,
      AppColors.sky200,
      AppColors.sky300,
      AppColors.sky400,
    ];
    final int tintIndex =
        subjectName.runes.fold<int>(0, (int a, int b) => a + b) % tints.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tints[tintIndex],
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(_subjectIcon, color: AppColors.navy, size: size * 0.48),
    );
  }

  IconData get _subjectIcon {
    final String value = subjectName.toLowerCase();
    if (value.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (value.contains('science') || value.contains('physics')) {
      return Icons.science_rounded;
    }
    if (value.contains('english') || value.contains('language')) {
      return Icons.menu_book_rounded;
    }
    if (value.contains('social') ||
        value.contains('history') ||
        value.contains('geography')) {
      return Icons.public_rounded;
    }
    if (value.contains('computer')) {
      return Icons.computer_rounded;
    }
    return Icons.auto_stories_rounded;
  }
}

class _CompactCounts extends StatelessWidget {
  const _CompactCounts({required this.curriculum});

  final CurriculumEntity curriculum;

  @override
  Widget build(BuildContext context) {
    if (curriculum.isEmpty) {
      return Text(
        'No content in this curriculum yet.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingXs,
      children: <Widget>[
        _CountChip(
          icon: Icons.account_tree_outlined,
          count: curriculum.nodeCount,
          singular: 'topic',
          plural: 'topics',
        ),
        _CountChip(
          icon: Icons.play_circle_outline,
          count: curriculum.videoCount,
          singular: 'video',
          plural: 'videos',
        ),
        _CountChip(
          icon: Icons.description_outlined,
          count: curriculum.documentCount,
          singular: 'document',
          plural: 'documents',
        ),
      ],
    );
  }
}

/// The subject's initial, not an icon: the API carries no per-subject icon or
/// colour (§8.3), and one generic book glyph on every card is no help in
/// telling the rows apart.
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

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.icon,
    required this.count,
    required this.singular,
    required this.plural,
  });

  final IconData icon;
  final int count;
  final String singular;
  final String plural;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppConstants.spacingXs),
        Text(
          '$count ${count == 1 ? singular : plural}',
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
