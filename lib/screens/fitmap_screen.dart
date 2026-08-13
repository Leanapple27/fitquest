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
                onPressed: () {
                  _showInfo();
                },
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

                const SizedBox(height: 18),

                _buildTodayCard(),

                const SizedBox(height: 22),

                const Text(
                  'SCHOOL SPORTS ZONE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildSchoolMap(),

                const SizedBox(height: 22),

                const Text(
                  'ACTIVITY AREAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildAreaCard(
                  emoji: '🏃',
                  title: 'Running Track',
                  subtitle: 'Outdoor track',
                  people: '12 active',
                  status: 'Moderate',
                  statusColor: const Color(0xFF4CAF50),
                  xp: 100,
                ),

                const SizedBox(height: 12),

                _buildAreaCard(
                  emoji: '🏊',
                  title: 'Swimming Area',
                  subtitle: 'Pool zone',
                  people: '7 active',
                  status: 'Available',
                  statusColor: const Color(0xFF4CAF50),
                  xp: 120,
                ),

                const SizedBox(height: 12),

                _buildAreaCard(
                  emoji: '🏀',
                  title: 'Basketball Court',
                  subtitle: 'Indoor court',
                  people: '18 active',
                  status: 'Busy',
                  statusColor: const Color(0xFFFFA726),
                  xp: 100,
                ),

                const SizedBox(height: 12),

                _buildAreaCard(
                  emoji: '🏋️',
                  title: 'Fitness Gym',
                  subtitle: 'Strength & fitness',
                  people: '9 active',
                  status: 'Moderate',
                  statusColor: const Color(0xFF4CAF50),
                  xp: 150,
                ),

                const SizedBox(height: 12),

                _buildAreaCard(
                  emoji: '⚽',
                  title: 'Football Ground',
                  subtitle: 'Main field',
                  people: '15 active',
                  status: 'Busy',
                  statusColor: const Color(0xFFFFA726),
                  xp: 120,
                ),

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
                  'You see activity levels, not individual students. '
                  'No names or precise student locations are shown.',
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
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 27),
              ),
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
              const Text(
                '🔥',
                style: TextStyle(fontSize: 20),
              ),
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

  Widget _buildSchoolMap() {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0E2),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFD3DEC9),
        ),
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
              color: const Color(0xFFD8EBCF),
              onTap: () => _selectActivity(
                'Running Track',
              ),
            ),
          ),

          Positioned(
            right: 25,
            top: 90,
            child: _mapZone(
              emoji: '🏀',
              label: 'Court',
              color: const Color(0xFFFFE4C4),
              onTap: () => _selectActivity(
                'Basketball Court',
              ),
            ),
          ),

          Positioned(
            left: 45,
            bottom: 28,
            child: _mapZone(
              emoji: '🏊',
              label: 'Pool',
              color: const Color(0xFFD6ECF5),
              onTap: () => _selectActivity(
                'Swimming Area',
              ),
            ),
          ),

          Positioned(
            right: 40,
            bottom: 28,
            child: _mapZone(
              emoji: '🏋️',
              label: 'Gym',
              color: const Color(0xFFE6DDF3),
              onTap: () => _selectActivity(
                'Fitness Gym',
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 205,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _selectActivity(
                    'Football Ground',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.9,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 78,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 25),
            ),
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

  Widget _buildAreaCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String people,
    required String status,
    required Color statusColor,
    required int xp,
  }) {
    final bool selected =
        activeActivity == title;

    return GestureDetector(
      onTap: () {
        _selectActivity(title);
      },
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
              color: Colors.black.withValues(
                alpha: 0.03,
              ),
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
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style:
                      const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '+$xp XP',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF7545),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  people,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveActivity() {
    final String activity =
        activeActivity ?? 'Activity';

    final int xp = _xpForActivity(activity);

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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: activityStarted
                  ? () => _completeActivity()
                  : () {
                      setState(() {
                        activityStarted = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFFD166),
                foregroundColor:
                    const Color(0xFF302B63),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: Text(
                activityStarted
                    ? 'COMPLETE ACTIVITY'
                    : 'START ACTIVITY',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
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

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!mounted) return;

        Scrollable.ensureVisible(
          context,
          duration:
              const Duration(milliseconds: 300),
        );
      },
    );
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

  void _completeActivity() {
    final String activity =
        activeActivity ?? 'Activity';

    final int reward =
        _xpForActivity(activity);

    widget.appState.addXp(reward);

    setState(() {
      activityStarted = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '🎉 $activity complete! +$reward XP',
          ),
        ),
      );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'FitMap Privacy',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
          content: const Text(
            'FitMap shows general activity levels '
            'around school areas. It does not show '
            'student names or precise student locations.',
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
}