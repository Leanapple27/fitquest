import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF151B3D),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeacherHeader(),

            const SizedBox(height: 20),

            _buildClassCard(),

            const SizedBox(height: 22),

            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    emoji: '✅',
                    title: 'Mark Activity',
                    subtitle: 'Record participation',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    emoji: '👥',
                    title: 'Students',
                    subtitle: 'View class',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    emoji: '📊',
                    title: 'Progress',
                    subtitle: 'Class statistics',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    emoji: '🏆',
                    title: 'Leaderboard',
                    subtitle: 'Class rankings',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildNoPhoneCard(),

            const SizedBox(height: 22),

            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 10),

            _buildActivityItem(
              emoji: '🏃',
              name: 'Aarav',
              activity: 'Running',
              duration: '20 min',
            ),

            _buildActivityItem(
              emoji: '🏀',
              name: 'Priya',
              activity: 'Basketball',
              duration: '35 min',
            ),

            _buildActivityItem(
              emoji: '⚽',
              name: 'Rahul',
              activity: 'Football',
              duration: '30 min',
            ),

            _buildActivityItem(
              emoji: '🧘',
              name: 'Ananya',
              activity: 'Stretching',
              duration: '15 min',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherHeader() {
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
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              '👩‍🏫',
              style: TextStyle(fontSize: 31),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Ma\'am! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'PE Teacher • FitQuest School',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: Color(0xFF302B63),
                size: 25,
              ),
              SizedBox(width: 10),
              Text(
                'Class 8-A',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),
              Spacer(),
              Text(
                '42 students',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Text(
                '31',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF302B63),
                ),
              ),
              SizedBox(width: 7),
              Text(
                '/ 42 participated today',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 31 / 42,
              minHeight: 10,
              backgroundColor: Color(0xFFE8E8EE),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF302B63),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '74% participation today',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPhoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB9DEC2),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students without phones',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF205C32),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Teachers can record and verify physical activity '
                  'for students who do not have a personal smartphone.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF477A55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String emoji,
    required String name,
    required String activity,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activity • $duration',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              '✓ Verified',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF27733A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}