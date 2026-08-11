import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// The dedicated "your school's access is suspended" screen (PRD §5.2).
///
/// Shown *instead of* a screen's own content once
/// `schoolSuspensionProvider` latches: while a school is suspended every
/// authenticated call 403s, so the alternative is the same generic error
/// repeated on every screen the user tries, none of which says what is
/// actually wrong or who can fix it.
///
/// Deliberately terminal — there is no "retry" here, because nothing the user
/// can do from the app changes the answer, and a retry button that always
/// fails reads as the app being broken rather than the account being
/// suspended. Signing out is the only offered action, and it is required: the
/// suspension lasts the access token's lifetime, so a user who has switched
/// schools needs a way back to the login screen.
///
/// It takes [onSignOut] as a callback rather than reaching for the auth
/// feature's logout controller — `core/` must not depend on a feature.
class SchoolSuspendedView extends StatelessWidget {
  const SchoolSuspendedView({
    required this.onSignOut,
    this.schoolName,
    super.key,
  });

  /// Named when known, so a user in more than one tenant can see *which*
  /// school is suspended.
  final String? schoolName;

  final VoidCallback onSignOut;

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
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block_outlined,
                  size: 40,
                  color: colors.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                'Access suspended',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                schoolName == null
                    ? "Your school's access to Smart Teacher is suspended. "
                        'Contact your school admin to restore it.'
                    : "$schoolName's access to Smart Teacher is suspended. "
                        'Contact your school admin to restore it.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXl),
              FilledButton.tonal(
                onPressed: onSignOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
