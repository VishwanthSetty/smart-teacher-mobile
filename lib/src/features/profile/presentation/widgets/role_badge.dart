import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/me_entity.dart';

/// The actor's role, as a chip (PRD §5.2).
///
/// The label is derived from [UserRole] rather than from any raw string the
/// API sent, so an unrecognised role degrades to a neutral "Member" instead of
/// showing a server enum name to a user (§8.2 — `unknown` is a value we must
/// render, not a bug).
class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon, size: 16, color: colors.onSecondaryContainer),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String get label => switch (role) {
        UserRole.teacher => 'Teacher',
        UserRole.student => 'Student',
        UserRole.unknown => 'Member',
      };

  IconData get _icon => switch (role) {
        UserRole.teacher => Icons.co_present_outlined,
        UserRole.student => Icons.backpack_outlined,
        UserRole.unknown => Icons.person_outline,
      };
}
