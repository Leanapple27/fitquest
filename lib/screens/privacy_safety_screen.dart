import 'package:flutter/material.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Privacy & Safety',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSafetyHeader(),

            const SizedBox(height: 22),

            const Text(
              'YOUR PRIVACY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 10),

            _buildSettingCard(
              icon: '👤',
              title: 'Student Profile',
              subtitle: 'Only your school community can see basic profile information.',
              trailing: 'School only',
            ),

            _buildSettingCard(
              icon: '📍',
              title: 'Location',
              subtitle: 'FitMap shows activity areas, not your precise location.',
              trailing: 'Protected',
            ),

            _buildSettingCard(
              icon: '📊',
              title: 'Activity Data',
              subtitle: 'Your activity is used for progress, rewards and school participation.',
              trailing: 'Private',
            ),

            const SizedBox(height: 22),

            const Text(
              'COMMUNITY SAFETY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 10),

            _buildActionCard(
              icon: '🚩',
              title: 'Report a Problem',
              subtitle: 'Report inappropriate content or behaviour.',
              onTap: () {
                _showReportDialog(context);
              },
            ),

            _buildActionCard(
              icon: '🛡️',
              title: 'Community Rules',
              subtitle: 'Learn how to use FitQuest respectfully and safely.',
              onTap: () {
                _showRulesDialog(context);
              },
            ),

            _buildActionCard(
              icon: '🚫',
              title: 'Blocked & Reported',
              subtitle: 'Manage safety reports and blocked users.',
              onTap: () {
                _showInfoDialog(
                  context,
                  'Blocked & Reported',
                  'This section will allow students to manage safety reports and blocked accounts.',
                );
              },
            ),

            const SizedBox(height: 22),

            const Text(
              'SCHOOL ACCOUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 10),

            _buildSchoolAccountCard(),

            const SizedBox(height: 22),

            _buildSafetyMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF302B63),
            Color(0xFF51489A),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛡️',
            style: TextStyle(fontSize: 38),
          ),
          SizedBox(height: 12),
          Text(
            'Your safety comes first.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'FitQuest is designed to protect student privacy while making physical activity fun.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String icon,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
                icon,
                style: const TextStyle(fontSize: 23),
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    height: 1.35,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF27733A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black38,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSchoolAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Text(
            '🏫',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FitQuest School',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Student ID: STU1001',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'School-managed account',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF27733A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB9DEC2),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF27733A),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'FitQuest does not need to publicly expose personal student information to make fitness fun.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF477A55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Report a Problem',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'In the full version, students will be able to report inappropriate content or behaviour to school moderators.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Community Rules',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Be respectful. Encourage others. Do not share private information. Do not bully, threaten or harass other students. Report anything that makes you uncomfortable.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('I Understand'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}