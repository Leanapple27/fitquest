import 'package:flutter/material.dart';
import '../app_state.dart';

class LeaguesScreen extends StatefulWidget {
  final AppState appState;

  const LeaguesScreen({
    super.key,
    required this.appState,
  });

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  final List<Map<String, dynamic>> _leagueTiers = [
    {'name': 'Bronze League', 'icon': '🥉', 'color': Color(0xFFCD7F32)},
    {'name': 'Silver League', 'icon': '🥈', 'color': Color(0xFF94A3B8)},
    {'name': 'Gold League', 'icon': '🥇', 'color': Color(0xFFF59E0B), 'active': true},
    {'name': 'Diamond League', 'icon': '💎', 'color': Color(0xFF06B6D4)},
    {'name': 'Champion League', 'icon': '👑', 'color': Color(0xFF8B5CF6)},
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Current Tier Card & Countdown
          _buildTierHeader(),

          const SizedBox(height: 16),

          // League Rules Banner
          Container(
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
          ),

          const SizedBox(height: 16),

          // 15-Student Bracket Standings
          ..._bracketStudents.map((student) => _buildStudentRankCard(student)),
        ],
      ),
    );
  }

  Widget _buildTierHeader() {
    return Container(
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
          // Tier progression visual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _leagueTiers.map((tier) {
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
          // Rank Badge with status color indicator
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

          // Avatar
          Text(student['avatar'], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),

          // Name and House
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

          // XP Score
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
