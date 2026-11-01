import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The Brinda wave — the brand's one decorative motif.
///
/// Play screens draw it across the top of the page (with the sun); Focus draws
/// it only along the bottom of the hero card. It is decoration: it sits behind
/// content, takes no input and is excluded from semantics.
class BrindaWave extends StatelessWidget {
  const BrindaWave({
    this.withSky = true,
    this.withSun = false,
    this.opacity = 1,
    super.key,
  });

  /// Fill the area above the wave with the pale mist colour (Play header).
  final bool withSky;

  /// Draw the dashed-ring sun in the top-right corner (Play header).
  final bool withSun;

  /// Fades both strokes — the hero card runs them at about half strength.
  final double opacity;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: CustomPaint(
        painter: _WavePainter(
          withSky: withSky,
          withSun: withSun,
          opacity: opacity,
        ),
        size: Size.infinite,
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.withSky,
    required this.withSun,
    required this.opacity,
  });

  final bool withSky;
  final bool withSun;
  final double opacity;

  /// The design's artboard is 390 × 260; everything scales off that.
  static const double _designWidth = 390;
  static const double _designHeight = 260;

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / _designWidth;
    final double sy = size.height / _designHeight;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    if (withSky) {
      final Path sky = Path()
        ..moveTo(p(-20, 170).dx, p(-20, 170).dy)
        ..cubicTo(
          p(80, 120).dx,
          p(80, 120).dy,
          p(170, 210).dx,
          p(170, 210).dy,
          p(260, 160).dx,
          p(260, 160).dy,
        )
        ..cubicTo(
          p(340, 115).dx,
          p(340, 115).dy,
          p(380, 120).dx,
          p(380, 120).dy,
          p(420, 150).dx,
          p(420, 150).dy,
        )
        ..lineTo(p(420, -10).dx, p(420, -10).dy)
        ..lineTo(p(-20, -10).dx, p(-20, -10).dy)
        ..close();
      canvas.drawPath(sky, Paint()..color = AppColors.mist);
    }

    Paint stroke(Color color, double width) => Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width * sx;

    final Path upper = Path()
      ..moveTo(p(-10, 200).dx, p(-10, 200).dy)
      ..cubicTo(
        p(90, 150).dx,
        p(90, 150).dy,
        p(180, 230).dx,
        p(180, 230).dy,
        p(280, 185).dx,
        p(280, 185).dy,
      )
      ..cubicTo(
        p(360, 150).dx,
        p(360, 150).dy,
        p(380, 150).dx,
        p(380, 150).dy,
        p(410, 168).dx,
        p(410, 168).dy,
      );
    canvas.drawPath(upper, stroke(AppColors.waveSky, 7));

    final Path lower = Path()
      ..moveTo(p(30, 222).dx, p(30, 222).dy)
      ..cubicTo(
        p(120, 182).dx,
        p(120, 182).dy,
        p(210, 250).dx,
        p(210, 250).dy,
        p(300, 208).dx,
        p(300, 208).dy,
      )
      ..cubicTo(
        p(370, 185).dx,
        p(370, 185).dy,
        p(380, 188).dx,
        p(380, 188).dy,
        p(400, 196).dx,
        p(400, 196).dy,
      );
    canvas.drawPath(lower, stroke(AppColors.brindaBlue, 9));

    if (withSun) {
      final Offset centre = Offset(size.width - 54 * sx, 44 * sx);
      canvas.drawCircle(centre, 22 * sx, Paint()..color = AppColors.sun);
      final Paint ring = Paint()
        ..color = AppColors.sun.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * sx;
      // Dashed ring: twelve short arcs.
      const int dashes = 14;
      const double sweep = 6.283185307179586 / dashes;
      for (int i = 0; i < dashes; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: centre, radius: 31 * sx),
          i * sweep,
          sweep * 0.4,
          false,
          ring,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.withSky != withSky ||
      oldDelegate.withSun != withSun ||
      oldDelegate.opacity != opacity;
}
