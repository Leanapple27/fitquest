import 'package:flutter/material.dart';

import '../theme/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  final String currentUserName;
  final int currentUserXp;
  final int currentUserGrowth;

  const LeaderboardScreen({
    super.key,
    this.currentUserName = 'You',
    this.currentUserXp = 2340,
    this.currentUserGrowth = 24,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final Set<String> _requestsSent = <String>{};

  late final List<_User> _users = [
    const _User('alex', 'Alex', '@alex.moves', '🏃', 2840, 18, 12, 11,
        'Trying to beat my step record this week.'),
    const _User('sam', 'Sam', '@sam.active', '🏋️', 2690, 12, 15, 11,
        'Competing with myself.'),
    const _User('jordan', 'Jordan', '@jordan.run', '⚽', 2510, 31, 7, 10,
        'Football + fitness.'),
    const _User('maya', 'Maya', '@maya.fit', '🏏', 2420, 35, 9, 10,
        'Small progress every day 🌱'),
    const _User('riya', 'Riya', '@riya.moves', '🏃‍♀️', 2290, 42, 6, 9,
        'Consistency, not perfection.'),
    const _User('arjun', 'Arjun', '@arjun.active', '🏃', 2140, 27, 5, 9,
        'Getting better one day at a time.'),
  ];

  List<_User> get _xpBoard {
    final list = [
      ..._users,
      _User(
          'me',
          widget.currentUserName,
          '@you',
          '🧑‍🎓',
          widget.currentUserXp,
          widget.currentUserGrowth,
          7,
          (widget.currentUserXp ~/ 250) + 1,
          'Keep moving.'),
    ];
    list.sort((a, b) => b.xp.compareTo(a.xp));
    return list;
  }

  List<_User> get _growthBoard {
    final list = [
      ..._users,
      _User(
          'me',
          widget.currentUserName,
          '@you',
          '🧑‍🎓',
          widget.currentUserXp,
          widget.currentUserGrowth,
          7,
          (widget.currentUserXp ~/ 250) + 1,
          'Keep moving.'),
    ];
    list.sort((a, b) => b.growth.compareTo(a.growth));
    return list;
  }

  int _rank(String id, List<_User> board) =>
      board.indexWhere((u) => u.id == id) + 1;

  @override
  Widget build(BuildContext context) {
    final xpRank = _rank('me', _xpBoard);
    final growthRank = _rank('me', _growthBoard);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: DefaultTabController(
        length: 2,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _hero(xpRank, growthRank),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: FqColors.surface,
                borderRadius: FqRadii.buttonBorder,
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: FqColors.lavender,
                  borderRadius: FqRadii.chipBorder,
                ),
                labelColor: FqColors.primary,
                unselectedLabelColor: Colors.black45,
                labelStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                tabs: [
                  Tab(text: 'XP LEADERBOARD'),
                  Tab(text: 'MOST IMPROVED'),
                ],
              ),
            ),
            const SizedBox(height: FqSpacing.label),
            SizedBox(
              height: 530,
              child: TabBarView(
                children: [
                  _board(_xpBoard, false),
                  _board(_growthBoard, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(int xpRank, int growthRank) {
    return Container(
      padding: const EdgeInsets.all(FqSpacing.card),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: FqColors.heroGradient,
        ),
        borderRadius: FqRadii.heroBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMPETE • GROW • SUPPORT',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 7),
          const Text('There is more than one way to win.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Compete through XP or become the most improved.',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _stat('XP RANK', '#$xpRank', Icons.emoji_events)),
            const SizedBox(width: 9),
            Expanded(
                child: _stat(
                    'GROWTH RANK', '#$growthRank', Icons.trending_up_rounded)),
          ]),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(children: [
          Icon(icon, color: FqColors.accent, size: 20),
          const SizedBox(width: 7),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 7,
                    fontWeight: FontWeight.w900)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ]),
        ]),
      );

  Widget _board(List<_User> board, bool growth) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: board.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (_, index) {
        final u = board[index];
        final me = u.id == 'me';
        final rank = index + 1;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: me ? null : () => _openUser(u),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: me ? FqColors.lavender : FqColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              SizedBox(
                width: 32,
                child: rank <= 3
                    ? Text(['🥇', '🥈', '🥉'][rank - 1],
                        style: const TextStyle(fontSize: 20))
                    : Text('$rank',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w900)),
              ),
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FqColors.scaffold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(u.avatar, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(u.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: FqColors.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900)),
                        ),
                        if (me)
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text('YOU',
                                style: TextStyle(
                                    color: FqColors.primary,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900)),
                          ),
                      ]),
                      Text(u.handle,
                          style: const TextStyle(
                              color: Colors.black38, fontSize: 9)),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(growth ? '+${u.growth}%' : '${u.xp} XP',
                    style: TextStyle(
                        color: growth ? FqColors.success : FqColors.energy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text('🔥 ${u.streak}',
                    style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
        );
      },
    );
  }

  void _openUser(_User user) {
    final sent = _requestsSent.contains(user.id);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: FqColors.surface,
          borderRadius: FqRadii.sheetTopBorder,
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: FqRadii.cardBorder),
            ),
            const SizedBox(height: 16),
            Text(user.avatar, style: const TextStyle(fontSize: 48)),
            Text(user.name,
                style: const TextStyle(
                    color: FqColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900)),
            Text(user.handle,
                style: const TextStyle(color: Colors.black45, fontSize: 11)),
            const SizedBox(height: 8),
            Text(user.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _mini('LEVEL', '${user.level}')),
              const SizedBox(width: 7),
              Expanded(child: _mini('XP', '${user.xp}')),
              const SizedBox(width: 7),
              Expanded(child: _mini('STREAK', '${user.streak} 🔥')),
            ]),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sent
                    ? null
                    : () {
                        setState(() => _requestsSent.add(user.id));
                        Navigator.pop(sheet);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Friend request sent to ${user.name}!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: Icon(sent
                    ? Icons.check_rounded
                    : Icons.person_add_alt_1_rounded),
                label: Text(sent ? 'REQUEST SENT' : 'ADD FRIEND'),
                style: FilledButton.styleFrom(
                  backgroundColor: FqColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _mini(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: FqColors.scaffold,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  color: FqColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 7,
                  fontWeight: FontWeight.w900)),
        ]),
      );
}

class _User {
  final String id, name, handle, avatar, bio;
  final int xp, growth, streak, level;

  const _User(this.id, this.name, this.handle, this.avatar, this.xp,
      this.growth, this.streak, this.level, this.bio);
}
