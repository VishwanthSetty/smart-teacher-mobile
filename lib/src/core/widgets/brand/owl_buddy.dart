import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The Play register's owl buddy (style guide: "Owl buddy on every screen").
///
/// Painted in code from the design's 104 × 108 vector, so it scales crisply
/// and needs no asset. Tapping it hops — the screen decides what the hop means
/// (the home screen cycles the speech bubble).
class OwlBuddy extends StatefulWidget {
  const OwlBuddy({this.size = 104, this.onTap, super.key});

  /// Width in logical pixels; height follows the 104:108 artwork.
  final double size;
  final VoidCallback? onTap;

  @override
  State<OwlBuddy> createState() => _OwlBuddyState();
}

class _OwlBuddyState extends State<OwlBuddy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  int _hops = 0;

  @override
  void dispose() {
    _hop.dispose();
    super.dispose();
  }

  void _tap() {
    _hops++;
    _hop.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Widget owl = SizedBox(
      width: widget.size,
      height: widget.size * 108 / 104,
      child: const CustomPaint(painter: _OwlPainter()),
    );

    return Semantics(
      button: widget.onTap != null,
      label: 'Owl buddy',
      child: GestureDetector(
        onTap: widget.onTap == null ? null : _tap,
        child: AnimatedBuilder(
          animation: _hop,
          builder: (BuildContext context, Widget? child) {
            final double t = _hop.value;
            // Up, land, a small second bounce — the design's `hopA/hopB`,
            // alternating the tilt direction on every hop.
            final double lift = t < 0.3
                ? -14 * (t / 0.3)
                : t < 0.6
                ? -14 * (1 - (t - 0.3) / 0.3)
                : t < 0.8
                ? -4 * ((t - 0.6) / 0.2)
                : -4 * (1 - (t - 0.8) / 0.2);
            final double tilt =
                (t < 0.6 ? -0.1 : 0.07) * (1 - t) * (_hops.isEven ? 1 : -1);
            return Transform.translate(
              offset: Offset(0, lift),
              child: Transform.rotate(angle: tilt, child: child),
            );
          },
          child: owl,
        ),
      ),
    );
  }
}

class _OwlPainter extends CustomPainter {
  const _OwlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 104, size.height / 108);

    Paint fill(Color c) => Paint()..color = c;
    Paint line(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 102), width: 60, height: 10),
      fill(AppColors.ink.withValues(alpha: 0.10)),
    );

    // Body.
    final Path body = Path()
      ..moveTo(18, 60)
      ..cubicTo(18, 30, 86, 30, 86, 60)
      ..lineTo(86, 78)
      ..cubicTo(86, 100, 18, 100, 18, 78)
      ..close();
    canvas
      ..drawPath(body, fill(AppColors.brindaBlue))
      ..drawPath(body, line(AppColors.deepBlueDark, 3.5));

    // Belly with feather ticks.
    final Path belly = Path()
      ..moveTo(32, 70)
      ..cubicTo(32, 58, 72, 58, 72, 70)
      ..lineTo(72, 80)
      ..cubicTo(72, 94, 32, 94, 32, 80)
      ..close();
    canvas.drawPath(belly, fill(AppColors.mist));
    final Paint tick = line(AppColors.waveSky, 2.5);
    for (final Offset o in const <Offset>[
      Offset(38, 76),
      Offset(50, 82),
      Offset(58, 74),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx, o.dy)
          ..quadraticBezierTo(o.dx + 4, o.dy - 4, o.dx + 8, o.dy),
        tick,
      );
    }

    // Eyes.
    for (final (Offset eye, Offset pupil, Offset glint)
        in const <(Offset, Offset, Offset)>[
          (Offset(38, 52), Offset(41, 53), Offset(43, 50.5)),
          (Offset(66, 52), Offset(63, 53), Offset(65, 50.5)),
        ]) {
      canvas
        ..drawCircle(eye, 14, fill(AppColors.white))
        ..drawCircle(eye, 14, line(AppColors.deepBlueDark, 3))
        ..drawCircle(pupil, 6.5, fill(AppColors.ink))
        ..drawCircle(glint, 2.2, fill(AppColors.white));
    }

    // Beak.
    final Path beak = Path()
      ..moveTo(47, 62)
      ..lineTo(57, 62)
      ..lineTo(52, 70)
      ..close();
    canvas
      ..drawPath(beak, fill(AppColors.sun))
      ..drawPath(beak, line(const Color(0xFFC98A0E), 2));

    // Cheeks.
    final Paint cheek = fill(AppColors.bubblegum.withValues(alpha: 0.55));
    canvas
      ..drawCircle(const Offset(26, 66), 5, cheek)
      ..drawCircle(const Offset(78, 66), 5, cheek);

    // Mortarboard and tassel.
    canvas
      ..drawPath(
        Path()
          ..moveTo(24, 30)
          ..lineTo(52, 18)
          ..lineTo(80, 30)
          ..lineTo(52, 42)
          ..close(),
        fill(AppColors.ink),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(40, 31, 24, 9),
          const Radius.circular(2),
        ),
        fill(AppColors.ink),
      )
      ..drawLine(
        const Offset(80, 30),
        const Offset(80, 44),
        line(AppColors.sun, 3),
      )
      ..drawCircle(const Offset(80, 46), 4, fill(AppColors.sun));
  }

  @override
  bool shouldRepaint(_OwlPainter oldDelegate) => false;
}
