import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../notification_service.dart';
import '../theme/fq_animations.dart';
import '../theme/fq_colors.dart';
import '../theme/fq_typography.dart';
import 'ai_coach_screen.dart';
import 'community_screen.dart';
import 'duels_screen.dart';
import 'fitmap_screen.dart';
import 'leagues_screen.dart';
import 'profile_screen.dart';
import 'quests_screen.dart';
import 'quiz_screen.dart';
import 'rewards_screen.dart';
import 'shop_screen.dart';
import 'snap_screen.dart';
import 'steps_screen.dart';

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
      if (mounted) setState(() => profileLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (data != null && mounted) {
        final name = data['name'];
        final schoolId = data['schoolId'];
        final house = data['house'];

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
      } else if (mounted) {
        setState(() => profileLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => profileLoading = false);
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          setState(() => selectedIndex = 0);
        } else {
          _showExitConfirmationDialog();
        }
      },
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: FqColors.scaffold,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              reverseDuration: const Duration(milliseconds: 220),
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
                      begin: const Offset(0.025, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _buildSelectedPage(),
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          );
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('🏃', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Exit FitQuest?',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF151B3D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to leave?\nKeep your daily workout streak burning! 🔥',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('EXIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF302B63),
                      foregroundColor: const Color(0xFF00F5D4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('STAY & PLAY 🔥', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (selectedIndex) {
      case 1:
        return KeyedSubtree(
          key: const ValueKey('quests'),
          child: QuestsScreen(appState: appState),
        );
      case 2:
        return KeyedSubtree(
          key: const ValueKey('fitmap'),
          child: FitMapScreen(appState: appState),
        );
      case 3:
        return KeyedSubtree(
          key: const ValueKey('community'),
          child: CommunityScreen(appState: appState),
        );
      case 4:
        return KeyedSubtree(
          key: const ValueKey('profile'),
          child: ProfileScreen(appState: appState),
        );
      case 0:
      default:
        return KeyedSubtree(
          key: const ValueKey('home'),
          child: _buildHomePage(),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // HOME PAGE CONTENT WITH SMOOTH STAGGERED ENTRANCES
  // ---------------------------------------------------------------------------

  Widget _staggeredCard(int index, Widget child) {
    final delayMs = 35 * index;
    return TweenAnimationBuilder<double>(
      key: ValueKey('stagger-card-$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // 1. Top Identity Header
          _staggeredCard(0, _buildHeader()),
          const SizedBox(height: 16),

          // 2. Player Level & XP Hero Card
          _staggeredCard(1, _buildPlayerHeroCard()),
          const SizedBox(height: 16),

          // 3. High Stakes 1v1 Duels & Weekly League Arena Banner
          _staggeredCard(2, _buildHighStakesArenaBanner()),
          const SizedBox(height: 16),

          // 4. Streak & Activity Tracker Card
          _staggeredCard(3, _buildStreakCard()),
          const SizedBox(height: 18),

          // 5. Quick Actions Hub (2x2 Grid)
          _staggeredCard(
            4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QUICK ACTIONS',
                      style: FqTypography.sectionLabel(color: FqColors.muted),
                    ),
                    const Text(
                      '4 Available',
                      style: TextStyle(
                        color: FqColors.primaryMid,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildQuickActionsGrid(),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 6. Student Achievements & House Stats
          _staggeredCard(
            5,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT ACHIEVEMENTS',
                  style: FqTypography.sectionLabel(color: FqColors.muted),
                ),
                const SizedBox(height: 10),
                _buildQuickStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP IDENTITY HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar / School Icon
        GestureDetector(
          onTap: () => setState(() => selectedIndex = 4),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF302B63), Color(0xFF51489A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF302B63).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: profileLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('🎓', style: TextStyle(fontSize: 22)),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting & House Pill
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${_getTimeGreeting()}, $profileName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: FqColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('✨', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FqColors.lavender,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🛡️ $profileHouse House',
                      style: const TextStyle(
                        color: FqColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (profileSchoolId.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      profileSchoolId,
                      style: const TextStyle(
                        color: Color(0xFF747887),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Shop Coin Pill
        FQBounce(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShopScreen(appState: appState)),
            );
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFF00F5D4), width: 1.2),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  '${appState.fitCoins}',
                  style: const TextStyle(
                    color: Color(0xFF00F5D4),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Notification Bell
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE7E8EE)),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotificationsDialog,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: FqColors.ink,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PLAYER LEVEL & XP HERO CARD
  // ---------------------------------------------------------------------------

  Widget _buildPlayerHeroCard() {
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
            color: const Color(0xFF302B63).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Level Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FqColors.accent.withValues(alpha: 0.8),
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Text('🏃', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: FqColors.accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: FqColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'LV $level',
                        style: const TextStyle(
                          color: FqColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Level details and total XP
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'FITNESS EXPLORER • DIV 1',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: FqColors.accent, size: 18),
                        FQXpCounter(
                          targetValue: currentXp,
                          suffix: ' XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level Progress',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                xpRemaining > 0
                    ? '$xpRemaining XP to Level ${level + 1}'
                    : 'Level Up Ready!',
                style: const TextStyle(
                  color: FqColors.accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
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
  // HIGH STAKES 1v1 DUEL ARENA & WEEKLY LEAGUES BANNER
  // ---------------------------------------------------------------------------

  Widget _buildHighStakesArenaBanner() {
    return Column(
      children: [
        // 1v1 Duels Banner with Fluid Touch Bounce & Breathing Pulse
        FQBounce(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DuelsScreen(appState: appState)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF302B63).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('⚔️', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5D4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HIGH STAKES ARENA',
                              style: TextStyle(
                                color: Color(0xFF0F0C29),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Wager XP',
                            style: TextStyle(
                              color: Color(0xFF00F5D4),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1v1 Student Workout Duels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Challenge friends & verify reps via AI Camera',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00F5D4), size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Weekly Leagues Banner with Fluid Touch Bounce
        FQBounce(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LeaguesScreen(appState: appState)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🥇', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY LEAGUE • GOLD DIVISION #4',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD97706),
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Top 3 Promote to Diamond • 2d 14h left',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Rank #2 ⚡',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STREAK & WEEKLY ACTIVITY TRACKER
  // ---------------------------------------------------------------------------

  Widget _buildStreakCard() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    final hasActiveToday = appState.morningWarriorCompleted ||
        appState.completedDailyQuestIds.isNotEmpty ||
        appState.completedQuests > 0;

    return FQBounce(
      onTap: _showStreakMatrixDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7545), Color(0xFFFF5722)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7545).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appState.streak} DAY STREAK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasActiveToday
                          ? 'Today\'s activity logged! Streak safe! 🔥'
                          : 'Complete today\'s quest to protect your streak!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly 7-day tracker with GREEN (Done) and RED (Skipped)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isPast = index < currentDayIndex;
              final isToday = index == currentDayIndex;
              final isFuture = index > currentDayIndex;

              // Past days: based on streak or activity calendar
              // If student has streak >= (currentDayIndex - index + 1), it was completed, else skipped.
              final bool isDone = isPast
                  ? (appState.streak >= (currentDayIndex - index))
                  : (isToday && hasActiveToday);
              final bool isSkipped = isPast && !isDone;

              Color circleBg;
              Widget iconOrText;
              Border? border;

              if (isDone) {
                circleBg = const Color(0xFF10B981); // Bright Emerald Green for DONE
                iconOrText = const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                );
              } else if (isSkipped) {
                circleBg = const Color(0xFFEF4444); // Bright Red for SKIPPED
                iconOrText = const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 17,
                );
              } else if (isToday) {
                circleBg = Colors.white.withValues(alpha: 0.28);
                border = Border.all(color: FqColors.accent, width: 2.5);
                iconOrText = const Text('⚡', style: TextStyle(fontSize: 15));
              } else {
                // Future
                circleBg = Colors.white.withValues(alpha: 0.12);
                border = Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1);
                iconOrText = Text(
                  days[index],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: border,
                      boxShadow: (isDone || isSkipped || isToday)
                          ? [
                              BoxShadow(
                                color: (isDone
                                        ? const Color(0xFF10B981)
                                        : isSkipped
                                            ? const Color(0xFFEF4444)
                                            : FqColors.accent)
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(child: iconOrText),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      color: isToday
                          ? Colors.white
                          : Colors.white.withValues(alpha: isFuture ? 0.5 : 0.85),
                      fontSize: 9.5,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 12),

          // Legend Bar: Green = Activity Done, Red = Day Skipped
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Skipped',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: FqColors.accent, width: 1.5),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  // ---------------------------------------------------------------------------
  // QUICK ACTIONS (2x2 GRID)
  // ---------------------------------------------------------------------------

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFFEC4899),
                title: 'FitQuest Snap',
                subtitle: 'Photo log & moments',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SnapScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.directions_walk_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'Step Counter',
                subtitle: 'Track daily steps',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StepsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.smart_toy_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'AI Coach',
                subtitle: 'Personal workout tips',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiCoachScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.quiz_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Daily Quiz',
                subtitle: 'Earn +100 XP',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen(appState: appState)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStreakMatrixDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appState.streak} Day Active Streak',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF151B3D)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '1.5x Multiplier Active ⚡',
                        style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('7-Day Milestone', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      Text('UNLOCKED ✓', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900, fontSize: 11)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('14-Day Milestone (2x XP)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      Text('2 Days Left', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Streak Freeze Protection', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      Text('1 Available 🛡️', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF302B63),
                  foregroundColor: const Color(0xFF00F5D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('KEEP STREAK BURNING 🔥', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FQBounce(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E8EE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: FqColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF747887),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT ACHIEVEMENTS & HOUSE STATS
  // ---------------------------------------------------------------------------

  Widget _buildQuickStats() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openRewards,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7E8EE)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statMetric('${appState.badges}', 'Badges'),
                    Container(width: 1, height: 28, color: const Color(0xFFE7E8EE)),
                    _statMetric('${appState.stickers}', 'Stickers'),
                    Container(width: 1, height: 28, color: const Color(0xFFE7E8EE)),
                    _statMetric(profileHouse, 'House'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: FqColors.ink,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF747887),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _openRewards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RewardsScreen(appState: appState),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS DIALOG
  // ---------------------------------------------------------------------------

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.notifications_rounded, color: FqColors.primary),
              SizedBox(width: 8),
              Text(
                'Notifications',
                style: TextStyle(
                  color: FqColors.ink,
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
                'Keep your daily streak alive today!',
              ),
              const SizedBox(height: 12),
              _notificationItem(
                Icons.directions_walk_rounded,
                'Step reminder',
                'Keep moving toward your daily step target.',
              ),
              const SizedBox(height: 12),
              _notificationItem(
                Icons.track_changes_rounded,
                'Quest reminder',
                'Your morning warrior quest is ready.',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await NotificationService.requestPermission();
                    await NotificationService.showMotivationNotification();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Motivation notification sent!')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Motivation Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FqColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _notificationItem(IconData icon, String title, String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: FqColors.lavender,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: FqColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: FqColors.ink,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF747887)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FLOATING BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _navItem(0, Icons.home_rounded, 'Home'),
          _navItem(1, Icons.flash_on_rounded, 'Quests'),
          _navItem(2, Icons.map_rounded, 'FitMap'),
          _navItem(3, Icons.shield_rounded, 'Community'),
          _navItem(4, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => selectedIndex = index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? FqColors.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? FqColors.primary : const Color(0xFF8B8E99),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? FqColors.primary : const Color(0xFF8B8E99),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}