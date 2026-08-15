import 'package:flutter/material.dart';

import 'fq_colors.dart';
import 'fq_radii.dart';
import 'fq_typography.dart';

/// Centralized FitQuest [ThemeData] built from audited design tokens.
abstract final class FqTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scaffold: FqColors.scaffold,
        ink: FqColors.ink,
        muted: FqColors.muted,
        surface: FqColors.surface,
        primary: FqColors.primary,
        onPrimary: FqColors.surface,
        secondary: FqColors.accent,
        onSecondary: FqColors.primary,
        lavender: FqColors.lavender,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scaffold: FqColors.darkScaffold,
        ink: FqColors.darkInk,
        muted: FqColors.darkInk.withValues(alpha: 0.65),
        surface: FqColors.darkSurface,
        primary: FqColors.darkPrimary,
        onPrimary: FqColors.darkInk,
        secondary: FqColors.accent,
        onSecondary: FqColors.darkScaffold,
        lavender: FqColors.darkLavender,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color ink,
    required Color muted,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color lavender,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: FqColors.danger,
      onError: surface,
      surface: surface,
      onSurface: ink,
    );

    final appBarTitleStyle = FqTypography.screenTitle(color: ink).copyWith(
      fontSize: 18,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: FqTypography.fontFamily,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      textTheme: FqTypography.textTheme(ink: ink, muted: muted),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink),
        titleTextStyle: appBarTitleStyle,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: FqRadii.cardBorder,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          textStyle: FqTypography.button(color: onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: FqRadii.buttonBorder,
          ),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          elevation: 0,
          textStyle: FqTypography.button(color: primary),
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: FqRadii.buttonBorder,
          ),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          textStyle: FqTypography.button(color: onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: FqRadii.buttonBorder,
          ),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: FqTypography.button(color: primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: FqRadii.inputBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: FqRadii.inputBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: FqRadii.inputBorder,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: FqRadii.inputBorder,
          borderSide: BorderSide(color: FqColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: FqRadii.inputBorder,
          borderSide: BorderSide(color: FqColors.danger, width: 1.5),
        ),
        hintStyle: FqTypography.body(color: muted),
        labelStyle: FqTypography.body(color: muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: FqRadii.sheetTopBorder,
        ),
        showDragHandle: true,
        dragHandleColor: muted.withValues(alpha: 0.35),
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: 0.08),
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondary,
        linearTrackColor: lavender,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: FqRadii.cardBorder,
        ),
      ),
      extensions: [
        FqThemeExtension(
          ink: ink,
          muted: muted,
          lavender: lavender,
          accent: FqColors.accent,
          success: FqColors.success,
          successSurface: FqColors.successSurface,
          danger: FqColors.danger,
          dangerSurface: FqColors.dangerSurface,
          energy: FqColors.energy,
          heroGradient: brightness == Brightness.light
              ? FqColors.heroGradient
              : [FqColors.darkPrimary, FqColors.primaryMid],
        ),
      ],
    );
  }
}

/// Theme extension exposing FitQuest semantic tokens to widgets.
class FqThemeExtension extends ThemeExtension<FqThemeExtension> {
  const FqThemeExtension({
    required this.ink,
    required this.muted,
    required this.lavender,
    required this.accent,
    required this.success,
    required this.successSurface,
    required this.danger,
    required this.dangerSurface,
    required this.energy,
    required this.heroGradient,
  });

  final Color ink;
  final Color muted;
  final Color lavender;
  final Color accent;
  final Color success;
  final Color successSurface;
  final Color danger;
  final Color dangerSurface;
  final Color energy;
  final List<Color> heroGradient;

  static FqThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<FqThemeExtension>()!;
  }

  @override
  FqThemeExtension copyWith({
    Color? ink,
    Color? muted,
    Color? lavender,
    Color? accent,
    Color? success,
    Color? successSurface,
    Color? danger,
    Color? dangerSurface,
    Color? energy,
    List<Color>? heroGradient,
  }) {
    return FqThemeExtension(
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      lavender: lavender ?? this.lavender,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      energy: energy ?? this.energy,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  FqThemeExtension lerp(
    covariant ThemeExtension<FqThemeExtension>? other,
    double t,
  ) {
    if (other is! FqThemeExtension) return this;

    return FqThemeExtension(
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      energy: Color.lerp(energy, other.energy, t)!,
      heroGradient: [
        Color.lerp(heroGradient[0], other.heroGradient[0], t)!,
        Color.lerp(heroGradient[1], other.heroGradient[1], t)!,
      ],
    );
  }
}
