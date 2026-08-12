import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// The app's one generic "not found" state, for a `404` from the API
/// (PRD §4, §6.3).
///
/// It exists as a shared widget because the rule it implements is easy to
/// break one screen at a time. Single-item reads — `GET /curricula/:id/tree`,
/// `GET /videos/:id`, `GET /documents/:id` — answer a plain `404` **both** for
/// "no such record" and for "it exists, but you aren't entitled to it". That is
/// deliberate: it stops a single-item read leaking more than the list does. So
/// the app must never try to distinguish the two, and must never phrase this
/// state as a refusal — no "you don't have access", no "not allowed", no
/// "contact your admin". Anything of that shape tells an unentitled user that
/// the record exists.
///
/// Note this is *not* the router's unknown-route page: that one means the app
/// has no screen for a URL, which is a different fact and can safely say so.
///
/// There is no retry. A `404` is a final answer, and a button that re-asks a
/// settled question reads as the app being broken. [onBack] is offered instead
/// when there is somewhere sensible to return to.
class NotFoundView extends StatelessWidget {
  const NotFoundView({
    this.message,
    this.onBack,
    this.backLabel = 'Go back',
    super.key,
  });

  /// The API's own `404` message when it sent one — already generic, since
  /// `AppError.fromDioException` never dresses a `404` up as a permission
  /// error. Falls back to copy of the same shape.
  final String? message;

  final VoidCallback? onBack;
  final String backLabel;

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
                  Icons.search_off_outlined,
                  size: 40,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                'Not found',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                message ?? "We couldn't find what you were looking for.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onBack != null) ...<Widget>[
                const SizedBox(height: AppConstants.spacingXl),
                FilledButton.tonal(
                  onPressed: onBack,
                  child: Text(backLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
