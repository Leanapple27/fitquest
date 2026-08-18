import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../clan_service.dart';
import '../theme/fq_colors.dart';
import '../theme/fq_radii.dart';
import '../theme/fq_spacing.dart';
import '../theme/fq_typography.dart';
import 'leaderboard_screen.dart';
import 'leagues_screen.dart';
import 'shop_screen.dart';

class CommunityScreen extends StatefulWidget {
  final AppState appState;

  const CommunityScreen({
    super.key,
    required this.appState,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const List<Map<String, dynamic>> _demoMembers = [
    {
      'id': 'demo_arjun',
      'name': 'Arjun',
      'emoji': '🏃',
      'role': 'member',
      'weeklyXp': 210,
    },
    {
      'id': 'demo_maya',
      'name': 'Maya',
      'emoji': '🧘',
      'role': 'member',
      'weeklyXp': 165,
    },
    {
      'id': 'demo_kabir',
      'name': 'Kabir',
      'emoji': '🏋️',
      'role': 'member',
      'weeklyXp': 120,
    },
  ];

  final ClanService _clanService = ClanService();
  String? _selectedClanId;
  int _activeSegment = 0; // 0: Discover, 1: My Clan, 2: How It Works
  final TextEditingController _searchCommunityController = TextEditingController();
  String _selectedHouseFilter = 'ALL';

  @override
  void dispose() {
    _searchCommunityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedClanId != null) {
      return _ClanScreen(
        appState: widget.appState,
        clanService: _clanService,
        clanId: _selectedClanId!,
        onBack: () => setState(() => _selectedClanId = null),
      );
    }

    return Scaffold(
      backgroundColor: FqColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LeaguesScreen(appState: widget.appState),
                ),
              );
            },
            icon: const Text('🏆', style: TextStyle(fontSize: 20)),
            tooltip: 'Weekly Leagues',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(
                    currentUserXp: widget.appState.xp,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFF302B63), size: 22),
            tooltip: 'House Leaderboard',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _clanService.streamDiscoverClans(),
          builder: (context, snapshot) {
            final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
              ...(snapshot.data?.docs ?? []),
            ];

            docs.sort((a, b) {
              final aXp = a.data()['weeklyXp'] is num
                  ? (a.data()['weeklyXp'] as num).toInt()
                  : 0;
              final bXp = b.data()['weeklyXp'] is num
                  ? (b.data()['weeklyXp'] as num).toInt()
                  : 0;
              return bXp.compareTo(aXp);
            });

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 16),
                _buildSegmentedControl(),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
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
                          begin: const Offset(0.02, 0),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_activeSegment),
                    child: _activeSegment == 0
                        ? _buildDiscoverSection(snapshot, docs)
                        : _activeSegment == 1
                            ? _buildMyClanSection(docs)
                            : _activeSegment == 2
                                ? _buildLeaguesTabSection()
                                : _buildHowItWorksSection(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151B3D), Color(0xFF302B63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF151B3D).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: const Center(child: Text('🏟️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAMPUS COMMUNITIES',
                  style: TextStyle(
                    color: Color(0xFF00F5D4),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Team Up & Compete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Join your sports squad to earn weekly XP together.',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _createClan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5D4),
              foregroundColor: const Color(0xFF151B3D),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text(
              'Create',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEGMENTED CONTROL
  // ---------------------------------------------------------------------------

  Widget _buildSegmentedControl() {
    final segments = [
      {'label': 'Squads', 'icon': Icons.explore_rounded},
      {'label': 'My Hub', 'icon': Icons.shield_rounded},
      {'label': 'Leagues', 'icon': Icons.military_tech_rounded},
      {'label': 'Fair Play', 'icon': Icons.gavel_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _activeSegment == index;
          final item = segments[index];

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeSegment = index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF302B63) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF302B63).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 14,
                        color: isSelected ? const Color(0xFF00F5D4) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
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
  // DISCOVER SECTION
  // ---------------------------------------------------------------------------

  Widget _buildDiscoverSection(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (snapshot.hasError) {
      return _firestoreError(snapshot.error);
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(35),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _emptyClans();
  }

  Widget _buildLeaguesTabSection() {
    return Column(
      children: [
        // Main League Division Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF302B63).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🥇', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEEKLY DIVISION',
                            style: TextStyle(
                              color: Color(0xFF00F5D4),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Gold League #4',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rank #2 ⚡',
                      style: TextStyle(
                        color: Color(0xFF00F5D4),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Top 3 students promote to Diamond League on Sunday midnight! Keep logging verified workouts to defend your promotion spot.',
                style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LeaguesScreen(appState: widget.appState),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F5D4),
                        foregroundColor: const Color(0xFF0F0C29),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'VIEW BRACKET & REWARDS ⚡',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // League Rules Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text('🟢', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text('Top 3: Promote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                ],
              ),
              Row(
                children: [
                  Text('⚪', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text('4-12: Safe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  Text('🔴', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text('Bottom 3: Demote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MY CLAN SECTION
  // ---------------------------------------------------------------------------

  Widget _buildMyClanSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      return _emptyClans();
    }

    final topClan = docs.first;
    final data = topClan.data();
    final name = data['name']?.toString() ?? 'Featured Clan';
    final emoji = data['emoji']?.toString() ?? '🛡️';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7E8EE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                      color: FqColors.lavender,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: FqColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Your Active Fitness Clan',
                          style: TextStyle(
                            color: Color(0xFF747887),
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
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _clanStatMini('4', 'Quests Done'),
                  _clanStatMini('+340', 'XP Today'),
                  _clanStatMini('Rank #1', 'War Status'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _joinClan(topClan.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FqColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.meeting_room_rounded, size: 18),
                  label: const Text(
                    'ENTER CLAN HQ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _clanStatMini(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: FqColors.ink,
            fontSize: 14,
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

  Widget _buildHowItWorksSection() {
    final rules = [
      {
        'emoji': '⚖️',
        'badge': 'ANTI-CHEAT & INTEGRITY',
        'title': 'AI Motion Vision & GPS Validation',
        'desc': 'All pushups, squats, and jumping jacks are verified through on-device camera pose detection. Step cadences and GPS routes are validated by sensor fusion. Fake/spoofed movement is flagged and results in 0 XP and temporary league disqualification.',
        'color': const Color(0xFFEF4444),
      },
      {
        'emoji': '🤝',
        'badge': 'CODE OF CONDUCT',
        'title': 'Respect, Camaraderie & Positive Encouragement',
        'desc': 'FitQuest is built on mutual support. Chat harassment, derogatory speech, or toxic rivalry will result in immediate squad ban and house penalty points. Cheer your classmates on!',
        'color': const Color(0xFF3B82F6),
      },
      {
        'emoji': '🏆',
        'badge': 'LEAGUE PROGRESSION',
        'title': 'Weekly Promotion & Demotion Brackets',
        'desc': 'Every weekly season runs from Monday 00:00 to Sunday 23:59 IST. Communities compete within their division bracket. The Top 3 squads advance to higher divisions, unlocking up to 2.0x XP multipliers, while bottom 3 demote.',
        'color': const Color(0xFFF59E0B),
      },
      {
        'emoji': '⚡',
        'badge': 'SQUAD MULTIPLIERS',
        'title': 'Division Tiers & Perks',
        'desc': '🥉 Bronze (LV 1–3, 1.0x Base XP)\n🥈 Silver (LV 4–5, 1.1x XP)\n🥇 Gold (LV 6–7, 1.25x XP)\n💎 Platinum (LV 8–9, 1.5x XP)\n👑 Champion (LV 10, 2.0x XP + Exclusive Animated Stickers)',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'emoji': '⚔️',
        'badge': 'COMMUNITY WARS',
        'title': 'Weekend Head-to-Head Squad Battles',
        'desc': 'On weekends, matched sports communities duel for bonus house trophies. Every completed activity, quiz answer, and workout rep counts toward your squad victory score.',
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMMUNITY RULES & LEAGUE SYSTEM',
              style: FqTypography.sectionLabel(color: FqColors.muted),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF302B63),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'OFFICIAL RULES',
                style: TextStyle(color: Color(0xFF00F5D4), fontSize: 8.5, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rules.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (r['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(r['emoji'] as String, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (r['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                r['badge'] as String,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: r['color'] as Color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r['title'] as String,
                              style: const TextStyle(
                                color: Color(0xFF151B3D),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    r['desc'] as String,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _firestoreError(Object? error) {
    return Container(
      padding: const EdgeInsets.all(FqSpacing.card),
      decoration: BoxDecoration(
        color: FqColors.dangerSurface,
        borderRadius: FqRadii.cardBorder,
      ),
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 7),
          const Text(
            'Could not load public clans',
            style: TextStyle(
              color: FqColors.danger,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            error?.toString() ?? 'Unknown Firestore error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyClans() {
    final allCommunities = [
      {
        'id': 'comm_football',
        'name': 'Football Strikers Club',
        'emoji': '⚽',
        'sport': 'Football & Sprint Drills',
        'house': 'IGNIS',
        'houseLabel': 'Ignis 🔥',
        'members': 30,
        'level': 6,
        'weeklyXp': 3420,
        'desc': 'Campus football squad training daily for the Inter-School Cup!',
      },
      {
        'id': 'comm_basketball',
        'name': 'Hoops & Dunks Crew',
        'emoji': '🏀',
        'sport': 'Basketball & Stamina',
        'house': 'AQUA',
        'houseLabel': 'Aqua 🌊',
        'members': 20,
        'level': 8,
        'weeklyXp': 4180,
        'desc': 'Basketball enthusiasts mastering layups, fast-breaks & endurance.',
      },
      {
        'id': 'comm_volleyball',
        'name': 'Volleyball Spikers',
        'emoji': '🏐',
        'sport': 'Volleyball & Reflexes',
        'house': 'TERRA',
        'houseLabel': 'Terra 🌿',
        'members': 15,
        'level': 4,
        'weeklyXp': 2150,
        'desc': 'Spiking hard, setting high, and staying fit together!',
      },
      {
        'id': 'comm_badminton',
        'name': 'Campus Badminton Aces',
        'emoji': '🏸',
        'sport': 'Badminton & Agility',
        'house': 'VAYU',
        'houseLabel': 'Vayu 🌪️',
        'members': 18,
        'level': 5,
        'weeklyXp': 2890,
        'desc': 'Smashing shuttles, agility footwork drills & doubles tournaments!',
      },
      {
        'id': 'comm_track',
        'name': 'Track & Field Sprinters',
        'emoji': '🏃',
        'sport': 'Athletics & 100m Dash',
        'house': 'IGNIS',
        'houseLabel': 'Ignis 🔥',
        'members': 25,
        'level': 7,
        'weeklyXp': 3650,
        'desc': 'Speed training, relay handoffs, and campus 5K endurance pacing.',
      },
    ];

    final query = _searchCommunityController.text.trim().toLowerCase();
    final filtered = allCommunities.where((c) {
      final matchesSearch = query.isEmpty ||
          (c['name'] as String).toLowerCase().contains(query) ||
          (c['sport'] as String).toLowerCase().contains(query);
      final matchesHouse = _selectedHouseFilter == 'ALL' || c['house'] == _selectedHouseFilter;
      return matchesSearch && matchesHouse;
    }).toList();

    final houses = [
      {'key': 'ALL', 'label': 'All Houses 🏛️'},
      {'key': 'IGNIS', 'label': 'Ignis 🔥'},
      {'key': 'AQUA', 'label': 'Aqua 🌊'},
      {'key': 'TERRA', 'label': 'Terra 🌿'},
      {'key': 'VAYU', 'label': 'Vayu 🌪️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCommunityController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search by community name or sport...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchCommunityController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchCommunityController.clear();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),

        // 2. House Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: houses.map((h) {
              final isSel = _selectedHouseFilter == h['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 12),
                child: ChoiceChip(
                  label: Text(
                    h['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF302B63),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSel ? const Color(0xFF302B63) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedHouseFilter = h['key']!),
                ),
              );
            }).toList(),
          ),
        ),

        // 3. Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CAMPUS SPORTS COMMUNITIES',
              style: FqTypography.sectionLabel(color: FqColors.muted),
            ),
            Text(
              '${filtered.length} Squads Found',
              style: const TextStyle(
                color: FqColors.primaryMid,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE7E8EE)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Text('🔍', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text(
                    'No communities found',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF151B3D)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try adjusting your search query or house filter.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    // 1. Header: Emblem + Name + House Tag + Level Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(c['emoji'] as String, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['name'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF151B3D),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF302B63),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      c['houseLabel'] as String,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF00F5D4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${c['sport']}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'LV ${c['level']}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2. Description
                    Text(
                      c['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    // 3. Stats Bar & Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              '${c['members']} Athletes',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                        Text(
                          '+${c['weeklyXp']} Weekly XP',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ((c['level'] as int) / 10).toDouble(),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF302B63)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Full-Width Clean Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedClanId = c['id'] as String;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF302B63),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.shield_rounded, size: 16),
                        label: Text(
                          'VIEW SQUAD HUB (${c['members']} ATHLETES)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CREATE CLAN MODAL
  // ---------------------------------------------------------------------------

  Future<void> _createClan() async {
    final controller = TextEditingController();
    String emoji = '🛡️';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FqColors.lavender,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Create Clan',
                    style: TextStyle(
                      color: FqColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose an Emblem:',
                    style: TextStyle(
                      color: Color(0xFF747887),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['🛡️', '🏏', '🏋️', '🏃', '🧘', '⚽', '🔥', '⚡']
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item, style: const TextStyle(fontSize: 18)),
                            selected: emoji == item,
                            selectedColor: FqColors.lavender,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: emoji == item
                                    ? FqColors.primary
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            onSelected: (_) {
                              setDialogState(() => emoji = item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: 'Clan Name',
                      hintText: 'e.g. Riverside Sprinters',
                      filled: true,
                      fillColor: FqColors.scaffold,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    try {
                      final id = await _clanService.createClan(
                        name: controller.text,
                        emoji: emoji,
                      );
                      if (context.mounted) {
                        Navigator.pop(context, id != null);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context, false);
                        _showError(e.toString());
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FqColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('CREATE'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clan created successfully!')),
      );
    }
  }

  Future<void> _joinClan(String clanId) async {
    try {
      await _clanService.joinClan(clanId);
      if (mounted) {
        setState(() => _selectedClanId = clanId);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
    );
  }
}

// -----------------------------------------------------------------------------
// CLAN SCREEN (CHAT, MEMBERS, WAR)
// -----------------------------------------------------------------------------

class _ClanScreen extends StatefulWidget {
  final AppState appState;
  final ClanService clanService;
  final String clanId;
  final VoidCallback onBack;

  const _ClanScreen({
    required this.appState,
    required this.clanService,
    required this.clanId,
    required this.onBack,
  });

  @override
  State<_ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<_ClanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  bool _isMember = false;
  bool _isPending = false;

  final List<Map<String, dynamic>> _demoMembers = const [
    {
      'name': 'Arjun',
      'role': 'demo',
      'weeklyXp': 210,
      'emoji': '🏃',
    },
    {
      'name': 'Maya',
      'role': 'demo',
      'weeklyXp': 165,
      'emoji': '🧘',
    },
    {
      'name': 'Kabir',
      'role': 'demo',
      'weeklyXp': 120,
      'emoji': '🏋️',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.clanId == 'comm_football') {
      _isMember = true;
    }
  }

  void _showJoinRequestDialog(String squadName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text('📨', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              Text(
                'Request to Join $squadName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your application will be sent directly to the Community Captain for roster verification and approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _isPending = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Join request sent to Community Captain! ⏳'),
                        backgroundColor: Color(0xFF302B63),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: const Color(0xFF00F5D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('SEND JOIN REQUEST 📨', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _isMember = true;
                      _isPending = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('👑 Captain approved your request! Welcome to the squad!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.verified_user_rounded, size: 16),
                  label: const Text('(DEMO) INSTANT CAPTAIN APPROVE ✓', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  int _demoWarPoints() {
    return _demoMembers.fold<int>(
      0,
      (total, member) => total + (member['weeklyXp'] as int),
    );
  }

  int _myWarPoints() {
    final state = widget.appState;
    int points = state.weeklyFitnessActivities * 50;
    if (state.quizCompleted) points += 50;
    if (state.communityChallengeCompleted) points += 25;
    return points;
  }

  Future<void> _sendDemoReply(String userText) async {
    final text = userText.toLowerCase();
    String reply;
    String senderName;

    if (text.contains('hi') || text.contains('hello') || text.contains('hey')) {
      senderName = 'Arjun 🏃';
      reply = 'Hey! Welcome to the clan chat 👋 Ready for today\'s quest?';
    } else if (text.contains('war') || text.contains('challenge')) {
      senderName = 'Maya 🧘';
      reply = 'Clan War is on! 🔥 Every workout gives us points!';
    } else if (text.contains('workout') || text.contains('gym') || text.contains('run')) {
      senderName = 'Kabir 🏋️';
      reply = 'Awesome hustle! 💪 Let\'s push our clan to Rank #1!';
    } else {
      senderName = 'Maya 🧘';
      reply = 'Nice! 🙌 Every little win helps our clan level up.';
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));

    try {
      await FirebaseFirestore.instance
          .collection('clans')
          .doc(widget.clanId)
          .collection('messages')
          .add({
        'senderId': 'demo_$senderName',
        'senderName': senderName,
        'text': reply,
        'isDemo': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Demo reply is optional
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> fallbackData = {};
    if (widget.clanId == 'comm_football') {
      fallbackData = {'name': 'Football Strikers Club', 'emoji': '⚽', 'weeklyXp': 3420};
    } else if (widget.clanId == 'comm_basketball') {
      fallbackData = {'name': 'Hoops & Dunks Crew', 'emoji': '🏀', 'weeklyXp': 4180};
    } else if (widget.clanId == 'comm_volleyball') {
      fallbackData = {'name': 'Volleyball Spikers', 'emoji': '🏐', 'weeklyXp': 2150};
    } else if (widget.clanId == 'comm_badminton') {
      fallbackData = {'name': 'Campus Badminton Aces', 'emoji': '🏸', 'weeklyXp': 2890};
    } else if (widget.clanId == 'comm_track') {
      fallbackData = {'name': 'Track & Field Sprinters', 'emoji': '🏃', 'weeklyXp': 3650};
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.clanService.streamClan(widget.clanId),
      builder: (context, clanSnapshot) {
        final data = clanSnapshot.data?.data() ?? fallbackData;
        final name = data['name']?.toString() ?? 'Community Hub';
        final emoji = data['emoji']?.toString() ?? '🛡️';
        final weeklyXp =
            data['weeklyXp'] is num ? (data['weeklyXp'] as num).toInt() : 0;

        return Scaffold(
          backgroundColor: FqColors.scaffold,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: FqColors.ink),
            ),
            title: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: FqTypography.screenTitle(color: FqColors.ink).copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _isMember
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👑', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'MEMBER',
                              style: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _showJoinRequestDialog(name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPending ? const Color(0xFFF59E0B) : const Color(0xFF302B63),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(_isPending ? Icons.hourglass_top_rounded : Icons.person_add_rounded, size: 14),
                        label: Text(
                          _isPending ? 'PENDING' : 'JOIN',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                      ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: FqColors.primary,
              unselectedLabelColor: const Color(0xFF747887),
              indicatorColor: FqColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'LIVE CHAT'),
                Tab(text: 'MEMBERS'),
                Tab(text: 'COMMUNITY WAR ⚔️'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Clan Quick Stats Header
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: widget.clanService.streamMembers(widget.clanId),
                builder: (context, memberSnapshot) {
                  final realMembers = memberSnapshot.data?.docs.length ?? 0;
                  final totalMembers = realMembers > 0
                      ? realMembers
                      : (widget.clanId == 'comm_football'
                          ? 30
                          : widget.clanId == 'comm_basketball'
                              ? 20
                              : widget.clanId == 'comm_volleyball'
                                  ? 15
                                  : widget.clanId == 'comm_track'
                                      ? 25
                                      : 18);

                  final realXp = memberSnapshot.data?.docs.fold<int>(
                        0,
                        (total, doc) {
                          final value = doc.data()['weeklyXp'];
                          return total + (value is num ? value.toInt() : 0);
                        },
                      ) ??
                      weeklyXp;

                  final totalXp = realXp > 0 ? realXp : weeklyXp;

                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE7E8EE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _clanStatHeader('👥', '$totalMembers', 'MEMBERS'),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFE7E8EE),
                        ),
                        _clanStatHeader('⚡', '$totalXp XP', 'WEEKLY SCORE'),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFE7E8EE),
                        ),
                        _clanStatHeader('⚔️', 'DIV 1', 'WAR TIER'),
                      ],
                    ),
                  );
                },
              ),

              // Tab Content Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChat(name),
                    _buildMembers(),
                    _buildWar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _clanStatHeader(String icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: FqColors.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF747887),
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE CHAT TAB
  // ---------------------------------------------------------------------------

  Widget _buildChat(String squadName) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: widget.clanService.streamMessages(widget.clanId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FqColors.lavender,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: FqColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No messages yet',
                        style: TextStyle(
                          color: FqColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Say hi to your teammates below! 💬',
                        style: TextStyle(
                          color: Color(0xFF747887),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final senderId = data['senderId']?.toString() ?? '';
                  final senderName = data['senderName']?.toString() ?? 'Student';
                  final text = data['text']?.toString() ?? '';
                  final isMe = senderId == FirebaseAuth.instance.currentUser?.uid;
                  final isDemo = data['isDemo'] == true;

                  final timestamp = data['createdAt'];
                  final time = timestamp is Timestamp
                      ? _formatTime(timestamp.toDate())
                      : '';

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: isMe ? FqColors.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  senderName,
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : FqColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (isDemo) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FqColors.lavender,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'BOT',
                                      style: TextStyle(
                                        color: FqColors.primary,
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          if (!isMe) const SizedBox(height: 3),
                          if (data['stickerAsset'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 95,
                                height: 95,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  data['stickerAsset'].toString(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Text('🏷️', style: TextStyle(fontSize: 32)),
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe ? Colors.white : FqColors.ink,
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isMe ? Colors.white60 : Colors.black38,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Chat Input Bar or Locked Access Banner
        if (!_isMember)
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF334155)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.lock_rounded, color: Color(0xFF00F5D4), size: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JOIN COMMUNITY TO ACCESS CHAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isPending
                              ? 'Application pending Captain approval ⏳'
                              : 'Request to join this squad to chat and send stickers.',
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showJoinRequestDialog(squadName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPending ? const Color(0xFFF59E0B) : const Color(0xFF00F5D4),
                      foregroundColor: const Color(0xFF151B3D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _isPending ? 'PENDING' : 'JOIN 📨',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sticker Tray Button
                  IconButton(
                    tooltip: 'Stickers',
                    onPressed: _showStickerTray,
                    icon: const Icon(
                      Icons.sticky_note_2_outlined,
                      color: Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 500,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(
                        color: FqColors.ink,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message your community...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8B8E99),
                          fontSize: 12.5,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: FqColors.scaffold,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF302B63),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Send Message',
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
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

  void _showStickerTray() {
    final List<Map<String, String>> shopStickers = [
      {'id': 'sticker_shocked_anim', 'asset': 'assets/stickers/animated sticker 1.webp', 'name': 'Shocked Anime'},
      {'id': 'sticker_energetic_1', 'asset': 'assets/stickers/19e47b09-b3bb-47a6-a92a-fa94b8edc160.webp', 'name': 'Energetic'},
      {'id': 'sticker_cheer_2', 'asset': 'assets/stickers/a0575e8a-f7c5-4791-83e6-47891e76834a.webp', 'name': 'Victory Cheer'},
      {'id': 'sticker_fighter_3', 'asset': 'assets/stickers/b43e3c2f-d2a4-4e80-9b4a-ffc12274e847.webp', 'name': 'Fighter'},
      {'id': 'sticker_champ_4', 'asset': 'assets/stickers/f081235a-f4bd-4540-9cc1-1f5196ab87d1.webp', 'name': 'Power Champ'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final unlockedList = shopStickers.where(
            (s) => widget.appState.unlockedStickers.contains(s['id']),
          ).toList();

          return Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Community Stickers',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF151B3D)),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopScreen(appState: widget.appState),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF302B63)),
                      label: const Text('SHOP 🛒', style: TextStyle(color: Color(0xFF302B63), fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (unlockedList.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏷️', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          const Text(
                            'No stickers unlocked yet!',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF151B3D)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Buy animated and custom stickers from the Shop with your FitCoins.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShopScreen(appState: widget.appState),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF302B63),
                              foregroundColor: const Color(0xFF00F5D4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('VISIT SHOP 🛍️', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: unlockedList.length,
                      itemBuilder: (context, index) {
                        final item = unlockedList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _sendStickerMessage(item['asset']!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              item['asset']!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('🏷️', style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendStickerMessage(String assetPath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? 'Student';

      await FirebaseFirestore.instance
          .collection('clans')
          .doc(widget.clanId)
          .collection('messages')
          .add({
        'senderId': user?.uid ?? 'guest',
        'senderName': userName,
        'stickerAsset': assetPath,
        'text': '[Sticker]',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send sticker: $e')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // MEMBERS TAB
  // ---------------------------------------------------------------------------

  Widget _buildMembers() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.clanService.streamMembers(widget.clanId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final memberList = <Map<String, dynamic>>[];

        if (docs.isNotEmpty) {
          for (final doc in docs) {
            final data = doc.data();
            final name = data['name']?.toString() ?? 'Student';
            final role = data['role']?.toString() ?? 'member';
            final xp = data['weeklyXp'] is num ? (data['weeklyXp'] as num).toInt() : 0;
            final emoji = role == 'owner' ? '👑' : role == 'admin' ? '🛡️' : '🏃';

            memberList.add({
              'name': name,
              'role': role.toUpperCase(),
              'xp': xp,
              'emoji': emoji,
              'isDemo': false,
            });
          }
        } else if (widget.clanId == 'comm_football') {
          memberList.addAll([
            {'name': 'Rohit Sharma', 'role': 'CAPTAIN (Striker)', 'xp': 620, 'emoji': '👑', 'isDemo': true},
            {'name': 'Aman Verma', 'role': 'VICE-CAPTAIN', 'xp': 580, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Sneha Reddy', 'role': 'FORWARD', 'xp': 540, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Devansh Kumar', 'role': 'MIDFIELDER', 'xp': 510, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Yash Patel', 'role': 'GOALKEEPER', 'xp': 480, 'emoji': '🧤', 'isDemo': true},
            {'name': 'Priya Nair', 'role': 'DEFENDER', 'xp': 450, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Tanvi Shah', 'role': 'WINGBACK', 'xp': 420, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Karan Malhotra', 'role': 'MIDFIELDER', 'xp': 390, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Aditya Sen', 'role': 'STRIKER', 'xp': 370, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Ananya Roy', 'role': 'WINGER', 'xp': 350, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Vikram Mehra', 'role': 'CENTER-BACK', 'xp': 330, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Simran Kaur', 'role': 'MIDFIELDER', 'xp': 310, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Kabir Das', 'role': 'FORWARD', 'xp': 290, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Rhea Kapoor', 'role': 'WINGBACK', 'xp': 270, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Harsh Gupta', 'role': 'DEFENDER', 'xp': 250, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Neha Joshi', 'role': 'MIDFIELDER', 'xp': 240, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Manish Rao', 'role': 'GOALKEEPER (SUB)', 'xp': 220, 'emoji': '🧤', 'isDemo': true},
            {'name': 'Kriti Varma', 'role': 'WINGER', 'xp': 210, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Siddharth Iyer', 'role': 'DEFENDER', 'xp': 190, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Tara Singh', 'role': 'MIDFIELDER', 'xp': 180, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Varun Chawla', 'role': 'STRIKER (SUB)', 'xp': 170, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Ishita Paul', 'role': 'WINGBACK', 'xp': 160, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Gaurav Jain', 'role': 'DEFENDER', 'xp': 150, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Divya Pillai', 'role': 'MIDFIELDER', 'xp': 140, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Akash Bhatia', 'role': 'FORWARD', 'xp': 130, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Meera Menon', 'role': 'DEFENDER', 'xp': 120, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Kunal Bajaj', 'role': 'WINGER', 'xp': 110, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Pooja Hegde', 'role': 'MIDFIELDER', 'xp': 100, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Rohan Nair', 'role': 'STRIKER (RESERVE)', 'xp': 90, 'emoji': '⚽', 'isDemo': true},
            {'name': 'Nikhil Saxena', 'role': 'RESERVE', 'xp': 80, 'emoji': '🏃', 'isDemo': true},
          ]);
        } else if (widget.clanId == 'comm_basketball') {
          memberList.addAll([
            {'name': 'Kabir Mehta', 'role': 'CAPTAIN (Point Guard)', 'xp': 710, 'emoji': '👑', 'isDemo': true},
            {'name': 'Maya Sen', 'role': 'VICE-CAPTAIN (Shooting Guard)', 'xp': 650, 'emoji': '⛹️', 'isDemo': true},
            {'name': 'Rohan Das', 'role': 'CENTER', 'xp': 580, 'emoji': '🏀', 'isDemo': true},
            {'name': 'Aditya Rao', 'role': 'POWER FORWARD', 'xp': 520, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Ananya Gupta', 'role': 'SMALL FORWARD', 'xp': 490, 'emoji': '🏀', 'isDemo': true},
            {'name': 'Vikram Singh', 'role': 'POINT GUARD (SUB)', 'xp': 450, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Simran Kaur', 'role': 'SHOOTING GUARD', 'xp': 410, 'emoji': '⛹️', 'isDemo': true},
            {'name': 'Neha Joshi', 'role': 'SIXTH PLAYER', 'xp': 370, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Harshvardhan', 'role': 'CENTER (SUB)', 'xp': 340, 'emoji': '🏀', 'isDemo': true},
            {'name': 'Priya Patel', 'role': 'FORWARD', 'xp': 310, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Devansh K.', 'role': 'GUARD', 'xp': 280, 'emoji': '⛹️', 'isDemo': true},
            {'name': 'Tanvi Gupta', 'role': 'FORWARD', 'xp': 250, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Karan Singh', 'role': 'POWER FORWARD', 'xp': 220, 'emoji': '🏀', 'isDemo': true},
            {'name': 'Meera Joshi', 'role': 'GUARD', 'xp': 190, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Aman Verma', 'role': 'RESERVE', 'xp': 170, 'emoji': '⛹️', 'isDemo': true},
            {'name': 'Rhea Kapoor', 'role': 'FORWARD', 'xp': 150, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Yash Patil', 'role': 'GUARD', 'xp': 130, 'emoji': '🏀', 'isDemo': true},
            {'name': 'Siddharth I.', 'role': 'CENTER', 'xp': 110, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Ishita Paul', 'role': 'GUARD', 'xp': 90, 'emoji': '⛹️', 'isDemo': true},
            {'name': 'Varun Chawla', 'role': 'RESERVE', 'xp': 70, 'emoji': '⚡', 'isDemo': true},
          ]);
        } else if (widget.clanId == 'comm_volleyball') {
          memberList.addAll([
            {'name': 'Rahul Verma', 'role': 'CAPTAIN (Outside Hitter)', 'xp': 480, 'emoji': '👑', 'isDemo': true},
            {'name': 'Meera Joshi', 'role': 'VICE-CAPTAIN (Setter)', 'xp': 420, 'emoji': '🏐', 'isDemo': true},
            {'name': 'Harshvardhan', 'role': 'SPIKER', 'xp': 380, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Pooja Das', 'role': 'LIBERO', 'xp': 330, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Kunal Sen', 'role': 'MIDDLE BLOCKER', 'xp': 290, 'emoji': '🏐', 'isDemo': true},
            {'name': 'Ria Kapoor', 'role': 'SERVER', 'xp': 250, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Aditya Rao', 'role': 'OPPOSITE HITTER', 'xp': 220, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Tanvi Shah', 'role': 'DEFENSIVE SPECIALIST', 'xp': 190, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Devansh K.', 'role': 'SETTER (SUB)', 'xp': 160, 'emoji': '🏐', 'isDemo': true},
            {'name': 'Ananya Roy', 'role': 'SPIKER (SUB)', 'xp': 140, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Vikram Mehra', 'role': 'MIDDLE BLOCKER', 'xp': 120, 'emoji': '⚡', 'isDemo': true},
            {'name': 'Sneha Reddy', 'role': 'SERVER', 'xp': 100, 'emoji': '🏐', 'isDemo': true},
            {'name': 'Manish Rao', 'role': 'LIBERO (SUB)', 'xp': 80, 'emoji': '🛡️', 'isDemo': true},
            {'name': 'Kriti Varma', 'role': 'DEFENSIVE SPECIALIST', 'xp': 60, 'emoji': '🏃', 'isDemo': true},
            {'name': 'Akash Bhatia', 'role': 'RESERVE', 'xp': 40, 'emoji': '⚡', 'isDemo': true},
          ]);
        } else {
          for (final member in _demoMembers) {
            memberList.add({
              'name': member['name'] as String,
              'role': 'MEMBER',
              'xp': member['weeklyXp'] as int,
              'emoji': member['emoji'] as String,
              'isDemo': true,
            });
          }
        }

        // Sort by XP descending
        memberList.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            final m = memberList[index];
            final rank = index + 1;

            return _memberCard(
              rank: rank,
              name: m['name'] as String,
              role: m['role'] as String,
              xp: m['xp'] as int,
              emoji: m['emoji'] as String,
              isDemo: m['isDemo'] as bool,
            );
          },
        );
      },
    );
  }

  Widget _memberCard({
    required int rank,
    required String name,
    required String role,
    required int xp,
    required String emoji,
    required bool isDemo,
  }) {
    Color? rankBadgeColor;
    if (rank == 1) rankBadgeColor = const Color(0xFFFFD700);
    if (rank == 2) rankBadgeColor = const Color(0xFFC0C0C0);
    if (rank == 3) rankBadgeColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Row(
        children: [
          // Rank Medal or Position
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankBadgeColor != null
                  ? rankBadgeColor.withValues(alpha: 0.2)
                  : FqColors.scaffold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank <= 3 ? (rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉') : '#$rank',
                style: TextStyle(
                  fontSize: rank <= 3 ? 14 : 10,
                  fontWeight: FontWeight.w900,
                  color: rank <= 3 ? Colors.black : const Color(0xFF747887),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: FqColors.lavender,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),

          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FqColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (isDemo) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: FqColors.lavender,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEMO',
                          style: TextStyle(
                            color: FqColors.primary,
                            fontSize: 6.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF747887),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          // XP Contribution
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: FqColors.lavender,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$xp XP',
              style: const TextStyle(
                color: FqColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CLAN WAR TAB (ARENA)
  // ---------------------------------------------------------------------------

  Widget _buildWar() {
    final myPoints = _myWarPoints() + _demoWarPoints();
    const opponentPoints = 780;
    final totalPoints = (myPoints + opponentPoints).clamp(1, 99999);
    final myShare = (myPoints / totalPoints).clamp(0.05, 0.95);
    final myClanWins = myPoints >= opponentPoints;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        children: [
          // Arena Battle Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF302B63), Color(0xFF51489A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
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
                      child: const Text(
                        'ROUND 3 OF 4',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.white70, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Ends in 2d 14h',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Teams Score Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          const Text(
                            'YOUR CLAN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$myPoints',
                            style: const TextStyle(
                              color: FqColors.accent,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('⚔️', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          const Text(
                            'RIVAL CLAN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$opponentPoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tug of War Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.15),
                    child: Row(
                      children: [
                        Flexible(
                          flex: (myShare * 100).toInt(),
                          child: Container(color: FqColors.accent),
                        ),
                        Flexible(
                          flex: ((1 - myShare) * 100).toInt(),
                          child: Container(color: const Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Lead Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: myClanWins
                        ? FqColors.accent.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    myClanWins
                        ? '🔥 YOUR CLAN IS LEADING BY ${myPoints - opponentPoints} PTS'
                        : '💪 OPPONENT LEADING BY ${opponentPoints - myPoints} PTS',
                    style: TextStyle(
                      color: myClanWins ? FqColors.accent : Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // User Contribution Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                    child: Text('🌟', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR CONTRIBUTION',
                        style: TextStyle(
                          color: Color(0xFF747887),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_myWarPoints()} War Points Earned',
                        style: const TextStyle(
                          color: FqColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: FqColors.lavender,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: FqColors.primary,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // War Scoring Rules
          _warRuleTile('🏃', 'Workouts & Runs', 'Every 20 mins of activity awards +50 War Points.'),
          _warRuleTile('🧠', 'Wellness Quiz', 'Complete weekly quizzes for +50 War Points.'),
          _warRuleTile('🎯', 'Daily Quests', 'Daily student quests boost your clan total score.'),
        ],
      ),
    );
  }

  Widget _warRuleTile(String emoji, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: FqColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF747887),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await widget.clanService.sendMessage(
        clanId: widget.clanId,
        text: text,
      );
      await _sendDemoReply(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}


