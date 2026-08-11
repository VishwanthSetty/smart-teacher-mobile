import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// How an [AuthBanner] reads. The three auth screens all have to say things
/// that are *not* interchangeable — "you got it wrong", "not yet", "that
/// worked" — and colouring every one of them error-red trains people to
/// ignore the banner.
enum AuthBannerTone {
  /// Something is wrong and the user has to change something.
  error,

  /// Nothing is wrong; the server is throttling. Waiting is the fix.
  waiting,

  /// The action completed.
  success,
}

/// The in-page message block used by every auth screen.
///
/// In-page and persistent rather than a snackbar on purpose: each of these is
/// a state the user has to act on (fix a field, wait out a lockout, go check
/// their inbox), not a transient notification that should slide away on its
/// own while they're reading it.
class AuthBanner extends StatelessWidget {
  const AuthBanner({
    required this.message,
    required this.tone,
    this.details = const <String>[],
    this.icon,
    super.key,
  });

  final String message;
  final AuthBannerTone tone;

  /// Extra lines rendered as bullets — the API's per-field complaints from a
  /// `ValidationError`, when it sends any.
  final List<String> details;

  /// Overrides the tone's default icon, for cases the tone alone doesn't
  /// distinguish (a disabled account vs. a wrong password are both errors,
  /// but a padlock says more than a warning triangle).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final (Color background, Color foreground) = switch (tone) {
      AuthBannerTone.error => (colors.errorContainer, colors.onErrorContainer),
      AuthBannerTone.waiting => (
          colors.secondaryContainer,
          colors.onSecondaryContainer,
        ),
      AuthBannerTone.success => (
          colors.tertiaryContainer,
          colors.onTertiaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon ?? _defaultIcon, color: foreground, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
                ...details.map(
                  (String detail) => Padding(
                    padding: const EdgeInsets.only(top: AppConstants.spacingXs),
                    child: Text(
                      '• $detail',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _defaultIcon => switch (tone) {
        AuthBannerTone.error => Icons.error_outline,
        AuthBannerTone.waiting => Icons.timer_outlined,
        AuthBannerTone.success => Icons.check_circle_outline,
      };
}
