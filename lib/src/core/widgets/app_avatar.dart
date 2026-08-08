import 'package:flutter/material.dart';

/// A circular avatar that renders a person's initials over a color derived
/// deterministically from their name, so the same name always looks the same.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Stable hue from the name keeps avatars consistent between builds.
    final hue = (name.hashCode % 360).abs().toDouble();
    final background = HSLColor.fromAHSL(1, hue, 0.4, 0.85).toColor();
    final foreground = HSLColor.fromAHSL(1, hue, 0.6, 0.30).toColor();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? scheme.secondaryContainer
          : background,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? scheme.onSecondaryContainer
              : foreground,
        ),
      ),
    );
  }
}
