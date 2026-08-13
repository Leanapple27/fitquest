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
              'Rewards',
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
                  'BADGES',
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

                const SizedBox(height: 24),

                const Text(
                  'UPCOMING REWARDS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 10),

                _buildUpcomingRewards(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardHeader() {
    final int badgeCount = appState.badges;
    final int stickerCount = appState.stickers;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8A3D),
            Color(0xFFFF5E62),
          ],
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
                '🏆 $badgeCount Badges',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '🎟️ $stickerCount Stickers',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '⭐ ${appState.xp} XP',
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

  Widget _buildBadgeGrid() {
    final badges = [
      (
        '🔥',
        'Streak Starter',
        '7 day streak',
        'streak_starter',
      ),
      (
        '🏃',
        'Morning Warrior',
        '1 quest completed',
        'morning_warrior',
      ),
      (
        '💪',
        'Fitness Hero',
        '3 quests completed',
        'fitness_hero',
      ),
      (
        '⭐',
        'XP Explorer',
        'Starter badge',
        'xp_explorer',
      ),
      (
        '🏆',
        'House Champion',
        'Starter badge',
        'house_champion',
      ),
      (
        '🥇',
        'Sports Star',
        '10 quests completed',
        'sports_star',
      ),
      (
        '🌟',
        'XP Master',
        '2,000 XP earned',
        'xp_master',
      ),
      (
        '👑',
        'XP Champion',
        '2,500 XP earned',
        'xp_champion',
      ),
      (
        '🔥',
        'Streak Master',
        '15 day streak',
        'streak_master',
      ),
    ];

    return GridView.builder(
      itemCount: badges.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];

        final bool unlocked =
            appState.unlockedBadges.contains(badge.$4);

        return _buildBadge(
          emoji: badge.$1,
          title: badge.$2,
          subtitle: badge.$3,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFFD166)
              : const Color(0xFFE2E2E8),
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFFFFF0D6)
                      : const Color(0xFFE8E8EE),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                unlocked ? emoji : '🔒',
                style: const TextStyle(fontSize: 27),
              ),
            ],
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
              fontWeight: unlocked
                  ? FontWeight.w900
                  : FontWeight.w700,
              color: unlocked
                  ? const Color(0xFF4B8B57)
                  : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerCollection() {
    final stickers = [
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
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final sticker = stickers[index];

          final bool unlocked =
              appState.unlockedStickers.contains(sticker.$3);

          return Column(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFFF0EFFF)
                      : const Color(0xFFE8E8EE),
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
                  color: unlocked
                      ? const Color(0xFF151B3D)
                      : Colors.black45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingRewards() {
    final rewards = [
      (
        '🏅',
        'Activity Champion',
        'Complete 50 verified activities.',
        _activityProgress(),
      ),
      (
        '👑',
        'Fitness Legend',
        'Reach Level 15.',
        _levelProgress(),
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < rewards.length; i++) ...[
          _buildLockedReward(
            emoji: rewards[i].$1,
            title: rewards[i].$2,
            description: rewards[i].$3,
            progress: rewards[i].$4.$1,
            progressText: rewards[i].$4.$2,
          ),
          if (i < rewards.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }

  (double, String) _activityProgress() {
    // The current AppState does not track verified activity count,
    // so keep this reward informational rather than inventing progress.
    return (
      0.0,
      'Progress tracking coming soon',
    );
  }

  (double, String) _levelProgress() {
    // The current AppState does not contain a level field.
    // XP remains the source of truth until levels are implemented.
    final int currentLevel =
        (appState.xp ~/ 250).clamp(1, 15);

    final double progress =
        (currentLevel / 15).clamp(0.0, 1.0);

    return (
      progress,
      'Level $currentLevel / 15',
    );
  }

  Widget _buildLockedReward({
    required String emoji,
    required String title,
    required String description,
    required double progress,
    required String progressText,
  }) {
    final bool hasProgress =
        progress > 0 && progressText != 'Progress tracking coming soon';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E2E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8EE),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Center(
              child: Text(
                '🔒',
                style: const TextStyle(fontSize: 25),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: hasProgress ? progress : 0,
                    minHeight: 6,
                    backgroundColor:
                        const Color(0xFFE8E8EE),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Color(0xFF51489A),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progressText,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700,
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
