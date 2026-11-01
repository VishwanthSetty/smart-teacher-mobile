import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';

/// A Play-register "clay" surface: a flat colour block sitting on a darker lip
/// (a hard, unblurred shadow straight down), which sinks onto its lip when
/// pressed.
///
/// Used for every tappable thing in the Pre-primary to Grade 5 screens — tiles,
/// the Today card, round play buttons. With no [onTap] it is a plain surface
/// and does not animate.
class Clay extends StatefulWidget {
  const Clay({
    required this.color,
    required this.lip,
    required this.child,
    this.onTap,
    this.radius = 26,
    this.lipDepth = 6,
    this.shape = BoxShape.rectangle,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
    this.border,
    super.key,
  });

  final Color color;
  final Color lip;
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final double lipDepth;
  final BoxShape shape;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final BoxBorder? border;

  @override
  State<Clay> createState() => _ClayState();
}

class _ClayState extends State<Clay> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap != null && value != _pressed) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pressing sinks the face by most of the lip, so the lip all but vanishes.
    final double sink = _pressed ? widget.lipDepth - 2 : 0;
    final bool circle = widget.shape == BoxShape.circle;

    final Widget surface = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, sink, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        shape: widget.shape,
        border: widget.border,
        borderRadius: circle ? null : BorderRadius.circular(widget.radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: widget.lip,
            offset: Offset(0, widget.lipDepth - sink),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return surface;
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: Padding(
          // Leave room for the lip so it isn't clipped by a tight parent.
          padding: EdgeInsets.only(bottom: widget.lipDepth),
          child: surface,
        ),
      ),
    );
  }
}

/// Scale-on-press for Focus and Teach cards (0.97, the design's `.press`).
class PressScale extends StatefulWidget {
  const PressScale({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppConstants.pressDuration,
        child: widget.child,
      ),
    );
  }
}
