import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Placeholder body for a shell tab whose feature hasn't been built yet.
///
/// Deliberately not an error or an empty state: both of those mean "the call
/// answered and there is nothing here", which is a real, designed condition in
/// this app (PRD §6.4). This one means the screen doesn't exist yet, and it
/// exists purely so the role-based shell (§5.7) can be navigated end to end
/// while the features behind its tabs land one at a time.
///
/// Every use of this is temporary — deleting the last one is the signal that
/// §5.4/§5.5 are done.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
    super.key,
  });

  final String title;

  /// What this screen will do once it's built — enough that a tap on the tab
  /// answers "is this broken, or just not here yet?".
  final String description;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'Coming soon',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
