import 'package:flutter/material.dart';

import 'fq_colors.dart';

/// FitQuest typography tokens derived from the existing visual contract.
abstract final class FqTypography {
  static const String fontFamily = 'Arial';

  static TextStyle screenTitle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w900,
        color: color ?? FqColors.ink,
      );

  static TextStyle sectionLabel({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: color ?? FqColors.muted,
      );

  static TextStyle cardTitle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color ?? FqColors.ink,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? FqColors.ink,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: color,
      );

  static TextTheme textTheme({required Color ink, required Color muted}) {
    return TextTheme(
      displayLarge: screenTitle(color: ink).copyWith(fontSize: 36),
      displayMedium: screenTitle(color: ink).copyWith(fontSize: 30),
      displaySmall: screenTitle(color: ink).copyWith(fontSize: 24),
      headlineLarge: screenTitle(color: ink).copyWith(fontSize: 20),
      headlineMedium: cardTitle(color: ink),
      headlineSmall: cardTitle(color: ink).copyWith(fontSize: 15),
      titleLarge: cardTitle(color: ink),
      titleMedium: body(color: ink).copyWith(fontWeight: FontWeight.w700),
      titleSmall: body(color: ink).copyWith(fontSize: 13),
      bodyLarge: body(color: ink).copyWith(fontSize: 16),
      bodyMedium: body(color: ink),
      bodySmall: body(color: muted).copyWith(fontSize: 12),
      labelLarge: button(color: ink),
      labelMedium: sectionLabel(color: muted),
      labelSmall: sectionLabel(color: muted).copyWith(fontSize: 10),
    );
  }
}
