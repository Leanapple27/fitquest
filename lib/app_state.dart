import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/anti_cheat_service.dart';
import 'widget_service.dart';

class AppState extends ChangeNotifier {
// -----------------------------
// PLAYER DATA
// -----------------------------

  int xp = 1820;
  int streak = 12;
  int dailyEarnedXp = 0;
  bool isFairPlayVerified = true;
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

// -----------------------------
// SHOP & PET COMPANION DATA
// -----------------------------
  int fitCoins = 180;
  final Set<String> unlockedPets = {'baby_dragon'};
  String activePet = 'baby_dragon';
  int petLevel = 1;
  int petHunger = 80;
  final Set<String> unlockedFrames = {'neon_cyber'};
  String activeFrame = 'neon_cyber';
  final List<String> customStickers = [];

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
  int get currentLevel => (xp ~/ 250).clamp(1, 15);

  int get weeklyGoalProgress =>
      weeklyFitnessActivities.clamp(0, 5);

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

  // Local progress is isolated per Firebase account.
  // This prevents one student on the same device from seeing another
  // student's XP, quests, badges, stickers, or weekly progress.
  String get _localStoragePrefix {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return 'fitquest_${uid ?? 'signed_out'}';
  }

  String _localKey(String key) {
    return '${_localStoragePrefix}_$key';
  }
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
    // AppState is created after authentication in StudentHomeScreen, so
    // local progress is loaded using the signed-in student's UID.
    _loadProgress();
  }
// -----------------------------
// LOAD PROGRESS
// -----------------------------

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Local storage is an offline fallback.
    xp = prefs.getInt(_localKey(_xpKey)) ?? 0;
    streak = prefs.getInt(_localKey(_streakKey)) ?? 0;
    completedQuests = prefs.getInt(_localKey(_completedQuestsKey)) ?? 0;

    final savedCompletedQuestIds =
        prefs.getStringList(_localKey(_completedQuestIdsKey));
    if (savedCompletedQuestIds != null) {
      completedQuestIds
        ..clear()
        ..addAll(savedCompletedQuestIds);
    }

    final savedDailyQuestIds =
        prefs.getStringList(_localKey(_completedDailyQuestIdsKey));
    if (savedDailyQuestIds != null) {
      completedDailyQuestIds
        ..clear()
        ..addAll(savedDailyQuestIds);
    }

    dailyQuestDate = prefs.getString(_localKey(_dailyQuestDateKey)) ?? '';
    dailyEarnedXp = prefs.getInt(_localKey('dailyEarnedXp')) ?? 0;
    isFairPlayVerified = prefs.getBool(_localKey('isFairPlayVerified')) ?? true;
    weeklyFitnessActivities =
    prefs.getInt(_localKey('weeklyFitnessActivities')) ?? 0;

weeklyFitnessWarriorCompleted =
    prefs.getBool(_localKey('weeklyFitnessWarriorCompleted')) ?? false;

weeklyChallengeWeek =
    prefs.getString(_localKey('weeklyChallengeWeek')) ?? '';

    morningWarriorCompleted =
        prefs.getBool(_localKey(_morningWarriorKey)) ?? false;
    hydrationHeroCompleted =
        prefs.getBool(_localKey(_hydrationHeroKey)) ?? false;
    stretchMasterCompleted =
        prefs.getBool(_localKey(_stretchMasterKey)) ?? false;
    communityChallengeCompleted =
        prefs.getBool(_localKey(_communityChallengeKey)) ?? false;
    quizCompleted =
        prefs.getBool(_localKey(_quizCompletedKey)) ?? false;

    final savedStickers = prefs.getStringList(_localKey(_stickersKey));
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
          final firebaseWeeklyFitnessActivities =
              data['weeklyFitnessActivities'];
          final firebaseWeeklyFitnessWarriorCompleted =
              data['weeklyFitnessWarriorCompleted'];
          final firebaseWeeklyChallengeWeek =
              data['weeklyChallengeWeek'];

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

          if (firebaseWeeklyFitnessActivities is num) {
            weeklyFitnessActivities =
                firebaseWeeklyFitnessActivities.toInt();
          }
          if (firebaseWeeklyFitnessWarriorCompleted is bool) {
            weeklyFitnessWarriorCompleted =
                firebaseWeeklyFitnessWarriorCompleted;
          }
          if (firebaseWeeklyChallengeWeek is String) {
            weeklyChallengeWeek = firebaseWeeklyChallengeWeek;
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

    _ensureWeeklyChallengeWeekSync();
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
  
    // Weekly fitness warrior.
    if (weeklyFitnessWarriorCompleted) {
      unlockedBadges.add('weekly_warrior');
    }

    // Quiz master.
    if (quizCompleted) {
      unlockedBadges.add('quiz_master');
    }

    // Community hero.
    if (communityChallengeCompleted) {
      unlockedBadges.add('community_hero');
    }

    // Level 5.
    if (currentLevel >= 5) {
      unlockedBadges.add('level_5');
    }

    // Level 10.
    if (currentLevel >= 10) {
      unlockedBadges.add('level_10');
    }

    // 30 day streak.
    if (streak >= 30) {
      unlockedBadges.add('streak_legend');
    }
}
// -----------------------------
// SAVE PROGRESS
// -----------------------------

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

  // Weekly challenge progress.
  await prefs.setInt(
    _localKey('weeklyFitnessActivities'),
    weeklyFitnessActivities,
  );

  await prefs.setBool(
    _localKey('weeklyFitnessWarriorCompleted'),
    weeklyFitnessWarriorCompleted,
  );

  await prefs.setString(
    _localKey('weeklyChallengeWeek'),
    weeklyChallengeWeek,
  );

  // Keep local storage as an offline fallback.
  await prefs.setInt(_localKey(_xpKey), xp);
  await prefs.setInt(_localKey(_streakKey), streak);
  await prefs.setInt(_localKey(_completedQuestsKey), completedQuests);

  await prefs.setStringList(
    _localKey(_completedQuestIdsKey),
    completedQuestIds.toList(),
  );

  await prefs.setStringList(
    _localKey(_completedDailyQuestIdsKey),
    completedDailyQuestIds.toList(),
  );

  await prefs.setString(
    _localKey(_dailyQuestDateKey),
    dailyQuestDate,
  );

  await prefs.setInt(
    _localKey('dailyEarnedXp'),
    dailyEarnedXp,
  );

  await prefs.setBool(
    _localKey('isFairPlayVerified'),
    isFairPlayVerified,
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
  // merge\:true preserves name, schoolId, house, and email.
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

  // Update Android Home Screen Widget
  WidgetService.syncWidget(this);
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

  String _weekKey() {
    final now = DateTime.now();
    final monday = now.subtract(
      Duration(days: now.weekday - 1),
    );
    final month = monday.month.toString().padLeft(2, '0');
    final day = monday.day.toString().padLeft(2, '0');
    return '${monday.year}-$month-$day';
  }

  void _ensureWeeklyChallengeWeekSync() {
    final currentWeek = _weekKey();

    if (weeklyChallengeWeek == currentWeek) {
      return;
    }

    weeklyChallengeWeek = currentWeek;
    weeklyFitnessActivities = 0;
    weeklyFitnessWarriorCompleted = false;
  }

  Future<void> ensureWeeklyChallengeWeek() async {
    final before = weeklyChallengeWeek;
    _ensureWeeklyChallengeWeekSync();

    if (before == weeklyChallengeWeek) {
      return;
    }

    await _saveProgress();
    notifyListeners();
  }

  Future<void> ensureDailyQuestDay() async {
    final today = _todayKey();

    if (dailyQuestDate == today) {
      return;
    }

    dailyQuestDate = today;
    dailyEarnedXp = 0;
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
      dailyEarnedXp = 0;
      completedDailyQuestIds.clear();
    }

    if (completedDailyQuestIds.contains(questId)) {
      return false;
    }

    // Apply AntiCheat daily XP cap (500 XP maximum per day)
    final xpValidation = AntiCheatService.validateDailyXp(
      currentDailyXp: dailyEarnedXp,
      incomingXp: rewardXp,
    );

    final awardedXp = xpValidation.allowedXp;

    completedDailyQuestIds.add(questId);
    completedQuestIds.add(questId);
    xp += awardedXp;
    dailyEarnedXp += awardedXp;
    completedQuests++;

    // Count every successfully completed dynamic/daily quest toward the
    // current weekly fitness challenge. The weekly challenge itself is not
    // a dynamic quest, so it cannot accidentally count itself.
    _ensureWeeklyChallengeWeekSync();
    _incrementWeeklyFitnessActivity();

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

  void _incrementWeeklyFitnessActivity() {
    if (weeklyFitnessWarriorCompleted) {
      return;
    }

    if (weeklyFitnessActivities >= 5) {
      return;
    }

    weeklyFitnessActivities++;

    if (weeklyFitnessActivities >= 5) {
      weeklyFitnessActivities = 5;
      weeklyFitnessWarriorCompleted = true;

      xp += 300;
      completedQuests++;

      _checkRewards();
    }
  }

  bool completeWeeklyFitnessActivity() {
    _ensureWeeklyChallengeWeekSync();

    final before = weeklyFitnessActivities;
    final wasCompleted = weeklyFitnessWarriorCompleted;

    _incrementWeeklyFitnessActivity();

    if (before == weeklyFitnessActivities &&
        wasCompleted == weeklyFitnessWarriorCompleted) {
      return false;
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
    completedDailyQuestIds.clear();
    dailyQuestDate = '';

    weeklyFitnessActivities = 0;
    weeklyFitnessWarriorCompleted = false;
    weeklyChallengeWeek = _weekKey();

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

    notifyListeners();

    _saveProgress();
  }

  // -----------------------------
  // SHOP & MARKETPLACE METHODS
  // -----------------------------

  bool convertXpToCoins(int xpToConvert) {
    if (xpToConvert <= 0 || xp < xpToConvert) return false;
    final coinsGained = (xpToConvert / 10).floor();
    xp -= xpToConvert;
    fitCoins += coinsGained;
    _saveProgress();
    notifyListeners();
    return true;
  }

  bool buyShopItem(String itemId, int price, String category) {
    if (fitCoins < price) return false;
    fitCoins -= price;
    if (category == 'pet') {
      unlockedPets.add(itemId);
      activePet = itemId;
    } else if (category == 'frame') {
      unlockedFrames.add(itemId);
      activeFrame = itemId;
    } else if (category == 'sticker') {
      unlockedStickers.add(itemId);
    } else if (category == 'food') {
      petHunger = (petHunger + 35).clamp(0, 100);
      petLevel += 1;
    }
    _saveProgress();
    notifyListeners();
    return true;
  }

  void equipPet(String petId) {
    if (unlockedPets.contains(petId)) {
      activePet = petId;
      _saveProgress();
      notifyListeners();
    }
  }

  void equipFrame(String frameId) {
    if (unlockedFrames.contains(frameId)) {
      activeFrame = frameId;
      _saveProgress();
      notifyListeners();
    }
  }

  void addCustomSticker(String stickerName) {
    customStickers.add(stickerName);
    unlockedStickers.add(stickerName);
    _saveProgress();
    notifyListeners();
  }
}