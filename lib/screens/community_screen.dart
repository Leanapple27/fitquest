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

  // ---------------------------------------------------------------------------
  // HERO BANNER
  // ---------------------------------------------------------------------------

  Widget _buildHeroBanner() {
    return Container(
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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚔️', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 5),
                    Text(
                      'WEEKLY CLAN WARS ACTIVE',
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: FqColors.accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'DIVISION 1',
                  style: TextStyle(
                    color: FqColors.accent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Build your clan.\nCompete together.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Team up with classmates, complete quests together, and dominate the weekly fitness leaderboard.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _createClan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FqColors.accent,
                  foregroundColor: const Color(0xFF151B3D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Create Clan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => setState(() => _activeSegment = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: const Text(
                  'Explore Clans',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
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
      {'label': 'Clans', 'icon': Icons.explore_rounded},
      {'label': 'My Clan', 'icon': Icons.shield_rounded},
      {'label': '🏆 Leagues', 'icon': Icons.military_tech_rounded},
      {'label': 'Rules', 'icon': Icons.info_outline_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
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
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? FqColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: FqColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 15,
                        color: isSelected ? Colors.white : const Color(0xFF747887),
                      ),
                      const SizedBox(width: 5),
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
    if (docs.isEmpty) {
      return _emptyClans();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOP CLANS THIS WEEK',
              style: FqTypography.sectionLabel(color: FqColors.muted),
            ),
            Text(
              '${docs.length} Active',
              style: const TextStyle(
                color: FqColors.primaryMid,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...docs.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final doc = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDiscoverClanCard(doc, rank),
          );
        }),
      ],
    );
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

  Widget _buildDiscoverClanCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    int rank,
  ) {
    final data = doc.data();
    final emoji = data['emoji']?.toString() ?? '🛡️';
    final name = data['name']?.toString() ?? 'Clan';
    final xp = data['weeklyXp'] is num ? (data['weeklyXp'] as num).toInt() : 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _clanService.streamMembers(doc.id),
      builder: (context, memberSnapshot) {
        final realMembers = memberSnapshot.data?.docs.length ?? 0;
        final totalMembers = realMembers + _demoMembers.length;

        Color? rankColor;
        if (rank == 1) rankColor = const Color(0xFFFFD700);
        if (rank == 2) rankColor = const Color(0xFFC0C0C0);
        if (rank == 3) rankColor = const Color(0xFFCD7F32);

        return Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              // Rank Medal / Index
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rankColor != null
                      ? rankColor.withValues(alpha: 0.2)
                      : FqColors.scaffold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank <= 3 ? (rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉') : '#$rank',
                    style: TextStyle(
                      color: rank <= 3 ? Colors.black : const Color(0xFF747887),
                      fontSize: rank <= 3 ? 14 : 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Clan Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: FqColors.lavender,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 11),

              // Clan Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FqColors.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 13,
                          color: Color(0xFF747887),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalMembers members',
                          style: const TextStyle(
                            color: Color(0xFF747887),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: FqColors.energy,
                        ),
                        Text(
                          '$xp XP',
                          style: const TextStyle(
                            color: FqColors.energy,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Join Button
              ElevatedButton(
                onPressed: () => _joinClan(doc.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FqColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  // ---------------------------------------------------------------------------
  // HOW IT WORKS SECTION
  // ---------------------------------------------------------------------------

  Widget _buildHowItWorksSection() {
    final perks = [
      {
        'emoji': '💬',
        'title': 'Live Clan Chat',
        'desc': 'Coordinate workout meetups and motivate your team in real time.',
      },
      {
        'emoji': '⚔️',
        'title': 'Weekly Clan Wars',
        'desc': 'Compete head-to-head against another clan every week for bonus trophies.',
      },
      {
        'emoji': '🏆',
        'title': 'Contributor Leaderboard',
        'desc': 'Every movement quest and step logged contributes to the clan standing.',
      },
      {
        'emoji': '👥',
        'title': 'Peer Accountability',
        'desc': 'Fitness is better together. Cheer on your friends and stay on streak.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW FITQUEST CLANS WORK',
          style: FqTypography.sectionLabel(color: FqColors.muted),
        ),
        const SizedBox(height: 10),
        ...perks.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
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
                      color: FqColors.lavender,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        p['emoji'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'] as String,
                          style: const TextStyle(
                            color: FqColors.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p['desc'] as String,
                          style: const TextStyle(
                            color: Color(0xFF747887),
                            fontSize: 10.5,
                            height: 1.35,
                          ),
                        ),
                      ],
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
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: FqRadii.cardBorder,
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Column(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 38)),
          const SizedBox(height: 8),
          const Text(
            'No public clans yet',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: FqColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create the first one and lead your classmates to victory!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _createClan,
            style: ElevatedButton.styleFrom(
              backgroundColor: FqColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create First Clan'),
          ),
        ],
      ),
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
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.clanService.streamClan(widget.clanId),
      builder: (context, clanSnapshot) {
        final data = clanSnapshot.data?.data() ?? {};
        final name = data['name']?.toString() ?? 'Clan HQ';
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
                Tab(text: 'CLAN WAR ⚔️'),
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
                  final totalMembers = realMembers + _demoMembers.length;

                  final realXp = memberSnapshot.data?.docs.fold<int>(
                        0,
                        (total, doc) {
                          final value = doc.data()['weeklyXp'];
                          return total + (value is num ? value.toInt() : 0);
                        },
                      ) ??
                      weeklyXp;

                  final totalXp = realXp + _demoWarPoints();

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
                    _buildChat(),
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

  Widget _buildChat() {
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
                                  style: const TextStyle(
                                    color: FqColors.primaryMid,
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

        // Chat Input Bar
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
                      hintText: 'Message your clan...',
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
                    color: FqColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
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

        for (final member in _demoMembers) {
          memberList.add({
            'name': member['name'] as String,
            'role': 'MEMBER',
            'xp': member['weeklyXp'] as int,
            'emoji': member['emoji'] as String,
            'isDemo': true,
          });
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
