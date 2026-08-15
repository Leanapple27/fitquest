import 'package:flutter/material.dart';

import 'fq_colors.dart';

/// FitQuest elevation tokens derived from the existing visual contract.
abstract final class FqShadows {
  /// Soft card shadow — black 0.06, blur 14, offset (0, 6).
  static List<BoxShadow> cardSoft({Color? color}) => [
        BoxShadow(
          color: (color ?? Colors.black).withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  /// Brand hero shadow — primary 0.18, blur 22, offset (0, 10).
  static List<BoxShadow> heroBrand({Color? color}) => [
        BoxShadow(
          color: (color ?? FqColors.primary).withValues(alpha: 0.18),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  /// Floating navigation shadow — black 0.08, blur 24, offset (0, 8).
  static List<BoxShadow> navFloat({Color? color}) => [
        BoxShadow(
          color: (color ?? Colors.black).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
