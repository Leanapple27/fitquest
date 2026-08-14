import 'package:flutter/material.dart';
import '../app_state.dart';

class FitMapScreen extends StatefulWidget {
  final AppState appState;

  const FitMapScreen({
    super.key,
    required this.appState,
  });

  @override
  State<FitMapScreen> createState() => _FitMapScreenState();
}

class _FitMapScreenState extends State<FitMapScreen> {
  String? activeActivity;
  bool activityStarted = false;
  bool buddyJoined = false;
  bool hotspotJoined = false;
  String selectedFilter = 'ALL';

  final List<Map<String, dynamic>> _activities = [
    {
      'emoji': '🏃',
      'title': 'Running Track',
      'subtitle': 'Outdoor track',
      'people': 12,
      'status': 'Moderate',
      'xp': 100,
      'free': true,
      'type': 'RUN',
      'buddyCount': 5,
      'time': '6:00 PM',
    },
    {
      'emoji': '🏊',
      'title': 'Swimming Area',
      'subtitle': 'Pool zone',
      'people': 7,
      'status': 'Available',
      'xp': 120,
      'free': false,
      'type': 'SWIM',
      'buddyCount': 3,
      'time': '5:30 PM',
    },
    {
      'emoji': '🏀',
      'title': 'Basketball Court',
      'subtitle': 'Indoor court',
      'people': 18,
      'status': 'Busy',
      'xp': 100,
      'free': true,
      'type': 'SPORT',
      'buddyCount': 8,
      'time': '5:30 PM',
    },
    {
      'emoji': '🏋️',
      'title': 'Fitness Gym',
      'subtitle': 'Strength & fitness',
      'people': 9,
      'status': 'Moderate',
      'xp': 150,
      'free': false,
      'type': 'GYM',
      'buddyCount': 4,
      'time': '7:00 PM',
    },
    {
      'emoji': '⚽',
      'title': 'Football Ground',
      'subtitle': 'Main field',
      'people': 15,
      'status': 'Busy',
      'xp': 120,
      'free': true,
      'type': 'SPORT',
      'buddyCount': 10,
      'time': '6:30 PM',
    },
  ];

  final List<Map<String, dynamic>> _demoBuddies = [
    {
      'name': 'Arjun',
      'emoji': '🏃',
      'activity': 'Running',
      'level': 7,
      'demo': true,
    },
    {
      'name': 'Maya',
      'emoji': '🧘',
      'activity': 'Yoga',
      'level': 9,
      'demo': true,
    },
    {
      'name': 'Rahul',
      'emoji': '🏋️',
      'activity': 'Gym',
      'level': 6,
      'demo': true,
    },
    {
      'name': 'Sara',
      'emoji': '🏀',
      'activity': 'Basketball',
      'level': 8,
      'demo': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: const Text(
              'FitMap',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _showInfo,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF302B63),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrivacyBanner(),
                const SizedBox(height: 16),
                _buildTodayCard(),
                const SizedBox(height: 18),
                _buildBuddyHero(),
                const SizedBox(height: 20),
                _buildSectionTitle('FIND YOUR ACTIVITY'),
                const SizedBox(height: 10),
                _buildFilters(),
                const SizedBox(height: 12),
                _buildSchoolMap(),
                const SizedBox(height: 22),
                _buildSectionTitle('FITQUEST HOTSPOT'),
                const SizedBox(height: 10),
                _buildHotspotCard(),
                const SizedBox(height: 22),
                _buildSectionTitle('ACTIVITY AREAS'),
                const SizedBox(height: 10),
                ..._filteredActivities().map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAreaCard(activity),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSectionTitle('FITNESS BUDDIES'),
                const SizedBox(height: 10),
                _buildBuddyList(),
                const SizedBox(height: 22),
                _buildSectionTitle('TODAY ON CAMPUS'),
                const SizedBox(height: 10),
                _buildScheduleCard(),
                const SizedBox(height: 22),
                _buildSectionTitle('CAMPUS FITNESS'),
                const SizedBox(height: 10),
                _buildLeaderboard(),
                if (activeActivity != null) ...[
                  const SizedBox(height: 22),
                  _buildActiveActivity(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Colors.black45,
      ),
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            color: Color(0xFF302B63),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy-first FitMap',
                  style: TextStyle(
                    color: Color(0xFF302B63),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You see activity levels, not individual locations. '
                  'Buddy matching is opt-in.',
                  style: TextStyle(
                    color: Color(0xFF51489A),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0D6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 27)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY\'S ACTIVITY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.appState.xp} XP earned',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                '${widget.appState.streak} days',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF302B63),
            Color(0xFF51489A),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text('🤝', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Fitness Buddy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                '+10',
                style: TextStyle(
                  color: Color(0xFFFFD166),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Training is easier when someone is counting on you.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat('5', 'looking for a buddy'),
              const SizedBox(width: 10),
              _heroStat('4', 'activities today'),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _openBuddyFinder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD166),
                foregroundColor: const Color(0xFF302B63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'FIND A FITNESS BUDDY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['ALL', 'FREE', 'RUN', 'SPORT', 'GYM'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: const Color(0xFF302B63),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF302B63),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredActivities() {
    if (selectedFilter == 'ALL') return _activities;
    if (selectedFilter == 'FREE') {
      return _activities.where((a) => a['free'] == true).toList();
    }
    return _activities
        .where((a) => a['type'] == selectedFilter)
        .toList();
  }

  Widget _buildSchoolMap() {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0E2),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD3DEC9)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            right: 20,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '🏫  FitQuest School Campus',
                  style: TextStyle(
                    color: Color(0xFF151B3D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 25,
            top: 90,
            child: _mapZone(
              emoji: '🏃',
              label: 'Track',
              onTap: () => _selectActivity('Running Track'),
            ),
          ),
          Positioned(
            right: 25,
            top: 90,
            child: _mapZone(
              emoji: '🏀',
              label: 'Court',
              onTap: () => _selectActivity('Basketball Court'),
            ),
          ),
          Positioned(
            left: 45,
            bottom: 28,
            child: _mapZone(
              emoji: '🏊',
              label: 'Pool',
              onTap: () => _selectActivity('Swimming Area'),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 28,
            child: _mapZone(
              emoji: '🏋️',
              label: 'Gym',
              onTap: () => _selectActivity('Fitness Gym'),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 205,
            child: Center(
              child: GestureDetector(
                onTap: () => _selectActivity('Football Ground'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '⚽ Main Ground',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapZone({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 27)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Central Sports Ground',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
              ),
              _tag('HOT'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '32 FitQuest activities this week',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _miniStat('🏃', '18 runs'),
              _miniStat('🏀', '9 games'),
              _miniStat('🏋️', '5 workouts'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  hotspotJoined = !hotspotJoined;
                });
                _showMessage(
                  hotspotJoined
                      ? '🔥 Hotspot challenge joined! +20 XP on completion.'
                      : 'Hotspot challenge left.',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF302B63),
                side: const BorderSide(color: Color(0xFF302B63)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                hotspotJoined
                    ? 'JOINED • +20 XP BONUS'
                    : 'JOIN HOTSPOT CHALLENGE',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String text) {
    return Expanded(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF151B3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9A6412),
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildAreaCard(Map<String, dynamic> activity) {
    final title = activity['title'] as String;
    final selected = activeActivity == title;
    final status = activity['status'] as String;
    final statusColor = status == 'Busy'
        ? const Color(0xFFFFA726)
        : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () => _selectActivity(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(
                  color: const Color(0xFF51489A),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  activity['emoji'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activity['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '+${activity['xp']} XP',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF7545),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (activity['free'] == true) _tag('FREE'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${activity['people']} active',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '🤝 ${activity['buddyCount']} buddies',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF51489A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyList() {
    return Column(
      children: _demoBuddies.take(3).map((buddy) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF0EFFF),
                child: Text(
                  buddy['emoji'] as String,
                  style: const TextStyle(fontSize: 22),
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
                          buddy['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF151B3D),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _tag('DEMO'),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${buddy['activity']} • Level ${buddy['level']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _joinBuddy(
                  buddy['name'] as String,
                  buddy['activity'] as String,
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCard() {
    final items = [
      ('🏃', 'Evening Run', '6:00 PM', '6 joined'),
      ('🏀', 'Basketball', '5:30 PM', '10 joined'),
      ('🧘', 'Recovery Yoga', '7:00 PM', '5 joined'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 23)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.$3} • ${item.$4}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black26,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboard() {
    final entries = [
      ('🥇', 'Arjun', 420),
      ('🥈', 'You', widget.appState.xp),
      ('🥉', 'Maya', 350),
      ('4', 'Rahul', 290),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                ),
                Text(
                  '${item.$3} XP',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF51489A),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveActivity() {
    final activity = activeActivity ?? 'Activity';
    final xp = _xpForActivity(activity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF302B63),
            Color(0xFF51489A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY SELECTED',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            activity,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activityStarted
                ? 'Activity in progress'
                : 'Ready to start your activity',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text(
                '⭐ Reward',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+$xp XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (buddyJoined) ...[
                const SizedBox(width: 12),
                const Text(
                  '+10 Buddy',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: activityStarted
                        ? _completeActivity
                        : () {
                            setState(() {
                              activityStarted = true;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      foregroundColor: const Color(0xFF302B63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      activityStarted ? 'COMPLETE' : 'START',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 52,
                height: 46,
                child: OutlinedButton(
                  onPressed: _openBuddyFinder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('🤝'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectActivity(String activity) {
    setState(() {
      activeActivity = activity;
      activityStarted = false;
    });
  }

  int _xpForActivity(String activity) {
    switch (activity) {
      case 'Running Track':
        return 100;
      case 'Swimming Area':
        return 120;
      case 'Basketball Court':
        return 100;
      case 'Fitness Gym':
        return 150;
      case 'Football Ground':
        return 120;
      default:
        return 100;
    }
  }

  void _joinBuddy(String name, String activity) {
    setState(() {
      buddyJoined = true;
      activeActivity = _activityTitle(activity);
      activityStarted = false;
    });

    _showMessage(
      '🤝 You joined $name for $activity. +10 Buddy Bonus on completion!',
    );
  }

  String _activityTitle(String activity) {
    switch (activity) {
      case 'Running':
        return 'Running Track';
      case 'Gym':
        return 'Fitness Gym';
      case 'Basketball':
        return 'Basketball Court';
      case 'Yoga':
        return 'Recovery Yoga';
      default:
        return 'Running Track';
    }
  }

  void _openBuddyFinder() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Find a Fitness Buddy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Join an activity with people who opted in.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _demoBuddies.map((buddy) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFFEDEBFF),
                            child: Text(
                              buddy['emoji'] as String,
                              style: const TextStyle(fontSize: 23),
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
                                      buddy['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF151B3D),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _tag('DEMO'),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${buddy['emoji']} ${buddy['activity']} • Level ${buddy['level']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _joinBuddy(
                                buddy['name'] as String,
                                buddy['activity'] as String,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF302B63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: const Text(
                              'JOIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF302B63),
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Demo participants are simulated for the prototype. '
                        'Real matching can be connected to Firebase later.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF51489A),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _completeActivity() {
    final activity = activeActivity ?? 'Activity';
    final reward = _xpForActivity(activity);
    final totalReward = reward + (buddyJoined ? 10 : 0);

    widget.appState.addXp(totalReward);

    setState(() {
      activityStarted = false;
      buddyJoined = false;
    });

    _showMessage(
      '🎉 $activity complete! +$totalReward XP'
      '${hotspotJoined ? ' • +20 hotspot bonus available' : ''}',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'FitMap',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
          content: const Text(
            'FitMap helps students discover campus activities, '
            'find opt-in fitness buddies, join activity groups, '
            'earn XP, and compete at FitQuest hotspots. '
            'This prototype uses simulated buddy data for demos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
