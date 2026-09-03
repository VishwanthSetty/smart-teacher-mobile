import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Passive startup surface; session routing remains in the router redirect.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.sky50, AppColors.white],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const Positioned(left: -36, top: 96, child: _SoftOrb(size: 120)),
            const Positioned(
              right: -22,
              bottom: 132,
              child: _SoftOrb(size: 92),
            ),
            SafeArea(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  tween: Tween<double>(begin: 0.88, end: 1),
                  builder:
                      (BuildContext context, double scale, Widget? child) =>
                          Opacity(
                            opacity: scale.clamp(0, 1),
                            child: Transform.scale(scale: scale, child: child),
                          ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.white,
                          size: 46,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      Text(
                        AppConstants.appName,
                        style: text.headlineMedium?.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        'Learning, made simple',
                        style: text.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      const _SplashDots(),
                      const SizedBox(height: AppConstants.spacingMd),
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sky400.withValues(alpha: 0.20),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SplashDots extends StatefulWidget {
  const _SplashDots();

  @override
  State<_SplashDots> createState() => _SplashDotsState();
}

class _SplashDotsState extends State<_SplashDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < 3; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: 8),
            Opacity(
              opacity:
                  0.35 +
                  (0.65 *
                      ((math.sin(
                                (_controller.value * math.pi * 2) -
                                    (index * 0.8),
                              ) +
                              1) /
                          2)),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.sky400,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(dimension: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
