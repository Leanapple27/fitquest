import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/fq_colors.dart';
import '../theme/fq_radii.dart';
import '../theme/fq_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_calendar_screen.dart';
import 'nutrition_screen.dart';
import 'privacy_safety_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String profileName = 'Student';
  String schoolId = '';
  String house = 'Phoenix';

  int xp = 0;
  int streak = 0;
  int badges = 0;
  int stickers = 0;

  bool loading = true;

  String selectedOutfit = 'default';
  String selectedFrame = 'none';
  String selectedBanner = 'fitness';

  // Private health profile fields stored on the authenticated user's document.
  double? heightCm;
  double? weightKg;
  String bloodGroup = '';
  DateTime? dateOfBirth;

  bool showAvatarEditor = false;
  int avatarTab = 0;

  late final AnimationController _avatarAnimationController;
  bool _avatarCelebrating = false;

  int? _lastKnownLevel;
  bool _showLevelUp = false;
  String _levelUpReward = '';

  @override
  void initState() {
    super.initState();

    _avatarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _loadProfile();
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => loading = false);
      }
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
        final id = data['schoolId'];
        final userHouse = data['house'];
        final userXp = data['xp'];
        final userStreak = data['streak'];
        final userBadges = data['badges'];
        final userStickers = data['stickers'];

        final savedOutfit = data['avatarOutfit'];
        final savedFrame = data['avatarFrame'];
        final savedBanner = data['avatarBanner'];

        final savedHeightCm = data['heightCm'];
        final savedWeightKg = data['weightKg'];
        final savedBloodGroup = data['bloodGroup'];
        final savedDateOfBirth = data['dateOfBirth'];

        final incomingXp = userXp is num ? userXp.toInt() : xp;
        final incomingLevel = (incomingXp ~/ 250) + 1;

        final storedLastSeenLevel = data['lastSeenLevel'] is num
            ? (data['lastSeenLevel'] as num).toInt()
            : null;

        final previousLevel = storedLastSeenLevel ?? _lastKnownLevel;

        setState(() {
          if (name is String && name.trim().isNotEmpty) {
            profileName = name.trim();
          }

          if (id is String) {
            schoolId = id.trim();
          }

          if (userHouse is String && userHouse.trim().isNotEmpty) {
            house = userHouse.trim();
          }

          if (userXp is num) {
            xp = userXp.toInt();
          }

          if (userStreak is num) {
            streak = userStreak.toInt();
          }

          if (userBadges is List) {
            badges = userBadges.length;
          }

          if (userStickers is List) {
            stickers = userStickers.length;
          }

          if (savedOutfit is String && savedOutfit.isNotEmpty) {
            selectedOutfit = savedOutfit;
          }

          if (savedFrame is String && savedFrame.isNotEmpty) {
            selectedFrame = savedFrame;
          }

          if (savedBanner is String && savedBanner.isNotEmpty) {
            selectedBanner = savedBanner;
          }

          if (savedHeightCm is num && savedHeightCm > 0) {
            heightCm = savedHeightCm.toDouble();
          }

          if (savedWeightKg is num && savedWeightKg > 0) {
            weightKg = savedWeightKg.toDouble();
          }

          if (savedBloodGroup is String) {
            bloodGroup = savedBloodGroup.trim();
          }

          if (savedDateOfBirth is Timestamp) {
            dateOfBirth = savedDateOfBirth.toDate();
          } else if (savedDateOfBirth is String) {
            dateOfBirth = DateTime.tryParse(savedDateOfBirth);
          }

          loading = false;
          _lastKnownLevel = incomingLevel;
        });

        final shouldCelebrate =
            previousLevel != null && incomingLevel > previousLevel;

        // Remember the level already seen so the celebration is shown once.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'lastSeenLevel': incomingLevel,
          },
          SetOptions(merge: true),
        );

        if (mounted && shouldCelebrate) {
          _showLevelUpCelebration(incomingLevel);
        }
      } else if (mounted) {
        setState(() => loading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.person_rounded,
                color: FqColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Profile',
              style: FqTypography.screenTitle(color: FqColors.ink).copyWith(
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Shop',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopScreen(appState: widget.appState),
                ),
              );
            },
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: FqColors.ink,
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: FqColors.ink,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProfile,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                // 1. Profile Hero & Avatar
                _buildProfileHeader(),
                const SizedBox(height: 16),

                // 2. Main Stats Grid
                _buildStats(),
                const SizedBox(height: 16),

                // 3. Health & Vitals Snapshot
                _buildHealthSnapshotCard(),
                const SizedBox(height: 16),

                // 4. Trackers & Wellness Section
                _buildSection(
                  title: 'TRACKERS & WELLNESS',
                  children: [
                    _buildMenuItem(
                      iconData: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Activity Calendar',
                      subtitle: 'Track workout streak and upcoming events',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconData: Icons.restaurant_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Nutrition Tracker',
                      subtitle: 'Log meals, water intake and dietary balance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NutritionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Rewards & Milestones
                _buildSection(
                  title: 'REWARDS & HOUSE',
                  children: [
                    _buildMenuItem(
                      iconData: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Badges & Achievements',
                      subtitle: '$badges badges earned so far',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RewardsScreen(
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconData: Icons.local_activity_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Sticker Collection',
                      subtitle: '$stickers stickers collected',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RewardsScreen(
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconData: Icons.shield_rounded,
                      iconColor: FqColors.energy,
                      title: '$house House',
                      subtitle: 'School house affiliation',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. Privacy & Safety
                _buildSection(
                  title: 'PRIVACY & SECURITY',
                  children: [
                    _buildMenuItem(
                      iconData: Icons.lock_outline_rounded,
                      iconColor: FqColors.primaryMid,
                      title: 'Privacy Controls',
                      subtitle: 'Control student visibility and consent',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySafetyScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconData: Icons.verified_user_outlined,
                      iconColor: FqColors.success,
                      title: 'Safety Centre',
                      subtitle: 'Student safety standards and rules',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySafetyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Account & Settings
                _buildSection(
                  title: 'ACCOUNT',
                  children: [
                    _buildMenuItem(
                      iconData: Icons.school_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'School ID',
                      subtitle: schoolId.isEmpty ? 'Not assigned' : schoolId,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      iconData: Icons.settings_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'App Settings',
                      subtitle: 'Notifications and preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Log out Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FqColors.danger,
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    label: const Text(
                      'LOG OUT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLevelUp) _buildLevelUpOverlay(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE HEADER (Identity + Avatar + Level Progress)
  // ---------------------------------------------------------------------------

  Widget _buildProfileHeader() {
    final level = (xp ~/ 250) + 1;
    final levelStart = (level - 1) * 250;
    final nextLevel = level * 250;
    final progress =
        ((xp - levelStart) / (nextLevel - levelStart)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF51489A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
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
          // Top Identity Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🛡️ $house House',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5D4).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00F5D4).withValues(alpha: 0.6),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF00F5D4),
                                  size: 11,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'FAIR PLAY',
                                  style: TextStyle(
                                    color: Color(0xFF00F5D4),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      loading ? 'Loading...' : profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Riverside Academy • Student',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _levelBadge(level),
            ],
          ),
          const SizedBox(height: 16),

          // Avatar Character & Quick stats
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildAnimatedAvatar(
                  level: level,
                  size: 130,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _heroStatMini(
                      Icons.local_fire_department_rounded,
                      '$streak Days',
                      'Active Streak',
                      FqColors.energy,
                    ),
                    const SizedBox(height: 8),
                    _heroStatMini(
                      Icons.bolt_rounded,
                      '$xp XP',
                      'Total Energy',
                      FqColors.accent,
                    ),
                    const SizedBox(height: 8),
                    _heroStatMini(
                      Icons.emoji_events_rounded,
                      '$badges Unlocked',
                      'Badges',
                      const Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // XP Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level Progress',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                progress >= 1
                    ? 'LEVEL COMPLETE!'
                    : '${(nextLevel - xp).clamp(0, nextLevel)} XP to Level ${level + 1}',
                style: const TextStyle(
                  color: FqColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
          const SizedBox(height: 14),

          // Customize Avatar Toggle Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showAvatarEditor = !showAvatarEditor;
                });
              },
              icon: Icon(
                showAvatarEditor
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.auto_awesome_rounded,
                size: 16,
              ),
              label: Text(
                showAvatarEditor ? 'Hide Avatar Studio' : 'Customize Avatar Studio',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FqColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // Inline Avatar Editor
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _buildAvatarEditor(level),
            ),
            crossFadeState: showAvatarEditor
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _heroStatMini(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: FqColors.accent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FqColors.accent.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        'LV $level',
        style: const TextStyle(
          color: FqColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN STATS GRID
  // ---------------------------------------------------------------------------

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.bolt_rounded,
            '$xp',
            'Total XP',
            FqColors.energy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.local_fire_department_rounded,
            '$streak Days',
            'Streak',
            const Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.military_tech_rounded,
            '$badges',
            'Badges',
            const Color(0xFFEAB308),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E8EE)),
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: FqColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF747887),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEALTH & VITALS SNAPSHOT
  // ---------------------------------------------------------------------------

  Widget _buildHealthSnapshotCard() {
    final currentBmi = bmi;
    String bmiLabel = 'Not Set';
    Color bmiColor = const Color(0xFF747887);

    if (currentBmi != null) {
      if (currentBmi < 18.5) {
        bmiLabel = 'Underweight';
        bmiColor = const Color(0xFF3B82F6);
      } else if (currentBmi <= 24.9) {
        bmiLabel = 'Healthy Weight';
        bmiColor = const Color(0xFF10B981);
      } else if (currentBmi <= 29.9) {
        bmiLabel = 'Moderate';
        bmiColor = const Color(0xFFF59E0B);
      } else {
        bmiLabel = 'High';
        bmiColor = const Color(0xFFEF4444);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: FqColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HEALTH & VITALS',
                    style: TextStyle(
                      color: FqColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _showHealthProfileSheet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: FqColors.lavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: FqColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: FqColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _vitalMetric(
                  'HEIGHT',
                  heightCm != null ? '${_formatNumber(heightCm!)} cm' : '--',
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE7E8EE)),
              Expanded(
                child: _vitalMetric(
                  'WEIGHT',
                  weightKg != null ? '${_formatNumber(weightKg!)} kg' : '--',
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE7E8EE)),
              Expanded(
                child: _vitalMetric(
                  'BLOOD',
                  bloodGroup.isNotEmpty ? bloodGroup : '--',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: FqColors.scaffold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'BMI Index: ',
                  style: TextStyle(
                    color: Color(0xFF747887),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  currentBmi != null
                      ? currentBmi.toStringAsFixed(1)
                      : 'Not Calculated',
                  style: const TextStyle(
                    color: FqColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (currentBmi != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bmiColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bmiLabel,
                      style: TextStyle(
                        color: bmiColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
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
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION & MENU ITEM BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FqTypography.sectionLabel(color: FqColors.muted),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7E8EE)),
            ),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData iconData,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor,
            size: 19,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: FqColors.ink,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 10.5,
          color: Color(0xFF747887),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 20,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AVATAR ANIMATION & CUSTOMIZATION
  // ---------------------------------------------------------------------------

  Widget _buildAnimatedAvatar({
    required int level,
    required double size,
  }) {
    final frameColor = selectedFrame == 'neon_cyber'
        ? const Color(0xFF00F5D4)
        : selectedFrame == 'gold_flame'
            ? const Color(0xFFF59E0B)
            : selectedFrame == 'diamond_aura'
                ? const Color(0xFF38BDF8)
                : selectedFrame == 'royal_crown'
                    ? const Color(0xFFEC4899)
                    : selectedFrame == 'gold'
                        ? const Color(0xFFFFD54F)
                        : selectedFrame == 'silver'
                            ? const Color(0xFFD9E2F2)
                            : const Color(0xFFB87842);

    return AnimatedBuilder(
      animation: _avatarAnimationController,
      builder: (context, child) {
        final bob = math.sin(
              _avatarAnimationController.value * math.pi * 2,
            ) *
            2.0;
        final reaction = _avatarCelebrating
            ? -math.sin(
                  _avatarAnimationController.value * math.pi,
                ) *
                9
            : 0.0;

        return Transform.translate(
          offset: Offset(0, bob + reaction),
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size + 12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selectedFrame != 'none')
              Container(
                width: size - 4,
                height: size - 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: frameColor,
                    width: selectedFrame == 'gold' ? 6 : 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: frameColor.withValues(alpha: 0.28),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 4,
              child: Container(
                width: size * 0.58,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              child: _AvatarCharacter(
                outfit: selectedOutfit,
                level: level,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarEditor(int level) {
    final tabs = ['OUTFITS', 'FRAMES', 'BANNERS'];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(
              tabs.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      avatarTab = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: avatarTab == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: avatarTab == index
                            ? FqColors.primary
                            : Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: avatarTab == 0
                ? _buildOutfitOptions(level)
                : avatarTab == 1
                    ? _buildFrameOptions(level)
                    : _buildBannerOptions(level),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitOptions(int level) {
    final outfits = [
      ('default', 'FitQuest', 1, Icons.sports),
      ('running', 'Runner', 2, Icons.directions_run_rounded),
      ('cricket', 'Cricket', 3, Icons.sports_cricket_rounded),
      ('football', 'Football', 4, Icons.sports_soccer_rounded),
    ];

    return _optionGrid(
      options: outfits,
      selected: selectedOutfit,
      onSelect: (id, unlockLevel) {
        if (level < unlockLevel) {
          _showLocked(unlockLevel);
          return;
        }
        setState(() {
          selectedOutfit = id;
        });
        _playAvatarReaction();
        _saveAvatarSelection(outfit: id);
      },
    );
  }

  Widget _buildFrameOptions(int level) {
    final frames = [
      ('none', 'None', 1, Icons.circle_outlined),
      ('neon_cyber', 'Cyber', 1, Icons.circle),
      ('gold_flame', 'Sunfire', 1, Icons.local_fire_department_rounded),
      ('diamond_aura', 'Diamond', 1, Icons.diamond_rounded),
      ('royal_crown', 'Royal', 1, Icons.military_tech_rounded),
      ('bronze', 'Bronze', 2, Icons.circle),
      ('silver', 'Silver', 3, Icons.circle),
      ('gold', 'Gold', 5, Icons.auto_awesome_rounded),
    ];

    return _optionGrid(
      options: frames,
      selected: selectedFrame,
      onSelect: (id, unlockLevel) {
        if (level < unlockLevel) {
          _showLocked(unlockLevel);
          return;
        }
        setState(() {
          selectedFrame = id;
        });
        _playAvatarReaction();
        _saveAvatarSelection(frame: id);
      },
    );
  }

  Widget _buildBannerOptions(int level) {
    final banners = [
      ('fitness', 'Explorer', 1, Icons.local_fire_department_rounded),
      ('streak', 'Streak', 3, Icons.bolt_rounded),
      ('quest', 'Master', 5, Icons.emoji_events_rounded),
    ];

    return _optionGrid(
      options: banners,
      selected: selectedBanner,
      onSelect: (id, unlockLevel) {
        if (level < unlockLevel) {
          _showLocked(unlockLevel);
          return;
        }
        setState(() {
          selectedBanner = id;
        });
        _playAvatarReaction();
        _saveAvatarSelection(banner: id);
      },
    );
  }

  Widget _optionGrid({
    required List<(String, String, int, IconData)> options,
    required String selected,
    required void Function(String, int) onSelect,
  }) {
    return GridView.builder(
      key: ValueKey(options.map((item) => item.$1).join()),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final id = option.$1;
        final name = option.$2;
        final unlockLevel = option.$3;
        final icon = option.$4;
        final locked = (xp ~/ 250) + 1 < unlockLevel;
        final isSelected = selected == id;

        return GestureDetector(
          onTap: () => onSelect(id, unlockLevel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? FqColors.accent
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? FqColors.primary
                      : locked
                          ? Colors.white38
                          : Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? FqColors.primary : Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  locked ? 'LV $unlockLevel' : 'READY',
                  style: TextStyle(
                    color: locked ? Colors.white38 : FqColors.accent,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playAvatarReaction() {
    _avatarAnimationController
      ..reset()
      ..forward();

    setState(() {
      _avatarCelebrating = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _avatarCelebrating = false;
      });
    });
  }

  Future<void> _saveAvatarSelection({
    String? outfit,
    String? frame,
    String? banner,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (outfit != null) updates['avatarOutfit'] = outfit;
    if (frame != null) updates['avatarFrame'] = frame;
    if (banner != null) updates['avatarBanner'] = banner;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));
    } catch (_) {}
  }

  void _showLocked(int unlockLevel) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Reach Level $unlockLevel to unlock this item.',
          ),
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // LEVEL UP OVERLAY
  // ---------------------------------------------------------------------------

  Widget _buildLevelUpOverlay() {
    final level = _lastKnownLevel ?? 1;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.70),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.55, end: 1.0),
              duration: const Duration(milliseconds: 650),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 27),
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: FqColors.accent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FqColors.accent.withValues(alpha: 0.30),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FqColors.lavender,
                        border: Border.all(
                          color: FqColors.accent,
                          width: 4,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🏆',
                          style: TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'LEVEL UP!',
                      style: TextStyle(
                        color: FqColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LEVEL $level REACHED',
                      style: const TextStyle(
                        color: FqColors.energy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: FqColors.lavender,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NEW REWARD UNLOCKED',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _levelUpReward,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: FqColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showLevelUp = false;
                                _avatarCelebrating = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FqColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('LATER'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _equipLevelReward();
                              if (!mounted) return;
                              setState(() {
                                _showLevelUp = false;
                                _avatarCelebrating = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FqColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('EQUIP NOW'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelUpCelebration(int level) {
    final reward = switch (level) {
      2 => 'Runner Outfit Unlocked',
      3 => 'Cricket Outfit Unlocked',
      4 => 'Football Outfit Unlocked',
      5 => 'Gold Frame Unlocked',
      7 => 'Fitness Buddy Banner Unlocked',
      10 => 'Champion Reward Unlocked',
      _ => 'New Fitness Reward Unlocked',
    };

    setState(() {
      _levelUpReward = reward;
      _showLevelUp = true;
      _avatarCelebrating = true;
    });

    _avatarAnimationController
      ..reset()
      ..forward();
  }

  Future<void> _equipLevelReward() async {
    final level = _lastKnownLevel ?? 1;

    String? outfit;
    String? frame;
    String? banner;

    switch (level) {
      case 2:
        outfit = 'running';
        break;
      case 3:
        outfit = 'cricket';
        break;
      case 4:
        outfit = 'football';
        break;
      case 5:
        frame = 'gold';
        break;
      case 7:
        banner = 'streak';
        break;
      case 10:
        frame = 'gold';
        banner = 'quest';
        break;
      default:
        break;
    }

    if (outfit != null) setState(() => selectedOutfit = outfit!);
    if (frame != null) setState(() => selectedFrame = frame!);
    if (banner != null) setState(() => selectedBanner = banner!);

    await _saveAvatarSelection(
      outfit: outfit,
      frame: frame,
      banner: banner,
    );
  }

  // ---------------------------------------------------------------------------
  // HEALTH PROFILE SHEET (BMI Calculation)
  // ---------------------------------------------------------------------------

  double? get bmi {
    final height = heightCm;
    final weight = weightKg;

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return null;
    }

    final heightMeters = height / 100;
    return weight / (heightMeters * heightMeters);
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  Future<void> _saveHealthProfile({
    required double? newHeightCm,
    required double? newWeightKg,
    required String newBloodGroup,
    required DateTime? newDateOfBirth,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'heightCm': newHeightCm,
      'weightKg': newWeightKg,
      'bloodGroup': newBloodGroup,
      'dateOfBirth': newDateOfBirth == null
          ? null
          : Timestamp.fromDate(newDateOfBirth),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        heightCm = newHeightCm;
        weightKg = newWeightKg;
        bloodGroup = newBloodGroup;
        dateOfBirth = newDateOfBirth;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Health profile saved.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not save your health profile.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _showHealthProfileSheet() async {
    final heightController = TextEditingController(
      text: heightCm == null ? '' : _formatNumber(heightCm!),
    );
    final weightController = TextEditingController(
      text: weightKg == null ? '' : _formatNumber(weightKg!),
    );

    String selectedBloodGroup = bloodGroup;
    DateTime? selectedDate = dateOfBirth;
    String? validationMessage;
    bool saving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              final previewHeight =
                  double.tryParse(heightController.text.trim());
              final previewWeight =
                  double.tryParse(weightController.text.trim());

              double? previewBmi;
              if (previewHeight != null &&
                  previewWeight != null &&
                  previewHeight > 0 &&
                  previewWeight > 0) {
                final heightMeters = previewHeight / 100;
                previewBmi =
                    previewWeight / (heightMeters * heightMeters);
              }

              Future<void> pickDate() async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ??
                      DateTime(now.year - 13, now.month, now.day),
                  firstDate: DateTime(1900),
                  lastDate: now,
                  helpText: 'SELECT DATE OF BIRTH',
                );

                if (picked != null) {
                  setSheetState(() {
                    selectedDate = picked;
                  });
                }
              }

              Future<void> save() async {
                final parsedHeight =
                    double.tryParse(heightController.text.trim());
                final parsedWeight =
                    double.tryParse(weightController.text.trim());

                if (parsedHeight != null &&
                    (parsedHeight < 50 || parsedHeight > 250)) {
                  setSheetState(() {
                    validationMessage =
                        'Height should be between 50 and 250 cm.';
                  });
                  return;
                }

                if (parsedWeight != null &&
                    (parsedWeight < 10 || parsedWeight > 300)) {
                  setSheetState(() {
                    validationMessage =
                        'Weight should be between 10 and 300 kg.';
                  });
                  return;
                }

                setSheetState(() {
                  validationMessage = null;
                  saving = true;
                });

                await _saveHealthProfile(
                  newHeightCm: parsedHeight,
                  newWeightKg: parsedWeight,
                  newBloodGroup: selectedBloodGroup,
                  newDateOfBirth: selectedDate,
                );

                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              }

              return Container(
                padding: EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: FqColors.scaffold,
                  borderRadius: FqRadii.sheetTopBorder,
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: FqColors.lavender,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.monitor_heart_rounded,
                                color: FqColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HEALTH PROFILE',
                                    style: TextStyle(
                                      color: FqColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Private student health vitals',
                                    style: TextStyle(
                                      color: FqColors.muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _healthInput(
                                controller: heightController,
                                label: 'HEIGHT',
                                hint: '170',
                                suffix: 'cm',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setSheetState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _healthInput(
                                controller: weightController,
                                label: 'WEIGHT',
                                hint: '60',
                                suffix: 'kg',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setSheetState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'BLOOD GROUP',
                          style: TextStyle(
                            color: FqColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            '',
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'AB+',
                            'AB-',
                            'O+',
                            'O-',
                          ].map((group) {
                            final selected = selectedBloodGroup == group;

                            return ChoiceChip(
                              label: Text(group.isEmpty ? 'Not set' : group),
                              selected: selected,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedBloodGroup = group;
                                });
                              },
                              selectedColor: FqColors.lavender,
                              labelStyle: TextStyle(
                                color: selected
                                    ? FqColors.primary
                                    : FqColors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'DATE OF BIRTH',
                          style: TextStyle(
                            color: FqColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: pickDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE7E8EE),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: FqColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedDate == null
                                        ? 'Select birth date'
                                        : '${selectedDate!.day.toString().padLeft(2, '0')}/'
                                            '${selectedDate!.month.toString().padLeft(2, '0')}/'
                                            '${selectedDate!.year}',
                                    style: TextStyle(
                                      color: selectedDate == null
                                          ? FqColors.muted
                                          : FqColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: FqColors.lavender,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insights_rounded,
                                color: FqColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CALCULATED BMI',
                                      style: TextStyle(
                                        color: FqColors.muted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      previewBmi == null
                                          ? 'Enter height & weight'
                                          : previewBmi.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: FqColors.ink,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (validationMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            validationMessage!,
                            style: const TextStyle(
                              color: FqColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saving ? null : save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FqColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              saving ? 'SAVING...' : 'SAVE HEALTH PROFILE',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      heightController.dispose();
      weightController.dispose();
    }
  }

  Widget _healthInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: FqColors.muted,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: FqColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7E8EE)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('always_login', false);
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}

// -----------------------------------------------------------------------------
// AVATAR CHARACTER COMPONENT
// -----------------------------------------------------------------------------

class _AvatarCharacter extends StatelessWidget {
  final String outfit;
  final int level;

  const _AvatarCharacter({
    required this.outfit,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final outfitColor = outfit == 'cricket'
        ? const Color(0xFFF2F7FF)
        : outfit == 'football'
            ? const Color(0xFF2F72D6)
            : outfit == 'running'
                ? const Color(0xFFFF7043)
                : const Color(0xFF3C79E8);

    final accent =
        outfit == 'cricket' ? const Color(0xFF2F72D6) : FqColors.accent;

    return SizedBox(
      width: 86,
      height: 122,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1B8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -3,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 19,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B2C24),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 23,
                    left: 12,
                    child: SizedBox(
                      width: 6,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: FqColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 23,
                    right: 12,
                    child: SizedBox(
                      width: 6,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: FqColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 17,
                    child: Container(
                      width: 14,
                      height: 5,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFD66A5C),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 47,
            child: Container(
              width: 58,
              height: 49,
              decoration: BoxDecoration(
                color: outfitColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: FqColors.primary,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 57,
            left: 3,
            child: Container(
              width: 13,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1B8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 57,
            right: 3,
            child: Container(
              width: 13,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1B8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 20,
            child: Container(
              width: 17,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF242A40),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 20,
            child: Container(
              width: 17,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF242A40),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 14,
            child: Container(
              width: 28,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF171B2E),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 14,
            child: Container(
              width: 28,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF171B2E),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (level >= 5)
            const Positioned(
              top: 0,
              right: 7,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: FqColors.accent,
                size: 17,
              ),
            ),
        ],
      ),
    );
  }
}