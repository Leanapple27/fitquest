import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/fq_animations.dart';

class LeaguesScreen extends StatefulWidget {
  final AppState appState;

  const LeaguesScreen({
    super.key,
    required this.appState,
  });

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allLeagues = [
    {
      'name': 'Bronze League',
      'icon': '🥉',
      'tier': 1,
      'minXp': '0 XP',
      'color': Color(0xFFCD7F32),
      'active': false,
      'description': 'The starting division for all new campus athletes.',
      'multiplier': '1.0x Base XP',
      'perks': [
        'Entry into weekly 15-student division brackets',
        'Standard Daily Quest access',
        'Basic 1v1 Duels (50 XP Wagers)',
      ],
    },
    {
      'name': 'Silver League',
      'icon': '🥈',
      'tier': 2,
      'minXp': '2,500 XP',
      'color': Color(0xFF94A3B8),
      'active': false,
      'description': 'For consistent students building daily workout habits.',
      'multiplier': '1.1x (+10% Bonus XP)',
      'perks': [
        '+10% Bonus XP on all verified workouts',
        'Silver Avatar Profile Ring',
        'Unlock 100 XP 1v1 Duels',
      ],
    },
    {
      'name': 'Gold League',
      'icon': '🥇',
      'tier': 3,
      'minXp': '5,000 XP',
      'color': Color(0xFFF59E0B),
      'active': true,
      'description': 'Top 25% elite campus athletes setting the pace.',
      'multiplier': '1.25x (+25% Bonus XP)',
      'perks': [
        '+25% Bonus XP on all steps and workouts',
        'Gold House Flame Avatar Flair',
        'High-Stakes 200 XP 1v1 Duels Unlock',
        'Clan SOS Streak Rescue Priority',
      ],
    },
    {
      'name': 'Diamond League',
      'icon': '💎',
      'tier': 4,
      'minXp': '10,000 XP',
      'color': Color(0xFF06B6D4),
      'active': false,
      'description': 'Top 10% fitness masters dominating university leaderboards.',
      'multiplier': '1.5x (+50% Bonus XP)',
      'perks': [
        '+50% Bonus XP on everything',
        'Diamond Neon Pulsing Profile Aura',
        'Custom Campus Athletic Title',
        'Double Streak Freeze Token per month',
      ],
    },
    {
      'name': 'Champion League',
      'icon': '👑',
      'tier': 5,
      'minXp': '20,000 XP',
      'color': Color(0xFF8B5CF6),
      'active': false,
      'description': 'Top 1% Campus Legends. The highest rank in FitQuest.',
      'multiplier': '2.0x (DOUBLE XP ⚡)',
      'perks': [
        '2.0x Double XP on all activities',
        'Crown Profile Flair & Hall of Fame Entry',
        'Campus Canteen & Merch Vouchers',
        'Exclusive Clan Captain Status',
      ],
    },
  ];

  final List<Map<String, dynamic>> _bracketStudents = [
    {'rank': 1, 'name': 'Aditya S.', 'house': 'Ignis', 'xp': 1420, 'avatar': '🔥', 'isMe': false},
    {'rank': 2, 'name': 'Alex Johnson (You)', 'house': 'Ignis', 'xp': 1250, 'avatar': '⚡', 'isMe': true},
    {'rank': 3, 'name': 'Priya Patel', 'house': 'Aqua', 'xp': 1180, 'avatar': '🌊', 'isMe': false},
    {'rank': 4, 'name': 'Rahul Verma', 'house': 'Terra', 'xp': 990, 'avatar': '🌿', 'isMe': false},
    {'rank': 5, 'name': 'Sneha Rao', 'house': 'Vayu', 'xp': 940, 'avatar': '🌪️', 'isMe': false},
    {'rank': 6, 'name': 'Karan Singh', 'house': 'Ignis', 'xp': 880, 'avatar': '🦁', 'isMe': false},
    {'rank': 7, 'name': 'Ananya Sharma', 'house': 'Terra', 'xp': 820, 'avatar': '🌱', 'isMe': false},
    {'rank': 8, 'name': 'Vikram Mehta', 'house': 'Aqua', 'xp': 760, 'avatar': '💧', 'isMe': false},
    {'rank': 9, 'name': 'Rohan Das', 'house': 'Vayu', 'xp': 710, 'avatar': '🦅', 'isMe': false},
    {'rank': 10, 'name': 'Tanvi Gupta', 'house': 'Ignis', 'xp': 650, 'avatar': '🐯', 'isMe': false},
    {'rank': 11, 'name': 'Devansh K.', 'house': 'Terra', 'xp': 590, 'avatar': '🌲', 'isMe': false},
    {'rank': 12, 'name': 'Meera Joshi', 'house': 'Aqua', 'xp': 520, 'avatar': '🐬', 'isMe': false},
    {'rank': 13, 'name': 'Harshvardhan', 'house': 'Vayu', 'xp': 310, 'avatar': '☁️', 'isMe': false},
    {'rank': 14, 'name': 'Simran Kaur', 'house': 'Ignis', 'xp': 280, 'avatar': '🔥', 'isMe': false},
    {'rank': 15, 'name': 'Yash Patil', 'house': 'Terra', 'xp': 190, 'avatar': '🪵', 'isMe': false},
  ];

  final List<Map<String, dynamic>> _communityLeaderboard = [
    {
      'rank': 1,
      'name': 'Hoops & Dunks Crew',
      'sport': 'Basketball',
      'emoji': '🏀',
      'tier': 'Platinum Division',
      'level': 8,
      'members': 20,
      'weeklyXp': 4180,
      'streak': '6 Wins 🔥',
      'isMyCommunity': false,
    },
    {
      'rank': 2,
      'name': 'Football Strikers Club',
      'sport': 'Football',
      'emoji': '⚽',
      'tier': 'Gold Division',
      'level': 6,
      'members': 30,
      'weeklyXp': 3420,
      'streak': '4 Wins 🔥',
      'isMyCommunity': true,
    },
    {
      'rank': 3,
      'name': 'Volleyball Spikers',
      'sport': 'Volleyball',
      'emoji': '🏐',
      'tier': 'Silver Division',
      'level': 4,
      'members': 15,
      'weeklyXp': 2150,
      'streak': '2 Wins ⚡',
      'isMyCommunity': false,
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
    super.dispose();
  }

  void _showLeagueDetailsModal(Map<String, dynamic> league) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final color = league['color'] as Color;
        final perks = league['perks'] as List<dynamic>;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
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
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Center(
                      child: Text(league['icon'], style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              league['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF151B3D),
                              ),
                            ),
                            if (league['active'] == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F5D4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF151B3D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          league['multiplier'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                league['description'],
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 18),
              const Text(
                'LEAGUE PERKS & PRIVILEGES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              ...perks.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚡ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            p.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('GOT IT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Weekly Leagues',
          style: TextStyle(
            color: Color(0xFF151B3D),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF151B3D)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF302B63),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF00F5D4),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          tabs: const [
            Tab(text: 'STUDENT BRACKET'),
            Tab(text: 'COMMUNITY LEAGUE 👥'),
            Tab(text: 'ALL TIERS & PERKS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBracketTab(),
          _buildCommunityLeagueTab(),
          _buildAllLeaguesTab(),
        ],
      ),
    );
  }

  Widget _buildBracketTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _buildTierHeader(),
        const SizedBox(height: 16),
        _buildRulesBanner(),
        const SizedBox(height: 16),
        ..._bracketStudents.asMap().entries.map((entry) {
          final i = entry.key;
          final student = entry.value;
          return FQFadeSlide(
            index: i,
            child: FQBounce(
              child: _buildStudentRankCard(student),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommunityLeagueTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Community League Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F0C29).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⚽', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 5),
                        Text(
                          'INTER-COMMUNITY LEAGUE',
                          style: TextStyle(
                            color: Color(0xFF00F5D4),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'SEASON 4',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Sports Community Standings',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Complete team quests, log matches, and win tournament duels to advance your community level!',
                style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Community Division Progression Ladder
        Container(
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COMMUNITY DIVISION PROGRESSION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Level 1 ➔ 10',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF302B63)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _communityTierBadge('🥉', 'Bronze', 'LV 1–3', '0 XP', const Color(0xFFCD7F32), false),
                    _communityTierBadge('🥈', 'Silver', 'LV 4–5', '1,500 XP', const Color(0xFF94A3B8), false),
                    _communityTierBadge('🥇', 'Gold', 'LV 6–7', '3,000 XP', const Color(0xFFF59E0B), true),
                    _communityTierBadge('💎', 'Platinum', 'LV 8–9', '4,500 XP', const Color(0xFF06B6D4), false),
                    _communityTierBadge('👑', 'Champion', 'LV 10', '6,000+ XP', const Color(0xFF8B5CF6), false),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'TOP CAMPUS SPORTS COMMUNITIES',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF64748B),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),

        ..._communityLeaderboard.asMap().entries.map((entry) {
          final i = entry.key;
          final comm = entry.value;
          final isMine = comm['isMyCommunity'] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMine ? const Color(0xFF00F5D4) : const Color(0xFFE2E8F0),
                width: isMine ? 2 : 1,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? const Color(0xFFFEF3C7)
                            : i == 1
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFFFFEDD5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          i == 0 ? '🥇' : i == 1 ? '🥈' : '🥉',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(comm['emoji'] as String, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comm['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF151B3D),
                                ),
                              ),
                              if (isMine) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF302B63),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'YOU',
                                    style: TextStyle(
                                      color: Color(0xFF00F5D4),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${comm['sport']} • ${comm['tier']} • ${comm['members']} Players',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${comm['weeklyXp']} XP',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        Text(
                          comm['streak'] as String,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COMMUNITY LEVEL ${comm['level']} / 10',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '${((comm['level'] as int) * 10)}% TO LV ${((comm['level'] as int) + 1)}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF302B63)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ((comm['level'] as int) / 10).toDouble(),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF302B63)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _communityTierBadge(String icon, String name, String levels, String reqXp, Color color, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? color : const Color(0xFFE2E8F0),
          width: isCurrent ? 1.8 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isCurrent ? color : const Color(0xFF1E293B),
            ),
          ),
          Text(
            levels,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isCurrent ? color : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(
              reqXp,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllLeaguesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF302B63),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIVISION HIERARCHY',
                      style: TextStyle(
                        color: Color(0xFF00F5D4),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Climb Tiers & Unlock Perks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Finish in Top 3 every Sunday midnight to promote!',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._allLeagues.asMap().entries.map((entry) {
          final i = entry.key;
          final league = entry.value;
          return FQFadeSlide(
            index: i,
            child: FQBounce(
              child: _buildLeagueOverviewCard(league),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLeagueOverviewCard(Map<String, dynamic> league) {
    final bool active = league['active'] == true;
    final Color color = league['color'] as Color;

    return GestureDetector(
      onTap: () => _showLeagueDetailsModal(league),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF00F5D4) : const Color(0xFFE2E8F0),
            width: active ? 2 : 1,
          ),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(league['icon'], style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        league['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (active) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F5D4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'YOU ARE HERE',
                            style: TextStyle(
                              color: Color(0xFF0F0C29),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${league['multiplier']} • Tap for rewards',
                    style: TextStyle(
                      color: active ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildTierHeader() {
    return GestureDetector(
      onTap: () => _tabController.animateTo(1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF302B63), Color(0xFF24243E)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF302B63).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
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
                          'CURRENT DIVISION',
                          style: TextStyle(
                            color: Color(0xFF00F5D4),
                            fontSize: 10,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '2d 14h left',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _allLeagues.map((tier) {
                final active = tier['active'] == true;
                return Column(
                  children: [
                    Text(tier['icon'], style: TextStyle(fontSize: active ? 22 : 16)),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF00F5D4) : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to View All League Rewards & Perks 💎',
                  style: TextStyle(
                    color: Color(0xFF00F5D4),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: Color(0xFF00F5D4), size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    );
  }

  Widget _buildStudentRankCard(Map<String, dynamic> student) {
    final int rank = student['rank'];
    final bool isMe = student['isMe'] == true;
    final bool isPromotion = rank <= 3;
    final bool isDemotion = rank >= 13;

    Color badgeColor = const Color(0xFF64748B);
    if (isPromotion) badgeColor = const Color(0xFF16A34A);
    if (isDemotion) badgeColor = const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFF00F5D4) : const Color(0xFFE2E8F0),
          width: isMe ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(student['avatar'], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 13.5,
                    color: isMe ? const Color(0xFF166534) : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${student['house']} House',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF59E0B)),
                Text(
                  '${student['xp']} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
