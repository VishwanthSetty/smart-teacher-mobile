import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// The Home tabs' own header (Focus and Teach registers): an optional leading
/// avatar, a greeting with a caption, and trailing 48 px action tiles.
///
/// The Home tabs draw this *instead of* the shell's app bar — the design opens
/// on a greeting, not on a title that says "Home".
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.trailing = const <Widget>[],
    super.key,
  });

  final String title;

  /// Muted caption under the title (Focus: grade and section).
  final String? subtitle;

  /// Muted caption above the title (Teach: today's date).
  final String? eyebrow;

  final Widget? leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle caption = GoogleFonts.nunito(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: <Widget>[
          if (leading case final Widget avatar) ...<Widget>[
            avatar,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow case final String text when text.isNotEmpty)
                  Text(text, style: caption),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (subtitle case final String text when text.isNotEmpty)
                  Text(text, style: caption),
              ],
            ),
          ),
          for (final Widget action in trailing) ...<Widget>[
            const SizedBox(width: 10),
            action,
          ],
        ],
      ),
    );
  }
}

/// A navy rounded-square avatar holding the person's initial(s).
class HomeAvatar extends StatelessWidget {
  const HomeAvatar({
    required this.name,
    this.initialsColor = AppColors.sun,
    this.twoLetters = false,
    super.key,
  });

  final String? name;
  final Color initialsColor;
  final bool twoLetters;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: twoLetters ? 48 : 44,
        height: twoLetters ? 48 : 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.brandNavy,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          initialsOf(name, max: twoLetters ? 2 : 1),
          style: GoogleFonts.fredoka(
            fontSize: twoLetters ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: initialsColor,
          ),
        ),
      ),
    );
  }
}

/// A Focus/Teach section heading, with an optional text action or any trailing
/// widget (the task segment control).
class FocusSectionHeading extends StatelessWidget {
  const FocusSectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (trailing case final Widget widget)
            Padding(padding: const EdgeInsets.only(right: 8), child: widget)
          else if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `'Good morning, Ravi'` — first name only, since a full name in a greeting
/// reads like a form letter. With no name, just the salutation.
String greetingFor(DateTime now, String? name) {
  final String salutation = now.hour < 12
      ? 'Good morning'
      : now.hour < 17
      ? 'Good afternoon'
      : 'Good evening';
  final String first = firstNameOf(name);
  return first.isEmpty ? salutation : '$salutation, $first';
}

String firstNameOf(String? name) {
  final String trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? '' : trimmed.split(RegExp(r'\s+')).first;
}

String initialsOf(String? name, {int max = 2}) {
  final List<String> words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((String w) => w.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) {
    return '?';
  }
  return words.take(max).map((String w) => w[0].toUpperCase()).join();
}
