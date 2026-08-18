import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/fq_audio_service.dart';
import '../theme/fq_animations.dart';
import '../theme/fq_colors.dart';
import '../theme/fq_typography.dart';
import 'ai_vision_workout_screen.dart';
import 'duels_screen.dart';
import 'workout_screen.dart';

class QuestsScreen extends StatefulWidget {
  final AppState appState;

  const QuestsScreen({
    super.key,
    required this.appState,
  });

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final Map<String, double> _progress = {};

  List<Map<String, dynamic>> _dailyQuests = [];
  List<Map<String, dynamic>> _weeklyQuests = [];

  bool _loading = true;
  String? _error;
  int _activeFilter = 0; // 0: All, 1: Daily, 2: Weekly, 3: Workouts
  bool _showAllDailyQuests = false;

  static const List<Map<String, dynamic>> _defaultDailyQuests = [
    {
      'id': 'morning_warrior',
      'title': 'Morning Campus Stride',
      'description': 'Walk 1,500 steps briskly before the morning school bell rings.',
      'icon': '🚶',
      'category': 'CARDIO',
      'xp': 60,
    },
    {
      'id': 'hydration_hero',
      'title': 'Hydro Charge Champion',
      'description': 'Drink 8 glasses of water (2.0 Litres) across your classes today.',
      'icon': '💧',
      'category': 'HYDRATION',
      'xp': 50,
    },
    {
      'id': 'stair_climber',
      'title': 'Stair Climber Hero',
      'description': 'Climb 4 flights of stairs instead of taking an elevator or ramp.',
      'icon': '🪜',
      'category': 'AGILITY',
      'xp': 50,
    },
    {
      'id': 'recess_dash',
      'title': 'Recess 100m Dash',
      'description': 'Sprint 100m across the sports ground with high energy.',
      'icon': '⚡',
      'category': 'SPEED',
      'xp': 75,
    },
    {
      'id': 'stretch_master',
      'title': 'Stretch & Mobility Master',
      'description': 'Complete 10 minutes of hamstring, shoulder & back stretching.',
      'icon': '🧘',
      'category': 'FLEXIBILITY',
      'xp': 75,
    },
    {
      'id': 'desk_neck_relief',
      'title': 'Desk Neck & Posture Relief',
      'description': '5 slow cervical chin-tucks and 10 shoulder rolls after study hours.',
      'icon': '💆',
      'category': 'POSTURE',
      'xp': 40,
    },
    {
      'id': 'ball_play',
      'title': 'Playground Ball Play',
      'description': '10 minutes of football dribbles, basketball shots, or catch play.',
      'icon': '🏀',
      'category': 'SPORTS',
      'xp': 80,
    },
    {
      'id': 'backpack_posture',
      'title': 'Backpack Posture Stride',
      'description': 'Walk with chest tall, shoulders relaxed & core engaged for 10 mins.',
      'icon': '🎒',
      'category': 'POSTURE',
      'xp': 45,
    },
    {
      'id': 'high_knee_power',
      'title': 'High-Knee Power March',
      'description': 'Complete 30 dynamic high-knee lifts on the spot during recess.',
      'icon': '🔥',
      'category': 'POWER',
      'xp': 60,
    },
    {
      'id': 'step_explorer',
      'title': 'Step Explorer 5,000',
      'description': 'Reach 5,000 total steps across your school campus today.',
      'icon': '👟',
      'category': 'STEPS',
      'xp': 80,
    },
    {
      'id': 'park_walk',
      'title': 'Fresh Air Outdoor Walk',
      'description': 'Enjoy a 15-minute nature walk in the campus courtyard or park.',
      'icon': '🌳',
      'category': 'ADVENTURE',
      'xp': 50,
    },
    {
      'id': 'sleep_champion',
      'title': 'Sleep Recovery Champion',
      'description': 'Log 8 hours of restful, uninterrupted sleep for brain recovery.',
      'icon': '🛌',
      'category': 'RECOVERY',
      'xp': 50,
    },
    {
      'id': 'squat_charge',
      'title': 'Study Break Squat Charge',
      'description': 'Perform 15 clean bodyweight squats during a 5-min study break.',
      'icon': '🏋️',
      'category': 'STRENGTH',
      'xp': 70,
    },
    {
      'id': 'plank_hero',
      'title': 'Core Armor Plank Hold',
      'description': 'Hold a solid, steady 45-second straight-arm or elbow plank.',
      'icon': '🛡️',
      'category': 'CORE',
      'xp': 65,
    },
  ];

  static const List<Map<String, dynamic>> _defaultWeeklyQuests = [
    {
      'id': 'weekly_fitness_warrior',
      'title': 'Weekly Fitness Warriors Boss Raid',
      'description': 'Complete 5 verified fitness sessions or sports matches this week.',
      'icon': '🏆',
      'category': 'MILESTONE',
      'xp': 300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      await widget.appState.ensureDailyQuestDay();

      final snapshot = await FirebaseFirestore.instance
          .collection('quests')
          .get(const GetOptions(source: Source.server));

      final firestoreDaily = <Map<String, dynamic>>[];
      final firestoreWeekly = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['active'] == true) {
          final type = data['type']?.toString().toLowerCase();
          final questMap = {
            'id': doc.id,
            'title': data['title']?.toString() ?? 'Quest',
            'description': data['description']?.toString() ?? '',
            'icon': data['icon']?.toString() ?? '🎯',
            'xp': (data['xp'] is num) ? (data['xp'] as num).toInt() : 50,
            'category': data['category']?.toString() ?? 'FITNESS',
          };

          if (type == 'daily') {
            firestoreDaily.add(questMap);
          } else if (type == 'weekly') {
            firestoreWeekly.add(questMap);
          }
        }
      }

      // Merge Firestore quests with built-in default quests so Hydration Hero & Stretch Master are ALWAYS present
      final mergedDaily = <Map<String, dynamic>>[...firestoreDaily];
      for (final defaultQ in _defaultDailyQuests) {
        final alreadyExists = mergedDaily.any(
          (q) =>
              q['id'] == defaultQ['id'] ||
              q['title'].toString().toLowerCase() ==
                  defaultQ['title'].toString().toLowerCase(),
        );
        if (!alreadyExists) {
          mergedDaily.add(defaultQ);
        }
      }

      final mergedWeekly = <Map<String, dynamic>>[...firestoreWeekly];
      for (final defaultW in _defaultWeeklyQuests) {
        final alreadyExists = mergedWeekly.any(
          (q) =>
              q['id'] == defaultW['id'] ||
              q['title'].toString().toLowerCase() ==
                  defaultW['title'].toString().toLowerCase(),
        );
        if (!alreadyExists) {
          mergedWeekly.add(defaultW);
        }
      }

      for (final q in mergedDaily) {
        final qId = q['id'] as String;
        _progress[qId] = widget.appState.isDailyQuestCompleted(qId) ? 1.0 : 0.0;
      }

      if (!mounted) return;

      setState(() {
        _dailyQuests = mergedDaily;
        _weeklyQuests = mergedWeekly;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      // Offline fallback: load built-in default quests
      if (!mounted) return;

      for (final q in _defaultDailyQuests) {
        final qId = q['id'] as String;
        _progress[qId] = widget.appState.isDailyQuestCompleted(qId) ? 1.0 : 0.0;
      }

      setState(() {
        _dailyQuests = [..._defaultDailyQuests];
        _weeklyQuests = [..._defaultWeeklyQuests];
        _loading = false;
        _error = null;
      });
    }
  }

  bool _isCompleted(String id) {
    return widget.appState.isDailyQuestCompleted(id);
  }

  void _startQuest(String id) {
    setState(() {
      if ((_progress[id] ?? 0) == 0) {
        _progress[id] = 0.25;
      }
    });
  }

  void _continueQuest(String id) {
    setState(() {
      final next = (_progress[id] ?? 0) + 0.35;
      _progress[id] = next > 1 ? 1 : next;
    });
  }

  void _completeQuest(String id, int xp) {
    if (_isCompleted(id)) return;

    FQAudioService().playXpGain();

    final awarded = widget.appState.completeDynamicQuest(
      questId: id,
      rewardXp: xp,
    );

    if (!awarded) return;

    setState(() {
      _progress[id] = 1.0;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: FqColors.ink,
          content: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.appState.weeklyFitnessWarriorCompleted
                      ? '+$xp XP earned! Weekly Warrior completed (+300 XP)! 🏆'
                      : '+$xp XP added to your total energy! ⚡',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _openWorkoutCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          appState: widget.appState,
        ),
      ),
    );
  }

  void _open1v1Duels() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuelsScreen(
          appState: widget.appState,
        ),
      ),
    );
  }

  void _openAiVisionWorkout({
    required String questId,
    required String title,
    required int xp,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiVisionWorkoutScreen(
          appState: widget.appState,
          questId: questId,
          exerciseName: title.contains('Warrior') ? 'Squats' : 'Workout Reps',
          targetReps: 12,
          rewardXp: xp,
        ),
      ),
    ).then((_) => _loadQuests());
  }

  bool _supportsAiVision({required String questId, required String category}) {
    final cat = category.toUpperCase();
    final id = questId.toLowerCase();
    if (id.contains('hydration') ||
        id.contains('water') ||
        id.contains('step') ||
        id.contains('campus') ||
        id.contains('hotspot') ||
        id.contains('desk') ||
        id.contains('sleep') ||
        id.contains('backpack') ||
        id.contains('stair') ||
        id.contains('park')) {
      return false;
    }
    return cat == 'CARDIO' ||
        cat == 'WORKOUT' ||
        cat == 'FLEXIBILITY' ||
        cat == 'FITNESS' ||
        cat == 'STRENGTH' ||
        cat == 'CORE' ||
        id.contains('workout') ||
        id.contains('warrior') ||
        id.contains('squat') ||
        id.contains('pushup') ||
        id.contains('plank') ||
        id.contains('stretch');
  }

  @override
  Widget build(BuildContext context) {
    final completed = _dailyQuests.where((q) => _isCompleted(q['id'] as String)).length;
    final total = _dailyQuests.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: FqColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🎯', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 9),
            Text(
              'Daily Quests',
              style: FqTypography.screenTitle(color: FqColors.ink).copyWith(
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Weekend Warriors Top Notification Pill
          InkWell(
            onTap: _showWeekendWarriorsDialog,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔔', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 4),
                  Text(
                    '2x Weekend XP',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _loadQuests,
            icon: const Icon(Icons.refresh_rounded, color: FqColors.ink),
            tooltip: 'Refresh Quests',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuests,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            // 1. Daily Progress Hero
            _buildProgressCard(
              progress: progress,
              completedCount: completed,
              totalQuests: total,
              xp: widget.appState.xp,
            ),
            const SizedBox(height: 14),

            // Quick Launcher Bar: 1v1 Battle Arena & Workout Center
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _open1v1Duels,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF302B63), Color(0xFF24243E)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF302B63).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('⚔️', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1V1 DUELS',
                                  style: TextStyle(
                                    color: Color(0xFF00F5D4),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Battle Arena',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _openWorkoutCenter,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('🏋️', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WORKOUTS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Center Hub',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Segment Filter Chips
            _buildFilterPills(),
            const SizedBox(height: 16),

            // 3. Quests Content
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _messageCard(_error!, 'TRY AGAIN', _loadQuests)
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_activeFilter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_activeFilter == 0 || _activeFilter == 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S DAILY QUESTS",
                              style: FqTypography.sectionLabel(color: FqColors.muted),
                            ),
                            Text(
                              '$completed of $total Complete',
                              style: const TextStyle(
                                color: FqColors.primaryMid,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...(_showAllDailyQuests ? _dailyQuests : _dailyQuests.take(5))
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final q = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FQFadeSlide(
                              index: i,
                              child: FQBounce(
                                child: _questCard(
                                  questId: q['id'] as String,
                                  emoji: q['icon'] as String,
                                  title: q['title'] as String,
                                  description: q['description'] as String,
                                  category: q['category'] as String? ?? 'FITNESS',
                                  xp: q['xp'] as int,
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_dailyQuests.length > 5) ...[
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _showAllDailyQuests = !_showAllDailyQuests),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF302B63),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              icon: Icon(_showAllDailyQuests ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18),
                              label: Text(
                                _showAllDailyQuests
                                    ? 'SHOW LESS (5 QUESTS)'
                                    : 'SHOW ALL ${_dailyQuests.length} QUESTS (+${_dailyQuests.length - 5} MORE)',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 16),
                      ],

                      if (_activeFilter == 0 || _activeFilter == 2) ...[
                        Text(
                          'WEEKLY FITNESS WARRIOR RAID',
                          style: FqTypography.sectionLabel(color: FqColors.muted),
                        ),
                        const SizedBox(height: 10),
                        ..._weeklyQuests.map((w) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _weeklyQuestPreviewCard(
                              questId: w['id'] as String,
                              emoji: w['icon'] as String,
                              title: w['title'] as String,
                              description: w['description'] as String,
                              xp: w['xp'] as int,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      if (_activeFilter == 0 || _activeFilter == 3) ...[
                        _buildWorkoutCenterCard(),
                        const SizedBox(height: 16),
                        _bonusQuestCard(),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROGRESS HERO CARD
  // ---------------------------------------------------------------------------

  Widget _buildProgressCard({
    required double progress,
    required int completedCount,
    required int totalQuests,
    required int xp,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF51489A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF302B63).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: FqColors.accent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'DAILY QUEST BOARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FqColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).round()}% COMPLETE',
                  style: const TextStyle(
                    color: FqColors.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount of $totalQuests Quests',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress >= 1.0
                          ? 'All quests completed! Great hustle today! 🎉'
                          : 'Complete all daily quests to boost clan standing.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: FqColors.energy, size: 16),
                    const SizedBox(width: 4),
                    FQXpCounter(
                      targetValue: xp,
                      suffix: ' XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    FqColors.accent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER PILLS
  // ---------------------------------------------------------------------------

  Widget _buildFilterPills() {
    final filters = [
      {'label': 'All Quests', 'icon': Icons.grid_view_rounded},
      {'label': 'Daily Focus', 'icon': Icons.today_rounded},
      {'label': 'Weekly Warrior', 'icon': Icons.military_tech_rounded},
      {'label': 'Workouts', 'icon': Icons.fitness_center_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _activeFilter == index;
          final item = filters[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeFilter = index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? FqColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? FqColors.primary : const Color(0xFFE7E8EE),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: FqColors.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFF747887),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF555A72),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QUEST CARD (Interactive Start -> Continue -> Complete)
  // ---------------------------------------------------------------------------

  Widget _questCard({
    required String questId,
    required String emoji,
    required String title,
    required String description,
    required String category,
    required int xp,
  }) {
    final completed = _isCompleted(questId);
    final current = _progress[questId] ?? 0;
    final started = current > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? FqColors.success.withValues(alpha: 0.3)
              : const Color(0xFFE7E8EE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji Squircle Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? FqColors.successSurface
                      : FqColors.lavender,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _AnimatedQuestEmoji(
                    emoji: completed ? '✅' : emoji,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: FqColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: Color(0xFF747887),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // XP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: FqColors.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: FqColors.energy, size: 14),
                    Text(
                      '+$xp XP',
                      style: const TextStyle(
                        color: FqColors.energy,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // In-Progress Indicator
          if (started && !completed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: current,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEEF2F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        FqColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(current * 100).round()}%',
                  style: const TextStyle(
                    color: FqColors.primaryMid,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Action Button & AI Camera Button
          if (!completed) ...[
            if (_supportsAiVision(questId: questId, category: category))
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!started) {
                          _startQuest(questId);
                        } else if (current < 1) {
                          _continueQuest(questId);
                        } else {
                          _completeQuest(questId, xp);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: current >= 1.0
                            ? FqColors.energy
                            : FqColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            current >= 1.0
                                ? Icons.card_giftcard_rounded
                                : started
                                    ? Icons.play_arrow_rounded
                                    : Icons.flag_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !started
                                ? 'START'
                                : current < 1
                                    ? 'PROGRESS'
                                    : 'CLAIM +$xp XP',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _openAiVisionWorkout(
                      questId: questId,
                      title: title,
                      xp: xp,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF151B3D),
                      foregroundColor: const Color(0xFF00F5D4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, size: 15, color: Color(0xFF00F5D4)),
                        SizedBox(width: 5),
                        Text(
                          'AI VISION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    if (!started) {
                      _startQuest(questId);
                    } else if (current < 1) {
                      _continueQuest(questId);
                    } else {
                      _completeQuest(questId, xp);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current >= 1.0
                        ? FqColors.energy
                        : FqColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        current >= 1.0
                            ? Icons.card_giftcard_rounded
                            : started
                                ? Icons.play_arrow_rounded
                                : Icons.flag_rounded,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        !started
                            ? 'START QUEST'
                            : current < 1
                                ? (questId == 'hydration_hero'
                                    ? 'DRINK +1 GLASS 💧'
                                    : 'CONTINUE QUEST')
                                : 'CLAIM +$xp XP REWARD',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                color: FqColors.successSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: FqColors.success, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'QUEST COMPLETED ✓',
                      style: TextStyle(
                        color: FqColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WEEKLY CHALLENGE CARD
  // ---------------------------------------------------------------------------

  Widget _weeklyQuestPreviewCard({
    required String questId,
    required String emoji,
    required String title,
    required String description,
    required int xp,
  }) {
    final progress = widget.appState.weeklyFitnessActivities;
    final completed = widget.appState.weeklyFitnessWarriorCompleted;
    final ratio = (progress.clamp(0, 10) / 10).toDouble();

    return InkWell(
      onTap: _showWeeklyWarriorsBossRaidDialog,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: completed
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Emblem + Title + XP Badge
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Center(
                    child: _AnimatedQuestEmoji(emoji: emoji),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'WEEKLY RAID',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB45309),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Ends Sun 11:59 PM',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF302B63),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$xp XP',
                    style: const TextStyle(
                      color: Color(0xFF00F5D4),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Description
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Progress Bar & Requirements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  completed ? '10 / 10 Activities Completed ✓' : '$progress / 10 Fitness Activities Done',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: completed ? const Color(0xFF10B981) : const Color(0xFF151B3D),
                  ),
                ),
                Text(
                  '${(ratio * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF302B63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: const Color(0xFFEEF2F6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Reward Showcase Pill & Tap Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Text('🏷️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reward: Exclusive Raid Champion Animated Sticker',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOSS RAID STATS MODAL
  // ---------------------------------------------------------------------------

  void _showWeeklyWarriorsBossRaidDialog() {
    final activities = widget.appState.weeklyFitnessActivities;
    final completed = widget.appState.weeklyFitnessWarriorCompleted;
    const totalStepsTarget = 100000;
    const currentCampusSteps = 84200;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY FITNESS RAID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: FqColors.energy,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Weekly Fitness Warrior',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF302B63),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '+300 XP',
                    style: TextStyle(
                      color: Color(0xFF00F5D4),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Global Campus Raid Progress
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CAMPUS RAID: POOLED STEPS & XP',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '$currentCampusSteps / $totalStepsTarget Steps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF302B63),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: currentCampusSteps / totalStepsTarget,
                      minHeight: 8,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Student Contribution Stats
            const Text(
              'YOUR CONTRIBUTION & MISSIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _raidMissionItem('🏋️ 10 Fitness Activities', '$activities / 10 Done', activities >= 10),
            _raidMissionItem('💧 7-Day Hydration Week', '5 / 7 Days Done', false),
            _raidMissionItem('⚡ Campus Raid Contribution', '+450 XP Pooled', true),

            const SizedBox(height: 14),

            // Exclusive Sticker Reward Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Center(
                      child: Text('🏷️', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXCLUSIVE REWARD: RAID CHAMPION STICKER',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Complete all 3 missions before Sunday midnight to unlock this exclusive animated sticker!',
                          style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF302B63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  completed ? 'CLAIMED ✓' : 'GOT IT, LET\'S RAID! 🔥',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _raidMissionItem(String title, String progress, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDone ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          Text(progress, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDone ? const Color(0xFF16A34A) : const Color(0xFF64748B))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WEEKEND WARRIOR NOTIFICATION DIALOG
  // ---------------------------------------------------------------------------

  void _showWeekendWarriorsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Text('🔔', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'Weekend 2x XP Active!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Every verified workout, quest, and community match completed this weekend earns DOUBLE XP (+250 XP bonus)!',
              style: TextStyle(fontSize: 13, color: Color(0xFF555A72), height: 1.35),
            ),
            SizedBox(height: 12),
            Text(
              '⚡ 2x XP Multiplier\n🏆 Community Tournament Leaderboard Boost\n🪙 2x FitCoins Conversion',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF302B63)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('GOT IT! 🔥', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WORKOUT CENTER SHORTCUT CARD
  // ---------------------------------------------------------------------------

  Widget _buildWorkoutCenterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF302B63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🏋️', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKOUT HUB',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Turn Quests Into Action 💪',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Timed workouts • HIIT • Yoga • Gym Routines with XP multipliers.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _openWorkoutCenter,
              style: ElevatedButton.styleFrom(
                backgroundColor: FqColors.accent,
                foregroundColor: const Color(0xFF151B3D),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_circle_filled_rounded, size: 18),
              label: const Text(
                'EXPLORE WORKOUTS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BONUS QUEST CARD
  // ---------------------------------------------------------------------------

  Widget _bonusQuestCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FqColors.accent.withValues(alpha: 0.6),
        ),
      ),
      child: const Row(
        children: [
          Text('🏆', style: TextStyle(fontSize: 30)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekend Warrior Bonus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: FqColors.ink,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Complete 60 mins of physical activity this weekend.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF747887),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '+250 XP',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: FqColors.energy,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(String message, String buttonText, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 38,
            color: FqColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF747887),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: FqColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ANIMATED EMOJI COMPONENT (Pulsing Fire, Bouncing Ball, Rippling Water)
// -----------------------------------------------------------------------------

class _AnimatedQuestEmoji extends StatefulWidget {
  final String emoji;
  const _AnimatedQuestEmoji({required this.emoji});

  @override
  State<_AnimatedQuestEmoji> createState() => _AnimatedQuestEmojiState();
}

class _AnimatedQuestEmojiState extends State<_AnimatedQuestEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = widget.emoji;
    final isFireOrPower = emoji == '🔥' || emoji == '⚡' || emoji == '🏃';
    final isWater = emoji == '💧';
    final isBall = emoji == '🏀' || emoji == '👟';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (isFireOrPower) {
          final scale = 0.92 + (_controller.value * 0.16);
          return Transform.scale(scale: scale, child: child);
        } else if (isWater) {
          final pulse = math.sin(_controller.value * math.pi) * 0.12;
          return Transform.scale(scale: 1.0 + pulse, child: child);
        } else if (isBall) {
          final bounce = -math.sin(_controller.value * math.pi) * 4.0;
          return Transform.translate(offset: Offset(0, bounce), child: child);
        }
        final subtle = math.sin(_controller.value * math.pi) * 0.08;
        return Transform.scale(scale: 1.0 + subtle, child: child);
      },
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}