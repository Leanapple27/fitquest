import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
// -----------------------------
// PLAYER DATA
// -----------------------------

  int xp = 1820;
  int streak = 12;
// -----------------------------
// QUEST DATA
// -----------------------------

  int completedQuests = 0;
  final Set<String> completedQuestIds = {};
  final Set<String> completedDailyQuestIds = {};
  String dailyQuestDate = '';
  int weeklyFitnessActivities = 0;
bool weeklyFitnessWarriorCompleted = false;
String weeklyChallengeWeek = '';

  bool morningWarriorCompleted = false;
  bool hydrationHeroCompleted = false;
  bool stretchMasterCompleted = false;
// -----------------------------
// COMMUNITY DATA
// -----------------------------

  bool communityChallengeCompleted = false;
// -----------------------------
// QUIZ DATA
// -----------------------------

  bool quizCompleted = false;
// -----------------------------
// REWARDS
// -----------------------------

  final Set<String> unlockedBadges = {};

  final Set<String> unlockedStickers = {
    'speedster',
    'super_star',
    'go_getter',
    'brave',
    'team_player',
    'positive',
    'on_fire',
    'rare',
    'focused',
    'healthy',
    'celebration',
    'runner',
  };
// Genuine starting badges.
  static const List<String> starterBadges = [
    'xp_explorer',
    'house_champion',
  ];
// -----------------------------
// COUNTS
// -----------------------------

  int get badges => unlockedBadges.length;

  int get stickers => unlockedStickers.length;
// -----------------------------
// STORAGE KEYS
// -----------------------------

  static const String _xpKey = 'xp';

  static const String _streakKey = 'streak';

  static const String _completedQuestsKey =
      'completedQuests';
  static const String _completedQuestIdsKey =
      'completedQuestIds';
  static const String _completedDailyQuestIdsKey =
      'completedDailyQuestIds';
  static const String _dailyQuestDateKey =
      'dailyQuestDate';

  static const String _morningWarriorKey =
      'morningWarriorCompleted';

  static const String _hydrationHeroKey =
      'hydrationHeroCompleted';

  static const String _stretchMasterKey =
      'stretchMasterCompleted';

  static const String _communityChallengeKey =
      'communityChallengeCompleted';

  static const String _quizCompletedKey =
      'quizCompleted';

  static const String _stickersKey =
      'unlockedStickers';

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
  }
// -----------------------------
// CONSTRUCTOR
// -----------------------------

  AppState() {
    _loadProgress();
  }
// -----------------------------
// LOAD PROGRESS
// -----------------------------

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Local storage is an offline fallback.
    xp = prefs.getInt(_xpKey) ?? 0;
    streak = prefs.getInt(_streakKey) ?? 0;
    completedQuests = prefs.getInt(_completedQuestsKey) ?? 0;

    final savedCompletedQuestIds =
        prefs.getStringList(_completedQuestIdsKey);
    if (savedCompletedQuestIds != null) {
      completedQuestIds
        ..clear()
        ..addAll(savedCompletedQuestIds);
    }

    final savedDailyQuestIds =
        prefs.getStringList(_completedDailyQuestIdsKey);
    if (savedDailyQuestIds != null) {
      completedDailyQuestIds
        ..clear()
        ..addAll(savedDailyQuestIds);
    }

    dailyQuestDate = prefs.getString(_dailyQuestDateKey) ?? '';

    morningWarriorCompleted =
        prefs.getBool(_morningWarriorKey) ?? false;
    hydrationHeroCompleted =
        prefs.getBool(_hydrationHeroKey) ?? false;
    stretchMasterCompleted =
        prefs.getBool(_stretchMasterKey) ?? false;
    communityChallengeCompleted =
        prefs.getBool(_communityChallengeKey) ?? false;
    quizCompleted =
        prefs.getBool(_quizCompletedKey) ?? false;

    final savedStickers = prefs.getStringList(_stickersKey);
    if (savedStickers != null) {
      unlockedStickers
        ..clear()
        ..addAll(savedStickers);
    }

    // Firebase is the source of truth for signed-in students.
    try {
      final doc = _userDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        final data = snapshot.data();

        if (data != null) {
          final firebaseXp = data['xp'];
          final firebaseStreak = data['streak'];
          final firebaseCompletedQuests =
              data['completedQuests'];
          final firebaseBadges = data['badges'];
          final firebaseCompletedQuestIds = data['completedQuestIds'];
          final firebaseCompletedDailyQuestIds =
              data['completedDailyQuestIds'];
          final firebaseDailyQuestDate = data['dailyQuestDate'];
          final firebaseStickers = data['stickers'];

          if (firebaseXp is num) {
            xp = firebaseXp.toInt();
          }
          if (firebaseStreak is num) {
            streak = firebaseStreak.toInt();
          }
          if (firebaseCompletedQuests is num) {
            completedQuests = firebaseCompletedQuests.toInt();
          }

          if (firebaseCompletedQuestIds is List) {
            completedQuestIds
              ..clear()
              ..addAll(firebaseCompletedQuestIds.whereType<String>());
          }

          if (firebaseBadges is List) {
            unlockedBadges
              ..clear()
              ..addAll(firebaseBadges.whereType<String>());
          }

          if (firebaseCompletedDailyQuestIds is List) {
            completedDailyQuestIds
              ..clear()
              ..addAll(
                firebaseCompletedDailyQuestIds.whereType<String>(),
              );
          }

          if (firebaseDailyQuestDate is String) {
            dailyQuestDate = firebaseDailyQuestDate;
          }

          if (firebaseStickers is List) {
            unlockedStickers
              ..clear()
              ..addAll(firebaseStickers.whereType<String>());
          }

          final morning = data['morningWarriorCompleted'];
          final hydration = data['hydrationHeroCompleted'];
          final stretch = data['stretchMasterCompleted'];
          final community = data['communityChallengeCompleted'];
          final quiz = data['quizCompleted'];

          if (morning is bool) {
            morningWarriorCompleted = morning;
          }
          if (hydration is bool) {
            hydrationHeroCompleted = hydration;
          }
          if (stretch is bool) {
            stretchMasterCompleted = stretch;
          }
          if (community is bool) {
            communityChallengeCompleted = community;
          }
          if (quiz is bool) {
            quizCompleted = quiz;
          }

          // Keep Firestore badges in sync with the rules below.
          _rebuildBadges();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore progress load failed: $e');
      }
    }

    _rebuildBadges();
    await _saveProgress();
    notifyListeners();
  }
// -----------------------------
// REBUILD BADGES
// -----------------------------

  void _rebuildBadges() {
    unlockedBadges.clear();
// Starter badges.
    unlockedBadges.addAll(
      starterBadges,
    );
// 7 day streak.
    if (streak >= 7) {
      unlockedBadges.add(
        'streak_starter',
      );
    }
// 1 completed quest.
    if (completedQuests >= 1) {
      unlockedBadges.add(
        'morning_warrior',
      );
    }
// 3 completed quests.
    if (completedQuests >= 3) {
      unlockedBadges.add(
        'fitness_hero',
      );
    }
// 2000 XP.
    if (xp >= 2000) {
      unlockedBadges.add(
        'xp_master',
      );
    }
// 2500 XP.
    if (xp >= 2500) {
      unlockedBadges.add(
        'xp_champion',
      );
    }
// 15 day streak.
    if (streak >= 15) {
      unlockedBadges.add(
        'streak_master',
      );
    }
// 10 completed quests.
    if (completedQuests >= 10) {
      unlockedBadges.add(
        'sports_star',
      );
    }
  }
// -----------------------------
// SAVE PROGRESS
// -----------------------------

  Future<void> _saveProgress() async {
  final prefs = await SharedPreferences.getInstance();

  // Weekly challenge progress.
  await prefs.setInt(
    'weeklyFitnessActivities',
    weeklyFitnessActivities,
  );

  await prefs.setBool(
    'weeklyFitnessWarriorCompleted',
    weeklyFitnessWarriorCompleted,
  );

  await prefs.setString(
    'weeklyChallengeWeek',
    weeklyChallengeWeek,
  );

  // Keep local storage as an offline fallback.
  await prefs.setInt(_xpKey, xp);
  await prefs.setInt(_streakKey, streak);
  await prefs.setInt(_completedQuestsKey, completedQuests);

  await prefs.setStringList(
    _completedQuestIdsKey,
    completedQuestIds.toList(),
  );

  await prefs.setStringList(
    _completedDailyQuestIdsKey,
    completedDailyQuestIds.toList(),
  );

  await prefs.setString(
    _dailyQuestDateKey,
    dailyQuestDate,
  );

  await prefs.setBool(
    _morningWarriorKey,
    morningWarriorCompleted,
  );

  await prefs.setBool(
    _hydrationHeroKey,
    hydrationHeroCompleted,
  );

  await prefs.setBool(
    _stretchMasterKey,
    stretchMasterCompleted,
  );

  await prefs.setBool(
    _communityChallengeKey,
    communityChallengeCompleted,
  );

  await prefs.setBool(
    _quizCompletedKey,
    quizCompleted,
  );

  await prefs.setStringList(
    _stickersKey,
    unlockedStickers.toList(),
  );

  // Save progress to this student's Firestore document.
  // merge:true preserves name, schoolId, house, and email.
  try {
    final doc = _userDoc;

    if (doc != null) {
      await doc.set(
        {
          'xp': xp,
          'streak': streak,
          'completedQuests': completedQuests,
          'completedQuestIds': completedQuestIds.toList(),
          'completedDailyQuestIds':
              completedDailyQuestIds.toList(),
          'dailyQuestDate': dailyQuestDate,
          'morningWarriorCompleted':
              morningWarriorCompleted,
          'hydrationHeroCompleted':
              hydrationHeroCompleted,
          'stretchMasterCompleted':
              stretchMasterCompleted,
          'communityChallengeCompleted':
              communityChallengeCompleted,
          'quizCompleted': quizCompleted,
          'badges': unlockedBadges.toList(),
          'stickers': unlockedStickers.toList(),
          'weeklyFitnessActivities':
              weeklyFitnessActivities,
          'weeklyFitnessWarriorCompleted':
              weeklyFitnessWarriorCompleted,
          'weeklyChallengeWeek':
              weeklyChallengeWeek,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Firestore progress save failed: $e',
      );
    }
  }
}
   
// -----------------------------
// DAILY QUEST RESET
// -----------------------------

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> ensureDailyQuestDay() async {
    final today = _todayKey();

    if (dailyQuestDate == today) {
      return;
    }

    dailyQuestDate = today;
    completedDailyQuestIds.clear();

    await _saveProgress();
    notifyListeners();
  }

  bool isDailyQuestCompleted(String questId) {
    return completedDailyQuestIds.contains(questId);
  }

// -----------------------------
// QUEST COMPLETION
// -----------------------------

  bool completeQuest({
    required String questId,
    required int rewardXp,
  }) {
    return completeDynamicQuest(
      questId: questId,
      rewardXp: rewardXp,
    );
  }

  bool completeDynamicQuest({
    required String questId,
    required int rewardXp,
  }) {
    if (questId.isEmpty || rewardXp <= 0) {
      return false;
    }

    // Daily quests are repeatable on a new calendar day.
    if (dailyQuestDate != _todayKey()) {
      dailyQuestDate = _todayKey();
      completedDailyQuestIds.clear();
    }

    if (completedDailyQuestIds.contains(questId)) {
      return false;
    }

    completedDailyQuestIds.add(questId);

    // Keep the lifetime quest ID list for overall progress/history.
    completedQuestIds.add(questId);
    xp += rewardXp;
    completedQuests++;
    

    if (questId == 'morning_warrior') {
      morningWarriorCompleted = true;
    } else if (questId == 'hydration_hero') {
      hydrationHeroCompleted = true;
    } else if (questId == 'stretch_master') {
      stretchMasterCompleted = true;
    }

    _checkRewards();
    notifyListeners();
    _saveProgress();

    return true;
  }
     

  bool completeWeeklyFitnessActivity() {
    if (weeklyFitnessWarriorCompleted) {
      return false;
    }

    if (weeklyFitnessActivities >= 5) {
      return false;
    }

    weeklyFitnessActivities++;

    if (weeklyFitnessActivities >= 5) {
      weeklyFitnessWarriorCompleted = true;

      xp += 300;
      completedQuests++;

      _checkRewards();
    }

    notifyListeners();
    _saveProgress();

    return true;
  }

  // -----------------------------
  // COMMUNITY CHALLENGE
  // -----------------------------
// -----------------------------
// COMMUNITY CHALLENGE
// -----------------------------

  bool completeCommunityChallenge() {
// Prevent duplicate +50 XP.
    if (communityChallengeCompleted) {
      return false;
    }

    xp += 50;

    communityChallengeCompleted = true;

    _checkRewards();

    notifyListeners();

    _saveProgress();

    return true;
  }
// -----------------------------
// QUIZ COMPLETION
// -----------------------------

  bool completeQuiz(int rewardXp) {
// Prevent duplicate quiz rewards.
    if (quizCompleted) {
      return false;
    }

    if (rewardXp <= 0) {
      return false;
    }

    xp += rewardXp;

    quizCompleted = true;

    _checkRewards();

    notifyListeners();

    _saveProgress();

    return true;
  }
// -----------------------------
// REWARD SYSTEM
// -----------------------------

  void _checkRewards() {
// Rebuild badges from actual progress.
    _rebuildBadges();
// 1 completed quest.
    if (completedQuests >= 1) {
      unlockedStickers.add(
        'runner',
      );
    }
// 3 completed quests.
    if (completedQuests >= 3) {
      unlockedStickers.add(
        'on_fire',
      );
    }
// 2000 XP.
    if (xp >= 2000) {
      unlockedStickers.add(
        'super_star',
      );
    }
// 2500 XP.
    if (xp >= 2500) {
      unlockedStickers.add(
        'rare',
      );
    }
// 15 day streak.
    if (streak >= 15) {
      unlockedStickers.add(
        'speedster',
      );
    }
// 10 completed quests.
    if (completedQuests >= 10) {
      unlockedStickers.add(
        'go_getter',
      );
    }
  }
// -----------------------------
// ADD XP
// -----------------------------

  void addXp(int amount) {
    if (amount <= 0) {
      return;
    }

    xp += amount;

    _checkRewards();

    notifyListeners();

    _saveProgress();
  }
// -----------------------------
// ADD STICKER
// -----------------------------

  void addSticker(String stickerId) {
    unlockedStickers.add(
      stickerId,
    );

    notifyListeners();

    _saveProgress();
  }
// -----------------------------
// INCREASE STREAK
// -----------------------------

  void increaseStreak() {
    streak++;

    _checkRewards();

    notifyListeners();

    _saveProgress();
  }
// -----------------------------
// RESET PROGRESS
// -----------------------------

  void resetProgress() {
    xp = 0;

    streak = 0;

    completedQuests = 0;
    completedQuestIds.clear();

    morningWarriorCompleted = false;

    hydrationHeroCompleted = false;

    stretchMasterCompleted = false;

    communityChallengeCompleted = false;

    quizCompleted = false;

    unlockedBadges.clear();

    unlockedStickers
      ..clear()
      ..addAll([
        'speedster',
        'super_star',
        'go_getter',
        'brave',
        'team_player',
        'positive',
        'on_fire',
        'rare',
        'focused',
        'healthy',
        'celebration',
        'runner',
      ]);

    _rebuildBadges();

    notifyListeners();

    _saveProgress();
  }
}