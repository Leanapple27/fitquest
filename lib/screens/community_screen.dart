import 'package:flutter/material.dart';
import '../app_state.dart';

class CommunityScreen extends StatefulWidget {
  final AppState appState;

  const CommunityScreen({
    super.key,
    required this.appState,
  });

  @override
  State<CommunityScreen> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState
    extends State<CommunityScreen> {
  bool challengeJoined = false;
  bool challengeCompleted = false;

  @override
  void initState() {
    super.initState();

    challengeCompleted =
        widget.appState.communityChallengeCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: const Text(
              'Community',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _showSafetyInfo,
                icon: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF302B63),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),

                const SizedBox(height: 20),

                const Text(
                  'YOUR HOUSE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildHouseCard(),

                const SizedBox(height: 22),

                const Text(
                  'SCHOOL CHALLENGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildChallengeCard(),

                const SizedBox(height: 22),

                const Text(
                  'SCHOOL GROUPS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildGroupCard(
                  emoji: '🏃',
                  title: 'Running Club',
                  subtitle:
                      'Train together • Share encouragement',
                  members: '12 members',
                ),

                const SizedBox(height: 12),

                _buildGroupCard(
                  emoji: '🏀',
                  title: 'Basketball Squad',
                  subtitle:
                      'Practice • Challenges • Team spirit',
                  members: '18 members',
                ),

                const SizedBox(height: 12),

                _buildGroupCard(
                  emoji: '🧘',
                  title: 'Wellness Club',
                  subtitle:
                      'Stretching • Mindfulness • Healthy habits',
                  members: '9 members',
                ),

                const SizedBox(height: 20),

                _buildSafetyCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
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
      child: Row(
        children: [
          const Text(
            '💬',
            style: TextStyle(fontSize: 40),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'School Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Encourage. Compete. Grow together.',
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

  Widget _buildHouseCard() {
    final int studentXp =
        widget.appState.xp;

    final int houseXp =
        4820 + studentXp;

    return GestureDetector(
      onTap: _showHouseDetails,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D6),
                borderRadius:
                    BorderRadius.circular(17),
              ),
              child: const Center(
                child: Text(
                  '🏠',
                  style: TextStyle(fontSize: 29),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phoenix House',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '23 members • $houseXp XP this week',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Your contribution: $studentXp XP',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF51489A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard() {
    const int phoenixBaseXp = 4820;
    const int tigerXp = 4210;

    final int phoenixXp =
        phoenixBaseXp + widget.appState.xp;

    final double progress =
        phoenixXp / (phoenixXp + tigerXp);

    final bool phoenixLeading =
        phoenixXp >= tigerXp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD166),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: 24),
              ),

              SizedBox(width: 8),

              Text(
                'House Challenge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Phoenix House vs Tiger House',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _scoreColumn(
                  '🔥',
                  'Phoenix',
                  '$phoenixXp XP',
                ),
              ),

              const Text(
                'VS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black38,
                ),
              ),

              Expanded(
                child: _scoreColumn(
                  '🐯',
                  'Tiger',
                  '$tigerXp XP',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.black12,
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Color(0xFFFFA726),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              phoenixLeading
                  ? 'Phoenix House is currently leading!'
                  : 'Tiger House is currently leading!',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed:
                  widget.appState.communityChallengeCompleted
                      ? null
                      : challengeJoined
                          ? _completeChallenge
                          : _joinChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF302B63),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFE7E7ED),
                disabledForegroundColor:
                    Colors.black45,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
              child: Text(
                widget.appState.communityChallengeCompleted
                    ? 'CHALLENGE COMPLETED ✓'
                    : challengeJoined
                        ? 'COMPLETE CHALLENGE'
                        : 'JOIN CHALLENGE',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          if (widget.appState.communityChallengeCompleted) ...[
            const SizedBox(height: 10),
            _buildCompletedChallengeStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedChallengeStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB9DFC1),
        ),
      ),
      child: const Row(
        children: [
          Text(
            '✓',
            style: TextStyle(
              color: Color(0xFF27733A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Challenge completed. Your +50 XP reward has already been claimed.',
              style: TextStyle(
                color: Color(0xFF27733A),
                fontSize: 10,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreColumn(
    String emoji,
    String name,
    String score,
  ) {
    return Column(
      children: [
        Text(
          emoji,
          style:
              const TextStyle(fontSize: 27),
        ),

        const SizedBox(height: 5),

        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF151B3D),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          score,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String members,
  }) {
    return GestureDetector(
      onTap: () {
        _showGroupDetails(
          title,
          subtitle,
          members,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
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
                      const TextStyle(fontSize: 27),
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

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    members,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF51489A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            color: Color(0xFF302B63),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe school community',
                  style: TextStyle(
                    color: Color(0xFF302B63),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Community spaces are school-only. '
                  'Students can report inappropriate content, '
                  'and teachers can moderate school groups.',
                  style: TextStyle(
                    color: Color(0xFF51489A),
                    fontSize: 11,
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

  void _joinChallenge() {
    setState(() {
      challengeJoined = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            '🔥 You joined the House Challenge!',
          ),
        ),
      );
  }

   void _completeChallenge() {
    if (widget.appState.communityChallengeCompleted) {
      return;
    }

    final bool awarded =
        widget.appState.completeCommunityChallenge();

    if (!awarded) {
      return;
    }

    setState(() {
      challengeCompleted = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '🎉 Challenge completed! +50 XP',
          ),
        ),
      );
  }

  void _showHouseDetails() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔥 Phoenix House',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Work together, stay active, '
                'and help your house climb the leaderboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Your contribution: ${widget.appState.xp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF51489A),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('DONE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGroupDetails(
    String title,
    String subtitle,
    String members,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF151B3D),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                members,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF51489A),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Group joining will be connected '
                'to the school community system later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSafetyInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Community Safety',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
          content: const Text(
            'FitQuest community areas are designed '
            'for school use. No precise student '
            'locations are displayed. In a full '
            'production version, reports and teacher '
            'moderation would be connected to the '
            'school administration system.',
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