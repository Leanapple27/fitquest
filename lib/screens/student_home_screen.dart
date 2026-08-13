import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import 'quests_screen.dart';
import 'profile_screen.dart';
import 'fitmap_screen.dart';
import 'community_screen.dart';
import 'quiz_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int selectedIndex = 0;

  // Shared FitQuest state.
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
        if (selectedIndex == 3) {
          return Scaffold(
            body: CommunityScreen(
  appState: appState,
),
            bottomNavigationBar: _buildBottomNavigation(),
          );
        }

        if (selectedIndex == 2) {
          return Scaffold(
            body: FitMapScreen(
  appState: appState,
),
            bottomNavigationBar: _buildBottomNavigation(),
          );
        }

        if (selectedIndex == 4) {
          return Scaffold(
            body: ProfileScreen(
              appState: appState,
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          );
        }

        if (selectedIndex == 1) {
          return Scaffold(
            body: QuestsScreen(
              appState: appState,
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 20),

                        _buildStreakCard(),

                        const SizedBox(height: 18),

                        _buildPlayerCard(),

                        const SizedBox(height: 18),

                      _buildQuestCard(),

const SizedBox(height: 18),

_buildQuizCard(),

const SizedBox(height: 18),

_buildQuickStats(),
                      ],
                    ),
                  ),
                ),

                _buildBottomNavigation(),
              ],
            ),
          ),
        );
      },
    );
  }

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
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF151B3D),
          ),
        ),
      ],
    );
  }

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
                color:
                    Colors.white.withValues(alpha: 0.18),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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

  Widget _buildPlayerCard() {
    final int currentXp = appState.xp;

    final int level =
        (currentXp ~/ 250) + 1;

    final int currentLevelStart =
        (level - 1) * 250;

    final int nextLevelXp =
        level * 250;

    final int levelRange =
        nextLevelXp - currentLevelStart;

    final int xpIntoLevel =
        currentXp - currentLevelStart;

    final double progress =
        levelRange <= 0
            ? 1.0
            : (xpIntoLevel / levelRange)
                .clamp(0.0, 1.0);

    final int xpRemaining =
        nextLevelXp > currentXp
            ? nextLevelXp - currentXp
            : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF302B63),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🧙',
                    style: TextStyle(fontSize: 43),
                  ),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
              Text(
                '⭐ $currentXp XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                '$nextLevelXp XP',
                style: TextStyle(
                  color:
                      Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD166),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              xpRemaining > 0
                  ? '$xpRemaining XP to Level ${level + 1}'
                  : 'Level up ready! 🎉',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            color:
                Colors.black.withValues(alpha: 0.05),
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
                padding:
                    const EdgeInsets.symmetric(
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
                      ? '✅ QUEST COMPLETE'
                      : '⚔️ TODAY\'S QUEST',
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
                    ? 'QUEST COMPLETED ✓'
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

        const SizedBox(width: 8),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
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

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () {
              setState(() {
                selectedIndex = 0;
              });
            },
          ),

          _NavItem(
            icon: Icons.flash_on_rounded,
            label: 'Quests',
            selected: selectedIndex == 1,
            onTap: () {
              setState(() {
                selectedIndex = 1;
              });
            },
          ),

          _NavItem(
            icon: Icons.map_rounded,
            label: 'FitMap',
            selected: selectedIndex == 2,
            onTap: () {
              setState(() {
                selectedIndex = 2;
              });
            },
          ),

          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'Community',
            selected: selectedIndex == 3,
            onTap: () {
              setState(() {
                selectedIndex = 3;
              });
            },
          ),

          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: selectedIndex == 4,
            onTap: () {
              setState(() {
                selectedIndex = 4;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? const Color(0xFF302B63)
                  : Colors.black38,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: selected
                    ? const Color(0xFF302B63)
                    : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}