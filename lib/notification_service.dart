import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('fitquest/notifications');

  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
  }

  static Future<void> showMotivationNotification() async {
    try {
      await _channel.invokeMethod(
        'showNotification',
        {
          'title': 'Your streak is waiting! 🔥',
          'message':
              'You have not completed your activity yet. '
              '10 minutes is all you need!',
        },
      );
    } catch (e) {
      debugPrint('Motivation notification error: $e');
    }
  }

  static Future<void> showQuestNotification() async {
    try {
      await _channel.invokeMethod(
        'showNotification',
        {
          'title': 'Your quest is waiting! 🎯',
          'message':
              'Complete today\'s challenge and keep your progress going.',
        },
      );
    } catch (e) {
      debugPrint('Quest notification error: $e');
    }
  }

  static Future<void> showStepNotification() async {
    try {
      await _channel.invokeMethod(
        'showNotification',
        {
          'title': 'Keep moving! 👟',
          'message':
              'A few more steps today can make a big difference.',
        },
      );
    } catch (e) {
      debugPrint('Step notification error: $e');
    }
  }

  static Future<void> showStreakNotification() async {
    try {
      await _channel.invokeMethod(
        'showNotification',
        {
          'title': 'Protect your streak! 🔥',
          'message':
              'Your FitQuest streak is waiting for you today.',
        },
      );
    } catch (e) {
      debugPrint('Streak notification error: $e');
    }
  }
}