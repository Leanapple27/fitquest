import 'package:flutter/material.dart';

/// FitQuest color tokens derived from the existing visual contract.
abstract final class FqColors {
  // Brand
  static const Color primary = Color(0xFF302B63);
  static const Color primaryMid = Color(0xFF51489A);
  static const Color accent = Color(0xFFFFD166);
  static const Color lavender = Color(0xFFEDEBFF);

  // Neutrals (light)
  static const Color ink = Color(0xFF151B3D);
  static const Color muted = Color(0xFF555A72);
  static const Color scaffold = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);

  // Semantic (light)
  static const Color success = Color(0xFF27733A);
  static const Color successSurface = Color(0xFFEAF6EE);
  static const Color danger = Color(0xFFD94B4B);
  static const Color dangerSurface = Color(0xFFFFE9E7);
  static const Color energy = Color(0xFFFF7545);

  // Hero gradient (canonical)
  static const List<Color> heroGradient = [primary, primaryMid];

  // Dark-mode foundational tokens
  static const Color darkScaffold = Color(0xFF10111A);
  static const Color darkInk = Color(0xFFE8E9F2);
  static const Color darkSurface = Color(0xFF1A1C28);
  static const Color darkLavender = Color(0xFF2A2850);
  static const Color darkPrimary = Color(0xFF7C72E8);
}
