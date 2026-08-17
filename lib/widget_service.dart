import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'app_state.dart';

class WidgetService {
  static const String _androidWidgetName = 'FitQuestWidgetProvider';

  static const List<Map<String, dynamic>> defaultDailyQuests = [
    {
      'id': 'morning_warrior',
      'title': 'Morning Warrior',
      'icon': '🏃',
      'description': '20m physical activity • +100 XP',
    },
    {
      'id': 'hydration_hero',
      'title': 'Hydration Hero',
      'icon': '💧',
      'description': 'Drink 8 glasses of water • +50 XP',
    },
    {
      'id': 'stretch_master',
      'title': 'Stretch Master',
      'icon': '🧘',
      'description': '10m full-body mobility • +75 XP',
    },
    {
      'id': 'step_explorer',
      'title': 'Step Explorer',
      'icon': '👟',
      'description': 'Reach 5,000 steps today • +80 XP',
    },
    {
      'id': 'campus_hotspot',
      'title': 'Campus Trekker',
      'icon': '🌳',
      'description': 'Check in at FitMap spot • +60 XP',
    },
  ];

  /// Syncs AppState data directly to Android Home Screen Widget
  static Future<void> syncWidget(AppState appState) async {
    try {
      final streak = appState.streak;
      final xp = appState.xp;
      final level = appState.currentLevel;

      // Calculate completed daily quests
      final completedDailyIds = appState.completedDailyQuestIds;
      final completedCount = completedDailyIds.length;
      final totalCount = defaultDailyQuests.length;

      // Find first incomplete daily quest
      Map<String, dynamic>? nextIncompleteQuest;
      for (final quest in defaultDailyQuests) {
        if (!completedDailyIds.contains(quest['id'])) {
          nextIncompleteQuest = quest;
          break;
        }
      }

      String nextTitle = '⚡ Daily Quests';
      String nextSubtitle = 'Keep moving to earn XP!';

      if (nextIncompleteQuest != null) {
        nextTitle = '${nextIncompleteQuest['icon']} ${nextIncompleteQuest['title']}';
        nextSubtitle = nextIncompleteQuest['description'] as String;
      } else if (completedCount >= totalCount) {
        nextTitle = '🎉 All Daily Quests Complete!';
        nextSubtitle = 'Great job! Streak maintained 🔥';
      }

      await HomeWidget.saveWidgetData<int>('streak', streak);
      await HomeWidget.saveWidgetData<int>('xp', xp);
      await HomeWidget.saveWidgetData<int>('level', level);
      await HomeWidget.saveWidgetData<int>('completed_quests', completedCount);
      await HomeWidget.saveWidgetData<int>('total_quests', totalCount);
      await HomeWidget.saveWidgetData<String>('next_quest_title', nextTitle);
      await HomeWidget.saveWidgetData<String>('next_quest_subtitle', nextSubtitle);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync FitQuest home widget: $e');
      }
    }
  }
}
