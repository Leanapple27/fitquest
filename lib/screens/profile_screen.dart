import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import 'rewards_screen.dart';
import 'privacy_safety_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileName = 'Student';
  String schoolId = '';
  String house = 'Phoenix';

  int xp = 0;
  int streak = 0;
  int badges = 0;
  int stickers = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

          loading = false;
        });
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
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
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
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },
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
    );
  }

  Widget _buildProfileHeader() {
    final level = (xp ~/ 250) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF302B63),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                '🧙',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            loading ? 'LOADING...' : profileName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
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

          const SizedBox(height: 4),

          Text(
            schoolId.isEmpty
                ? 'School ID not set'
                : schoolId,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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
          child: Column(children: children),
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
}
