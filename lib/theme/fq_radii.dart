import 'package:flutter/material.dart';

/// FitQuest border-radius tokens derived from the existing visual contract.
abstract final class FqRadii {
  static const double chip = 12;
  static const double input = 16;
  static const double button = 16;
  static const double card = 20;
  static const double hero = 24;
  static const double navigation = 26;
  static const double sheet = 28;

  static BorderRadius get chipBorder => BorderRadius.circular(chip);
  static BorderRadius get inputBorder => BorderRadius.circular(input);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get heroBorder => BorderRadius.circular(hero);
  static BorderRadius get navigationBorder => BorderRadius.circular(navigation);
  static BorderRadius get sheetBorder => BorderRadius.circular(sheet);
  static BorderRadius get sheetTopBorder =>
      const BorderRadius.vertical(top: Radius.circular(sheet));
}
