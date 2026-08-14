import 'package:flutter/material.dart';
import '../app_state.dart';

class RewardsScreen extends StatelessWidget {
  final AppState appState;

  const RewardsScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: const Text(
              'Rewards & Achievements',
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
                _buildRewardHeader(),
                const SizedBox(height: 22),
                const Text(
                  'ACHIEVEMENTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 10),
                _buildBadgeGrid(),
                const SizedBox(height: 24),
                const Text(
                  'YOUR PROGRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProgressCards(),
                const SizedBox(height: 24),
                const Text(
                  'STICKER COLLECTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStickerCollection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A3D), Color(0xFFFF5E62)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR COLLECTION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep moving,\nkeep unlocking! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '🏆 ${appState.badges} Badges',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '🎟️ ${appState.stickers} Stickers',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '⭐ ${appState.xp} XP • Level ${appState.currentLevel}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<_Achievement> _achievements() {
    return const [
      _Achievement('🔥', 'Streak Starter', '7 day streak', 'streak_starter'),
      _Achievement('🏃', 'First Quest', 'Complete 1 quest', 'morning_warrior'),
      _Achievement('💪', 'Fitness Hero', 'Complete 3 quests', 'fitness_hero'),
      _Achievement('⭐', 'XP Explorer', 'Starter badge', 'xp_explorer'),
      _Achievement('🏆', 'House Champion', 'Starter badge', 'house_champion'),
      _Achievement('🥇', 'Sports Star', 'Complete 10 quests', 'sports_star'),
      _Achievement('🌟', 'XP Master', 'Earn 2,000 XP', 'xp_master'),
      _Achievement('👑', 'XP Champion', 'Earn 2,500 XP', 'xp_champion'),
      _Achievement('🔥', 'Streak Master', '15 day streak', 'streak_master'),
      _Achievement('⚔️', 'Weekly Warrior', 'Complete the weekly fitness goal', 'weekly_warrior'),
      _Achievement('🧠', 'Quiz Master', 'Complete a quiz', 'quiz_master'),
      _Achievement('🤝', 'Community Hero', 'Complete a community challenge', 'community_hero'),
      _Achievement('🚀', 'Level 5', 'Reach Level 5', 'level_5'),
      _Achievement('🌠', 'Level 10', 'Reach Level 10', 'level_10'),
      _Achievement('🔥', 'Streak Legend', '30 day streak', 'streak_legend'),
    ];
  }

  Widget _buildBadgeGrid() {
    final badges = _achievements();

    return GridView.builder(
      itemCount: badges.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        final unlocked = appState.unlockedBadges.contains(badge.id);

        return _buildBadge(
          emoji: badge.emoji,
          title: badge.title,
          subtitle: badge.subtitle,
          unlocked: unlocked,
        );
      },
    );
  }

  Widget _buildBadge({
    required String emoji,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? const Color(0xFFFFD166) : const Color(0xFFE2E2E8),
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFFFFF0D6) : const Color(0xFFE8E8EE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                unlocked ? emoji : '🔒',
                style: const TextStyle(fontSize: 27),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            unlocked ? 'UNLOCKED' : subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: unlocked ? FontWeight.w900 : FontWeight.w700,
              color: unlocked ? const Color(0xFF4B8B57) : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards() {
    return Column(
      children: [
        _progressCard('🎯', 'Quests', appState.completedQuests, 10,
            '${appState.completedQuests} / 10 quests'),
        const SizedBox(height: 10),
        _progressCard('🔥', 'Streak', appState.streak, 30,
            '${appState.streak} / 30 days'),
        const SizedBox(height: 10),
        _progressCard('⚔️', 'Weekly Fitness', appState.weeklyFitnessActivities,
            5, '${appState.weeklyFitnessActivities} / 5 activities'),
        const SizedBox(height: 10),
        _progressCard('⭐', 'XP', appState.xp, 2500,
            '${appState.xp} / 2,500 XP'),
      ],
    );
  }

  Widget _progressCard(
    String emoji,
    String title,
    int value,
    int goal,
    String label,
  ) {
    final progress = (value / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 23)),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF151B3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8E8EE),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF51489A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerCollection() {
    const stickers = [
      ('⚡', 'Speedster', 'speedster'),
      ('🌟', 'Super Star', 'super_star'),
      ('🚀', 'Go Getter', 'go_getter'),
      ('🦁', 'Brave', 'brave'),
      ('🐯', 'Team Player', 'team_player'),
      ('🌈', 'Positive', 'positive'),
      ('🔥', 'On Fire', 'on_fire'),
      ('💎', 'Rare', 'rare'),
      ('🎯', 'Focused', 'focused'),
      ('❤️', 'Healthy', 'healthy'),
      ('🥳', 'Celebration', 'celebration'),
      ('🏃', 'Runner', 'runner'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stickers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final sticker = stickers[index];
          final unlocked = appState.unlockedStickers.contains(sticker.$3);

          return Column(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: unlocked ? const Color(0xFFF0EFFF) : const Color(0xFFE8E8EE),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(
                    unlocked ? sticker.$1 : '🔒',
                    style: const TextStyle(fontSize: 27),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                unlocked ? sticker.$2 : 'Locked',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: unlocked ? const Color(0xFF151B3D) : Colors.black45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Achievement {
  final String emoji;
  final String title;
  final String subtitle;
  final String id;

  const _Achievement(
    this.emoji,
    this.title,
    this.subtitle,
    this.id,
  );
}
