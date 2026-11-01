import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

/// The Flutter expression of the Smart Teacher design system ("one brand,
/// three registers"): Deep Blue leads, Navy carries hero cards, Sun is the
/// one highlight, and the Focus/Teach ground is a cool off-white.
///
/// The Play register (Pre-primary to Grade 5) layers its clay styling on top
/// of this theme inside its own widgets rather than as a second theme, so a
/// pushed route from a Play screen still looks like the rest of the app.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.sky400 : AppColors.blue,
          onPrimary: isDark ? AppColors.darkBackground : AppColors.white,
          primaryContainer: isDark ? AppColors.darkOutline : AppColors.mist,
          onPrimaryContainer: isDark
              ? AppColors.darkText
              : AppColors.deepBlueDark,
          secondary: isDark ? AppColors.sky400 : AppColors.navy,
          onSecondary: isDark ? AppColors.darkBackground : AppColors.white,
          secondaryContainer: isDark ? AppColors.darkOutline : AppColors.mist,
          onSecondaryContainer: isDark ? AppColors.darkText : AppColors.navy,
          surface: isDark ? AppColors.darkBackground : AppColors.white,
          onSurface: isDark ? AppColors.darkText : AppColors.textPrimary,
          onSurfaceVariant: isDark ? AppColors.sky200 : AppColors.textSecondary,
          outline: isDark ? AppColors.darkOutline : AppColors.textDisabled,
          outlineVariant: isDark ? AppColors.darkOutline : AppColors.line,
          tertiary: isDark ? AppColors.sun : AppColors.sunLip,
          tertiaryContainer: isDark ? AppColors.darkOutline : AppColors.sunPale,
          onTertiaryContainer: isDark ? AppColors.darkText : AppColors.sunInk,
          surfaceContainerHighest: isDark
              ? AppColors.darkOutline
              : AppColors.line,
          error: AppColors.danger,
          onError: AppColors.white,
        );

    final TextTheme nunito = GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: colors.onSurface, displayColor: colors.onSurface);
    final TextTheme textTheme = nunito.copyWith(
      displayLarge: _heading(nunito.displayLarge),
      displayMedium: _heading(nunito.displayMedium),
      displaySmall: _heading(nunito.displaySmall),
      headlineLarge: _heading(nunito.headlineLarge),
      headlineMedium: _heading(nunito.headlineMedium),
      headlineSmall: _heading(nunito.headlineSmall),
      titleLarge: _heading(nunito.titleLarge),
      titleMedium: nunito.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: nunito.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.ground,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
          TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.ground,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.sky400 : AppColors.focusText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1.5,
        shadowColor: isDark
            ? Colors.transparent
            : AppColors.brandNavy.withValues(alpha: 0.10),
        color: isDark ? AppColors.darkSurface : AppColors.white,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isDark ? AppColors.darkOutline : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        constraints: const BoxConstraints(minHeight: 56),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.fieldBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 18,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        indicatorColor: isDark ? AppColors.darkOutline : AppColors.mist,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? (isDark ? AppColors.sky400 : AppColors.deepBlue)
                : (isDark ? AppColors.sky200 : AppColors.focusTextSubtle),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? (isDark ? AppColors.sky400 : AppColors.deepBlueDark)
                : (isDark ? AppColors.sky200 : AppColors.focusTextSubtle),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
        circularTrackColor: colors.primaryContainer,
      ),
    );
  }

  static TextStyle? _heading(TextStyle? style) => style == null
      ? null
      : GoogleFonts.fredoka(
          textStyle: style.copyWith(fontWeight: FontWeight.w700),
        );
}

class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.035, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
