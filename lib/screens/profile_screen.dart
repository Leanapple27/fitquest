import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import 'rewards_screen.dart';
import 'privacy_safety_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
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

        final incomingXp = userXp is num ? userXp.toInt() : xp;
        final incomingLevel = (incomingXp ~/ 250) + 1;

        final storedLastSeenLevel =
            data['lastSeenLevel'] is num
                ? (data['lastSeenLevel'] as num).toInt()
                : null;

        final previousLevel =
            storedLastSeenLevel ?? _lastKnownLevel;

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

          loading = false;
          _lastKnownLevel = incomingLevel;
        });

        final shouldCelebrate =
            previousLevel != null &&
            incomingLevel > previousLevel;

        // Remember the level already seen so the celebration is shown once.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProfile,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                _buildProfileHeader(),

                const SizedBox(height: 18),

                _buildStats(),

                const SizedBox(height: 18),

                _buildSection(
                  title: 'REWARDS',
                  children: [
                    _buildMenuItem(
                      icon: '🏆',
                      title: 'Badges',
                      subtitle: '$badges badges earned',
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
                      icon: '🎟️',
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
                      icon: '🏠',
                      title: '$house House',
                      subtitle: 'Your school house',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildSection(
                  title: 'PRIVACY & SAFETY',
                  children: [
                    _buildMenuItem(
                      icon: '🛡️',
                      title: 'Privacy',
                      subtitle: 'Control what others can see',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PrivacySafetyScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: '🔒',
                      title: 'Safety Centre',
                      subtitle: 'Learn how FitQuest keeps you safe',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PrivacySafetyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildSection(
                  title: 'ACCOUNT',
                  children: [
                    _buildMenuItem(
                      icon: '🏫',
                      title: 'School Account',
                      subtitle: schoolId.isEmpty
                          ? 'School ID not set'
                          : schoolId,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: '⚙️',
                      title: 'Settings',
                      subtitle: 'App preferences',
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

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD94B4B),
                      side: const BorderSide(
                        color: Color(0xFFD94B4B),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
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

  Widget _buildLevelUpOverlay() {
    final level = _lastKnownLevel ?? 1;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.70),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Expanding glow behind the celebration.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Container(
                  width: 180 + (170 * value),
                  height: 180 + (170 * value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD166)
                        .withValues(alpha: 0.04 * (1 - value)),
                    border: Border.all(
                      color: const Color(0xFFFFD166)
                          .withValues(alpha: 0.24 * (1 - value)),
                      width: 2,
                    ),
                  ),
                );
              },
            ),

            // Sparkles around the reward card.
            ...List.generate(8, (index) {
              final angles = <double>[
                -2.8, -2.15, -1.45, -0.65,
                0.05, 0.75, 1.55, 2.35,
              ];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 550 + (index * 55)),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  final distance = 135.0 * value;
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angles[index]) * distance,
                      math.sin(angles[index]) * distance,
                    ),
                    child: Opacity(
                      opacity: (1.0 - value * 0.55).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.4 + (0.8 * value),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Icon(
                  index.isEven
                      ? Icons.auto_awesome_rounded
                      : Icons.star_rounded,
                  color: index.isEven
                      ? const Color(0xFFFFD166)
                      : Colors.white,
                  size: index.isEven ? 22 : 15,
                ),
              );
            }),

            // Main celebration card.
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
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFD166),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD166)
                          .withValues(alpha: 0.30),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            -18 * math.sin(value * math.pi),
                          ),
                          child: Transform.scale(
                            scale: 0.65 + (0.35 * value),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDEBFF),
                          border: Border.all(
                            color: const Color(0xFFFFD166),
                            width: 5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🏆',
                            style: TextStyle(fontSize: 53),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'LEVEL UP!',
                      style: TextStyle(
                        color: Color(0xFF302B63),
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'LEVEL $level',
                      style: const TextStyle(
                        color: Color(0xFFFF8A3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F6FF),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NEW REWARD',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _levelUpReward,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF151B3D),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 17),

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
                              foregroundColor: const Color(0xFF302B63),
                              side: const BorderSide(
                                color: Color(0xFF302B63),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'LATER',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              await _equipLevelReward();
                              if (!mounted) return;
                              setState(() {
                                _showLevelUp = false;
                                _avatarCelebrating = false;
                              });
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF302B63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'EQUIP NOW',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
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

  Widget _buildProfileHeader() {
    final level = (xp ~/ 250) + 1;
    final levelStart = (level - 1) * 250;
    final nextLevel = level * 250;
    final progress = ((xp - levelStart) / (nextLevel - levelStart))
        .clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF302B63),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF302B63).withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR FITNESS JOURNEY',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loading
                            ? 'LOADING...'
                            : profileName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Level $level • Fitness Explorer',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _levelBadge(level),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildAnimatedAvatar(
                    level: level,
                    size: 150,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _avatarMiniStat(
                        Icons.local_fire_department_rounded,
                        '$streak',
                        'DAY STREAK',
                      ),
                      const SizedBox(height: 9),
                      _avatarMiniStat(
                        Icons.bolt_rounded,
                        '$xp XP',
                        'TOTAL XP',
                      ),
                      const SizedBox(height: 9),
                      _avatarMiniStat(
                        Icons.emoji_events_rounded,
                        '$badges',
                        'BADGES',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '$xp / $nextLevel XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  progress >= 1
                      ? 'LEVEL UP!'
                      : '${(nextLevel - xp).clamp(0, nextLevel)} XP TO GO',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 9,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD166),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    showAvatarEditor = !showAvatarEditor;
                  });
                },
                icon: Icon(
                  showAvatarEditor
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.auto_awesome_rounded,
                ),
                label: Text(
                  showAvatarEditor
                      ? 'CLOSE AVATAR'
                      : 'CUSTOMIZE AVATAR',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF302B63),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _buildAvatarEditor(level),
              ),
              crossFadeState: showAvatarEditor
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOutCubic,
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showAvatarCollection,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      color: Color(0xFFFFD166),
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'MY AVATAR COLLECTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white54,
                      size: 20,
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

  Widget _levelBadge(int level) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD166),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD166).withValues(alpha: 0.25),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          'LV $level',
          style: const TextStyle(
            color: Color(0xFF302B63),
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _avatarMiniStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: const Color(0xFFFFD166),
          ),
        ),
        const SizedBox(width: 8),
        Column(
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
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedAvatar({
    required int level,
    required double size,
  }) {
    final frameColor = selectedFrame == 'gold'
        ? const Color(0xFFFFD166)
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
                    width: selectedFrame == 'gold' ? 8 : 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: frameColor.withValues(alpha: 0.28),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),

            Positioned(
              bottom: 4,
              child: Container(
                width: size * 0.58,
                height: 12,
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

            if (_avatarCelebrating)
              Positioned(
                top: 2,
                right: 4,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD166),
                    size: 24,
                  ),
                ),
              ),

            if (selectedBanner == 'fitness')
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'FITNESS EXPLORER',
                    style: TextStyle(
                      color: Color(0xFF302B63),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: avatarTab == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: avatarTab == index
                            ? const Color(0xFF302B63)
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
      ('fitness', 'Fitness Explorer', 1, Icons.local_fire_department_rounded),
      ('streak', 'Streak', 3, Icons.bolt_rounded),
      ('quest', 'Quest Master', 5, Icons.emoji_events_rounded),
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
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEDEBFF)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD166)
                    : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: locked
                            ? Colors.white30
                            : isSelected
                                ? const Color(0xFF302B63)
                                : Colors.white70,
                        size: 23,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: locked
                              ? Colors.white30
                              : Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locked ? 'LV $unlockLevel' : 'UNLOCKED',
                        style: TextStyle(
                          color: locked
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF7DE2A8),
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  const Positioned(
                    right: 2,
                    top: 2,
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white54,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAvatarSelection({
    String? outfit,
    String? frame,
    String? banner,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final updates = <String, dynamic>{};

      if (outfit != null) {
        updates['avatarOutfit'] = outfit;
      }
      if (frame != null) {
        updates['avatarFrame'] = frame;
      }
      if (banner != null) {
        updates['avatarBanner'] = banner;
      }

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(
          updates,
          SetOptions(merge: true),
        );
      }
    } catch (_) {
      // Keep the UI responsive even if saving is temporarily unavailable.
    }
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

  void _showAvatarCollection() {
    final level = (xp ~/ 250) + 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Text(
                      'MY COLLECTION',
                      style: TextStyle(
                        color: Color(0xFF151B3D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFB82E),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _collectionSection(
                  title: 'OUTFITS',
                  items: [
                    ('FitQuest', 'default', 1, Icons.sports),
                    ('Runner', 'running', 2, Icons.directions_run_rounded),
                    ('Cricket', 'cricket', 3, Icons.sports_cricket_rounded),
                    ('Football', 'football', 4, Icons.sports_soccer_rounded),
                  ],
                  selected: selectedOutfit,
                  level: level,
                ),
                const SizedBox(height: 12),
                _collectionSection(
                  title: 'FRAMES',
                  items: [
                    ('None', 'none', 1, Icons.circle_outlined),
                    ('Bronze', 'bronze', 2, Icons.circle),
                    ('Silver', 'silver', 3, Icons.circle),
                    ('Gold', 'gold', 5, Icons.auto_awesome_rounded),
                  ],
                  selected: selectedFrame,
                  level: level,
                ),
                const SizedBox(height: 12),
                _collectionSection(
                  title: 'BANNERS',
                  items: [
                    ('Fitness', 'fitness', 1, Icons.local_fire_department_rounded),
                    ('Streak', 'streak', 3, Icons.bolt_rounded),
                    ('Quest Master', 'quest', 5, Icons.emoji_events_rounded),
                  ],
                  selected: selectedBanner,
                  level: level,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _collectionSection({
    required String title,
    required List<(String, String, int, IconData)> items,
    required String selected,
    required int level,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final unlocked = level >= item.$3;
              final equipped = selected == item.$2;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 88,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: equipped ? const Color(0xFFEDEBFF) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: equipped
                        ? const Color(0xFFFFD166)
                        : Colors.black.withValues(alpha: 0.05),
                    width: equipped ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$4,
                      size: 22,
                      color: unlocked
                          ? const Color(0xFF302B63)
                          : Colors.black26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked
                            ? const Color(0xFF151B3D)
                            : Colors.black38,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      equipped
                          ? 'EQUIPPED'
                          : unlocked
                              ? 'UNLOCKED'
                              : 'LV ${item.$3}',
                      style: TextStyle(
                        color: equipped
                            ? const Color(0xFF27733A)
                            : unlocked
                                ? const Color(0xFF302B63)
                                : Colors.black26,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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

    if (outfit != null) {
      setState(() {
        selectedOutfit = outfit!;
      });
    }

    if (frame != null) {
      setState(() {
        selectedFrame = frame!;
      });
    }

    if (banner != null) {
      setState(() {
        selectedBanner = banner!;
      });
    }

    await _saveAvatarSelection(
      outfit: outfit,
      frame: frame,
      banner: banner,
    );
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

  // ============================================================
  // PROFILE AVATAR
  // ============================================================


  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            '⭐',
            '$xp',
            'XP',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _statCard(
            '🔥',
            '$streak',
            'Day Streak',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _statCard(
            '🏆',
            '$badges',
            'Badges',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 22),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.black45,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEBFF),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 21),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF151B3D),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black45,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.black26,
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}

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

    final accent = outfit == 'cricket'
        ? const Color(0xFF2F72D6)
        : const Color(0xFFFFD166);

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
                          color: Color(0xFF302B63),
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
                          color: Color(0xFF302B63),
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
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFD66A5C),
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
                    color: Color(0xFF302B63),
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
            Positioned(
              top: 0,
              right: 7,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: const Color(0xFFFFD166),
                size: 17,
              ),
            ),
        ],
      ),
    );
  }
}
