import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../errors/app_error.dart';

/// The app's "that call failed, try it again" state, for a screen whose whole
/// body is the failed thing.
///
/// Distinct from [NotFoundView], which is a settled answer and offers no retry,
/// and from an empty state (§6.4), which is the call *succeeding* with nothing.
/// A confirmed suspension should never reach here — screens check the latch
/// first and render `SchoolSuspendedView` instead (§5.2).
///
/// The icon switch is exhaustive over [AppError] so a new variant surfaces as
/// an analyzer error rather than silently picking the generic glyph (§6.3).
///
/// The library and My Classes screens predate this and still carry their own
/// private copies of the same layout; this is the version new screens should
/// use, and the one those two should collapse into when either is next touched.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    required this.error,
    required this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  final AppError error;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // A ListView, not a Center: a caller wrapping this in a RefreshIndicator
    // needs something scrollable to receive the gesture, and a failed load is
    // exactly where a user will try one.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          iconFor(error),
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          error.displayMessage,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Center(
          child: FilledButton.tonal(
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ),
      ],
    );
  }

  /// Exposed so a compact variant (a paginated list's footer, say) labels the
  /// same failure with the same glyph.
  static IconData iconFor(AppError error) => switch (error) {
    NetworkError() => Icons.wifi_off_outlined,
    UnauthorizedError() || ForbiddenError() => Icons.block_outlined,
    NotFoundError() => Icons.search_off_outlined,
    RateLimitedError() => Icons.timer_outlined,
    ValidationError() || UnknownError() => Icons.error_outline,
  };
}
