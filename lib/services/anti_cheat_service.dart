import 'package:flutter/foundation.dart';

enum AntiCheatStatus {
  verified,
  flagged,
  blocked,
}

class StepValidationResult {
  final bool isValid;
  final int validSteps;
  final String? warningMessage;

  const StepValidationResult({
    required this.isValid,
    required this.validSteps,
    this.warningMessage,
  });
}

class LocationValidationResult {
  final bool isValid;
  final String? reason;

  const LocationValidationResult({
    required this.isValid,
    this.reason,
  });
}

class XpValidationResult {
  final int allowedXp;
  final bool isCapped;
  final String? message;

  const XpValidationResult({
    required this.allowedXp,
    required this.isCapped,
    this.message,
  });
}

class AntiCheatService {
  /// Maximum XP allowed to be earned in a single day across all activities
  static const int maxDailyXpLimit = 500;

  /// Maximum human sprinting speed threshold in km/h (Usain Bolt peak ~44 km/h, amateur sprint ~20 km/h)
  static const double maxHumanSpeedKmh = 24.0;

  /// Maximum realistic human step cadence (steps per second)
  static const double maxCadenceStepsPerSecond = 4.0;

  /// Minimum acceptable GPS accuracy in meters for campus hotspot check-ins
  static const double maxAcceptableGpsAccuracyMeters = 80.0;

  /// Validates incoming step events against cadence and travel speed
  static StepValidationResult validateStepIncrement({
    required int stepsIncrement,
    required int elapsedSeconds,
    double? currentSpeedKmh,
  }) {
    if (stepsIncrement <= 0) {
      return const StepValidationResult(isValid: true, validSteps: 0);
    }

    // Check for vehicle transit speed
    if (currentSpeedKmh != null && currentSpeedKmh > maxHumanSpeedKmh) {
      if (kDebugMode) {
        debugPrint('[AntiCheat] High transit speed detected: ${currentSpeedKmh.toStringAsFixed(1)} km/h. Steps filtered.');
      }
      return StepValidationResult(
        isValid: false,
        validSteps: 0,
        warningMessage: 'Vehicle transit detected (${currentSpeedKmh.toStringAsFixed(0)} km/h). Steps paused.',
      );
    }

    // Check cadence (steps per second)
    if (elapsedSeconds > 0) {
      final cadence = stepsIncrement / elapsedSeconds;
      if (cadence > maxCadenceStepsPerSecond) {
        if (kDebugMode) {
          debugPrint('[AntiCheat] Unrealistic step cadence: ${cadence.toStringAsFixed(1)} steps/s. Clamped.');
        }
        final cappedSteps = (maxCadenceStepsPerSecond * elapsedSeconds).toInt();
        return StepValidationResult(
          isValid: false,
          validSteps: cappedSteps,
          warningMessage: 'Irregular step rhythm detected. Steps normalized.',
        );
      }
    }

    return StepValidationResult(
      isValid: true,
      validSteps: stepsIncrement,
    );
  }

  /// Validates GPS coordinates against mock location providers and accuracy
  static LocationValidationResult validateLocation({
    required bool isMocked,
    required double accuracyMeters,
    double? speedKmh,
  }) {
    if (isMocked) {
      return const LocationValidationResult(
        isValid: false,
        reason: 'Mock / Fake GPS location detected. Please disable developer spoofing to check in.',
      );
    }

    if (accuracyMeters > maxAcceptableGpsAccuracyMeters) {
      return LocationValidationResult(
        isValid: false,
        reason: 'GPS signal too weak (Accuracy: ${accuracyMeters.toStringAsFixed(0)}m). Please move outdoors.',
      );
    }

    if (speedKmh != null && speedKmh > maxHumanSpeedKmh) {
      return const LocationValidationResult(
        isValid: false,
        reason: 'Location moving too fast to be on foot. Please walk to the hotspot.',
      );
    }

    return const LocationValidationResult(isValid: true);
  }

  /// Validates XP against the 500 XP daily fair play allowance
  static XpValidationResult validateDailyXp({
    required int currentDailyXp,
    required int incomingXp,
  }) {
    if (incomingXp <= 0) {
      return const XpValidationResult(allowedXp: 0, isCapped: false);
    }

    final remainingAllowance = (maxDailyXpLimit - currentDailyXp).clamp(0, maxDailyXpLimit);

    if (remainingAllowance <= 0) {
      return const XpValidationResult(
        allowedXp: 0,
        isCapped: true,
        message: 'Daily XP limit of 500 XP reached! You can still work out, but XP will resume tomorrow.',
      );
    }

    if (incomingXp > remainingAllowance) {
      return XpValidationResult(
        allowedXp: remainingAllowance,
        isCapped: true,
        message: 'Partial XP awarded ($remainingAllowance XP) to preserve daily 500 XP fair play limit.',
      );
    }

    return XpValidationResult(
      allowedXp: incomingXp,
      isCapped: false,
    );
  }

  /// Validates clock integrity against backward jumps or date hopping
  static bool isClockTampered({
    required DateTime lastRecordedTime,
    required DateTime currentTime,
  }) {
    // If phone time is earlier than last recorded activity, clock was turned back
    if (currentTime.isBefore(lastRecordedTime.subtract(const Duration(minutes: 5)))) {
      return true;
    }

    // If phone time jumped more than 7 days into future in a single session
    if (currentTime.difference(lastRecordedTime).inDays > 7) {
      return true;
    }

    return false;
  }
}
