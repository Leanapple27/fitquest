import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../notification_service.dart';
import 'ai_coach_screen.dart';
import 'quests_screen.dart';
import 'profile_screen.dart';
import 'fitmap_screen.dart';
import 'community_screen.dart';
import 'quiz_screen.dart';
import 'steps_screen.dart';
import 'snap_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int selectedIndex = 0;

  final AppState appState = AppState();

  String profileName = 'Student';
  String profileSchoolId = '';
  String profileHouse = 'Phoenix';
  bool profileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          profileLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (data != null) {
        final name = data['name'];
        final schoolId = data['schoolId'];
        final house = data['house'];

        if (mounted) {
          setState(() {
            if (name is String && name.trim().isNotEmpty) {
              profileName = name.trim();
            }

            if (schoolId is String) {
              profileSchoolId = schoolId.trim();
            }

            if (house is String && house.trim().isNotEmpty) {
              profileHouse = house.trim();
            }

            profileLoading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          profileLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          profileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            reverseDuration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              final slide = Tween<Offset>(
                begin: const Offset(0.035, 0),
                end: Offset.zero,
              ).animate(curved);

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: slide,
                  child: child,
                ),
              );
            },
            child: _buildSelectedPage(),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildSelectedPage() {
    switch (selectedIndex) {
      case 1:
        return KeyedSubtree(
          key: const ValueKey('quests'),
          child: QuestsScreen(
            appState: appState,
          ),
        );

      case 2:
        return KeyedSubtree(
          key: const ValueKey('fitmap'),
          child: FitMapScreen(
            appState: appState,
          ),
        );

      case 3:
        return KeyedSubtree(
          key: const ValueKey('community'),
          child: CommunityScreen(
            appState: appState,
          ),
        );

      case 4:
        return KeyedSubtree(
          key: const ValueKey('profile'),
          child: ProfileScreen(
            appState: appState,
          ),
        );

      case 0:
      default:
        return KeyedSubtree(
          key: const ValueKey('home'),
          child: _buildHomePage(),
        );
    }
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animatedHomeCard(
                    index: 0,
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 20),

                  _animatedHomeCard(
                    index: 1,
                    child: _buildSnapCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 2,
                    child: _buildStreakCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 3,
                    child: _buildStepsCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 4,
                    child: _buildAiCoachCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 5,
                    child: _buildPlayerCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 6,
                    child: _buildQuestCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 7,
                    child: _buildQuizCard(),
                  ),

                  const SizedBox(height: 18),

                  _animatedHomeCard(
                    index: 8,
                    child: _buildQuickStats(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOME MOTION
  // ============================================================

  Widget _animatedHomeCard({
    required Widget child,
    required int index,
  }) {
    final delay = Duration(milliseconds: 45 * index);

    return TweenAnimationBuilder<double>(
      key: ValueKey('home-card-$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = ((value * 1.25) -
                (delay.inMilliseconds / 520))
            .clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.985 + (0.015 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF302B63),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: profileLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '🧑‍🎓',
                    style: TextStyle(fontSize: 25),
                  ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profileLoading
                    ? 'Hey, Student! 👋'
                    : 'Hey, $profileName! 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF151B3D),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                profileSchoolId.isEmpty
                    ? 'Ready for today\'s quest?'
                    : '$profileSchoolId • Ready for today\'s quest?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotificationsDialog,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF151B3D),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NEW: FITQUEST SNAP
  // ============================================================

  Widget _buildSnapCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SnapScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF5E62),
              Color(0xFFFF9966),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '📸',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FITQUEST SNAP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Show your fitness moment ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Filters • XP • Privacy-first',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: Color(0xFF302B63),
              ),
              SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _notificationItem(
                '🔥',
                'Streak reminder',
                'Keep your streak alive today!',
              ),

              const SizedBox(height: 14),

              _notificationItem(
                '👟',
                'Step reminder',
                'Keep moving toward your daily goal.',
              ),

              const SizedBox(height: 14),

              _notificationItem(
                '🎯',
                'Quest reminder',
                'Your daily quest is waiting.',
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    await NotificationService.requestPermission();

                    await NotificationService
                        .showMotivationNotification();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '🔔 Motivation notification sent!',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send Motivation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _notificationItem(
    String emoji,
    String title,
    String message,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 25),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF151B3D),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STREAK
  // ============================================================

  Widget _buildStreakCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 1;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF8A3D),
              Color(0xFFFF5E62),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🔥',
                  style: TextStyle(fontSize: 31),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appState.streak} DAY STREAK',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Keep moving tomorrow!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP COUNTER
  // ============================================================

  Widget _buildStepsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StepsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  '👟',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP COUNTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.black45,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Track your real steps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Powered by Health Connect',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 30,
              color: Color(0xFF302B63),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI COACH
  // ============================================================

  Widget _buildAiCoachCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AiCoachScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF302B63),
              Color(0xFF51489A),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI FITNESS COACH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Your personal coach',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Get workouts, motivation & fitness advice',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAYER / XP
  // ============================================================

  Widget _buildPlayerCard() {
    final int currentXp = appState.xp;
    final int level = (currentXp ~/ 250) + 1;
    final int currentLevelStart = (level - 1) * 250;
    final int nextLevelXp = level * 250;
    final int levelRange = nextLevelXp - currentLevelStart;
    final int xpIntoLevel = currentXp - currentLevelStart;

    final double progress = levelRange <= 0
        ? 1.0
        : (xpIntoLevel / levelRange).clamp(0.0, 1.0);

    final int xpRemaining =
        nextLevelXp > currentXp ? nextLevelXp - currentXp : 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF302B63),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF302B63).withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.65),
                        width: 2,
                      ),
                    ),
                    child: AnimatedScale(
                      scale: 1.0 + ((level.clamp(1, 10) - 1) * 0.008),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: const Center(
                        child: Text(
                          '🧙',
                          style: TextStyle(fontSize: 43),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -3,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF302B63),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'LV $level',
                        style: const TextStyle(
                          color: Color(0xFF302B63),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LEVEL $level  •  FITNESS EXPLORER',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profileSchoolId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$profileSchoolId • House $profileHouse',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: currentXp),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, animatedXp, child) {
                  return Text(
                    '⭐ $animatedXp XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),

              const Spacer(),

              Text(
                '$nextLevelXp XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD166),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                xpRemaining > 0
                    ? '$xpRemaining XP to Level ${level + 1}'
                    : 'Level up ready! 🎉',
                key: ValueKey('$level-$xpRemaining'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // QUEST
  // ============================================================

  Widget _buildQuestCard() {
    final bool completed =
        appState.morningWarriorCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFEAF6EE)
                      : const Color(0xFFEDEBFF),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  completed
                      ? 'QUEST COMPLETE'
                      : 'TODAY\'S QUEST',
                  style: TextStyle(
                    color: completed
                        ? const Color(0xFF27733A)
                        : const Color(0xFF302B63),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const Spacer(),

              const Text(
                '+100 XP',
                style: TextStyle(
                  color: Color(0xFFFF7A45),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Morning Warrior',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Complete 20 minutes of physical activity today.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: completed
                  ? null
                  : () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF302B63),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFEAF6EE),
                disabledForegroundColor:
                    const Color(0xFF27733A),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              child: Text(
                completed
                    ? 'QUEST COMPLETED'
                    : 'START QUEST',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================

  Widget _buildQuizCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Center(
              child: Text(
                '🧠',
                style: TextStyle(fontSize: 29),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Fitness Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Test your knowledge and earn up to 100 XP.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    appState: appState,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF302B63),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK STATS
  // ============================================================

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            '🏆',
            'Badges',
            appState.badges.toString(),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _statCard(
            '🎟️',
            'Stickers',
            appState.stickers.toString(),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _statCard(
            '🏠',
            'House',
            profileHouse,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String emoji,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 25),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.flash_on_rounded,
              label: 'Quests',
              selected: selectedIndex == 1,
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.map_rounded,
              label: 'FitMap',
              selected: selectedIndex == 2,
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Community',
              selected: selectedIndex == 3,
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selectedIndex == 4,
              onTap: () {
                setState(() {
                  selectedIndex = 4;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED NAV ITEM
// ============================================================

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEDEBFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  widget.icon,
                  size: selected ? 24 : 22,
                  color: selected
                      ? const Color(0xFF302B63)
                      : Colors.black38,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: selected ? 10.5 : 9.5,
                  fontWeight: selected
                      ? FontWeight.w900
                      : FontWeight.w700,
                  color: selected
                      ? const Color(0xFF302B63)
                      : Colors.black38,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
