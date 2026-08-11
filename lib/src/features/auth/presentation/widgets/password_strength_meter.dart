import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../password_strength.dart';

/// Advisory strength readout under a new-password field.
///
/// Advisory is the operative word: it never blocks submission (the field's
/// validator owns that), it just gives the user something to react to while
/// they type. Colours come from the scheme rather than hardcoded red/amber/
/// green so both themes stay legible.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final PasswordStrength strength = estimatePasswordStrength(password);

    final Color color = switch (strength) {
      PasswordStrength.weak => colors.error,
      PasswordStrength.fair => colors.secondary,
      PasswordStrength.strong => colors.primary,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingSm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.spacingXs),
              child: LinearProgressIndicator(
                value: strength.fraction,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            strength.label,
            // The label carries the meaning for anyone who can't distinguish
            // the bar's colour — the bar alone would be the only signal
            // otherwise.
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
