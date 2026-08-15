import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

import '../app_state.dart';
import '../notification_service.dart';
import 'ai_coach_screen.dart';
import 'quests_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';
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
          backgroundColor: FqColors.scaffold,
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

  // ============================================================
  // HOME PAGE LAYOUT
  //
  // Visual hierarchy (per design spec):
  // 1. Header (identity/greeting)
  // 2. Player / XP hero
  // 3. Today's Quest
  // 4. Streak
  // 5. Quick actions (Snap + Steps)
  // 6. AI Coach
  // 7. Quiz
  // 8. Quick stats
  //
  // NOTE: Only ordering/visual presentation changed here. Every widget,
  // callback, calculation and navigation call below is identical to the
  // original implementation.
  // ============================================================

  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animatedHomeCard(
                    index: 0,
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 18),
                  _animatedHomeCard(
                    index: 1,
                    child: _buildPlayerCard(),
                  ),
                  const SizedBox(height: 18),
                  _animatedHomeCard(
                    index: 2,
                    child: _buildQuestCard(),
                  ),
                  const SizedBox(height: 14),
                  _animatedHomeCard(
                    index: 3,
                    child: _buildStreakCard(),
                  ),
                  const SizedBox(height: 22),
                  _sectionLabel('QUICK ACTIONS'),
                  const SizedBox(height: 9),
                  _animatedHomeCard(
                    index: 4,
                    child: _buildQuickActionsRow(),
                  ),
                  const SizedBox(height: 18),
                  _animatedHomeCard(
                    index: 5,
                    child: _buildAiCoachCard(),
                  ),
                  const SizedBox(height: 12),
                  _animatedHomeCard(
                    index: 6,
                    child: _buildQuizCard(),
                  ),
                  const SizedBox(height: 18),
                  _sectionLabel('YOUR STATS'),
                  const SizedBox(height: 9),
                  _animatedHomeCard(
                    index: 7,
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Colors.black45,
        ),
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
        final delayedValue =
            ((value * 1.25) - (delay.inMilliseconds / 520)).clamp(0.0, 1.0);

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
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: FqColors.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: FqShadows.cardSoft(),
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
                : const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                selectedIndex = 4;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileLoading ? 'Hey, Student!' : 'Hey, $profileName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: FqColors.ink,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: FqColors.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: FqShadows.cardSoft(),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotificationsDialog,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: FqColors.ink,
            ),
          ),
        ),
      ],
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
            borderRadius: FqRadii.heroBorder,
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: FqColors.primary,
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
                Icons.local_fire_department_rounded,
                'Streak reminder',
                'Keep your streak alive today!',
              ),
              const SizedBox(height: 14),
              _notificationItem(
                Icons.directions_walk_rounded,
                'Step reminder',
                'Keep moving toward your daily goal.',
              ),
              const SizedBox(height: 14),
              _notificationItem(
                Icons.track_changes_rounded,
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

                    await NotificationService.showMotivationNotification();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Motivation notification sent!',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send Motivation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FqColors.primary,
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
    IconData icon,
    String title,
    String message,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: FqColors.lavender,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: FqColors.primary,
          ),
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
                  color: FqColors.ink,
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
  // PLAYER / XP — HERO ELEMENT
  // ============================================================

  Widget _buildPlayerCard() {
    final int currentXp = appState.xp;
    final int level = (currentXp ~/ 250) + 1;
    final int currentLevelStart = (level - 1) * 250;
    final int nextLevelXp = level * 250;
    final int levelRange = nextLevelXp - currentLevelStart;
    final int xpIntoLevel = currentXp - currentLevelStart;

    final double progress =
        levelRange <= 0 ? 1.0 : (xpIntoLevel / levelRange).clamp(0.0, 1.0);

    final int xpRemaining =
        nextLevelXp > currentXp ? nextLevelXp - currentXp : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FqColors.primary,
            FqColors.primary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: FqRadii.heroBorder,
        boxShadow: FqShadows.heroBrand(),
      ),
      child: Stack(
        children: [
          // Subtle decorative glow, purely visual.
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FqColors.accent.withValues(alpha: 0.7),
                            width: 2.5,
                          ),
                        ),
                        child: AnimatedScale(
                          scale: 1.0 + ((level.clamp(1, 10) - 1) * 0.008),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -6,
                        bottom: -4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: FqColors.accent,
                            borderRadius: FqRadii.chipBorder,
                            border: Border.all(
                              color: FqColors.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FqColors.accent.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'LV $level',
                            style: const TextStyle(
                              color: FqColors.primary,
                              fontSize: 10.5,
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
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LEVEL $level  •  FITNESS EXPLORER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (profileSchoolId.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '$profileSchoolId • House $profileHouse',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: currentXp),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedXp, child) {
                      return RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: FqColors.accent,
                                  size: 18,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: '$animatedXp',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const TextSpan(
                              text: ' XP',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Text(
                    '$nextLevelXp XP',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: FqRadii.cardBorder,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        FqColors.accent,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: FqSpacing.label),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    xpRemaining > 0
                        ? '$xpRemaining XP to Level ${level + 1}'
                        : 'Level up ready!',
                    key: ValueKey('$level-$xpRemaining'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUEST — PRIMARY ACTION
  // ============================================================

  Widget _buildQuestCard() {
    final bool completed = appState.morningWarriorCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FqSpacing.page),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.heroBorder,
        border: Border.all(
          color: completed
              ? FqColors.success.withValues(alpha: 0.25)
              : FqColors.primary.withValues(alpha: 0.12),
          width: 1.4,
        ),
        boxShadow: FqShadows.cardSoft(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      completed ? FqColors.successSurface : FqColors.lavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.bolt_rounded,
                      size: 14,
                      color:
                          completed ? FqColors.success : FqColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      completed ? 'QUEST COMPLETE' : 'TODAY\'S QUEST',
                      style: TextStyle(
                        color:
                            completed ? FqColors.success : FqColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FqColors.energy.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+100 XP',
                  style: TextStyle(
                    color: FqColors.energy,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Morning Warrior',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: FqColors.ink,
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: completed
                  ? null
                  : () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: FqColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: FqColors.successSurface,
                disabledForegroundColor: FqColors.success,
                elevation: completed ? 0 : 2,
                shadowColor: FqColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    completed
                        ? Icons.check_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    completed ? 'QUEST COMPLETED' : 'START QUEST',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      fontSize: 14.5,
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
        padding: const EdgeInsets.all(FqSpacing.page),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FqColors.energy,
              FqColors.energy.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: FqRadii.heroBorder,
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 30,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keep moving tomorrow!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS — SNAP + STEPS (paired, compact feature cards)
  // ============================================================

  Widget _buildQuickActionsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSnapCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildStepsCard()),
      ],
    );
  }

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              FqColors.energy,
              FqColors.energy,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: FqRadii.cardBorder,
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'FITQUEST SNAP',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Show your moment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text(
                  'Open',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FqColors.surface,
          borderRadius: FqRadii.cardBorder,
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_walk_rounded,
                  color: FqColors.primary,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'STEP COUNTER',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track your steps',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: FqColors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text(
                  'Open',
                  style: TextStyle(
                    color: FqColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: FqColors.primary,
                  size: 18,
                ),
              ],
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
        padding: const EdgeInsets.all(FqSpacing.page),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: FqColors.heroGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: FqRadii.heroBorder,
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 26,
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
                      fontSize: 18,
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================

  Widget _buildQuizCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              appState: appState,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FqSpacing.page),
        decoration: BoxDecoration(
          color: FqColors.surface,
          borderRadius: FqRadii.heroBorder,
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.quiz_rounded,
                  color: FqColors.primary,
                  size: 27,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Fitness Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: FqColors.ink,
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: FqColors.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: FqColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK STATS
  // ============================================================

  Widget _buildQuickStats() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openRewards,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
        decoration: BoxDecoration(
          color: FqColors.surface,
          borderRadius: FqRadii.cardBorder,
          border: Border.all(
            color: FqColors.primary.withValues(alpha: 0.08),
          ),
          boxShadow: FqShadows.cardSoft(),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: FqColors.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Row(
                children: [
                  _compactStat('Badges', appState.badges.toString()),
                  _statDivider(),
                  _compactStat('Stickers', appState.stickers.toString()),
                  _statDivider(),
                  _compactStat('House', profileHouse),
                ],
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.chevron_right_rounded,
              color: FqColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _openRewards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RewardsScreen(
          appState: appState,
        ),
      ),
    );
  }

  Widget _compactStat(String title, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: FqColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 46,
      color: Colors.black.withValues(alpha: 0.06),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: FqColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: FqColors.ink,
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
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.navigationBorder,
        boxShadow: FqShadows.navFloat(),
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
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? FqColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
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
                  color: selected ? FqColors.primary : FqColors.ink.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: selected ? 10.5 : 9.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? FqColors.primary : FqColors.ink.withValues(alpha: 0.62),
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