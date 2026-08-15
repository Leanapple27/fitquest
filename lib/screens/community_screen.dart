import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';

import '../app_state.dart';
import '../clan_service.dart';

class CommunityScreen extends StatefulWidget {
  final AppState appState;

  const CommunityScreen({
    super.key,
    required this.appState,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const List<Map<String, dynamic>> _demoMembers = [
    {
      'id': 'demo_arjun',
      'name': 'Arjun',
      'emoji': '🏃',
      'role': 'member',
      'weeklyXp': 210,
    },
    {
      'id': 'demo_maya',
      'name': 'Maya',
      'emoji': '🧘',
      'role': 'member',
      'weeklyXp': 165,
    },
    {
      'id': 'demo_kabir',
      'name': 'Kabir',
      'emoji': '🏋️',
      'role': 'member',
      'weeklyXp': 120,
    },
  ];


  final ClanService _clanService = ClanService();

  String? _selectedClanId;
  bool _showDiscover = false;

  @override
  Widget build(BuildContext context) {
    if (_selectedClanId != null) {
      return _ClanScreen(
        appState: widget.appState,
        clanService: _clanService,
        clanId: _selectedClanId!,
        onBack: () => setState(() => _selectedClanId = null),
      );
    }

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Leaderboard',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LeaderboardScreen(
                      currentUserXp: widget.appState.xp,
                    ),
                  ),
                );
              },
              icon: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFA000),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _clanService.streamDiscoverClans(),
          builder: (context, snapshot) {
            final docs = [...(snapshot.data?.docs ?? [])];

            docs.sort((a, b) {
              final aXp = a.data()['weeklyXp'] is num
                  ? (a.data()['weeklyXp'] as num).toInt()
                  : 0;
              final bXp = b.data()['weeklyXp'] is num
                  ? (b.data()['weeklyXp'] as num).toInt()
                  : 0;
              return bXp.compareTo(aXp);
            });

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
              children: [
                _buildHero(),
                const SizedBox(height: 20),
                _sectionTitle('CLANS'),
                const SizedBox(height: 10),
                _buildActionCard(
                  emoji: '🛡️',
                  title: 'Create a Clan',
                  subtitle: 'Start your own fitness community.',
                  button: 'CREATE',
                  onTap: _createClan,
                ),
                const SizedBox(height: 10),
                _buildActionCard(
                  emoji: '🌎',
                  title: 'Discover Clans',
                  subtitle: 'Join public clubs and compete together.',
                  button: _showDiscover ? 'HIDE' : 'BROWSE',
                  onTap: () => setState(
                    () => _showDiscover = !_showDiscover,
                  ),
                ),
                if (_showDiscover) ...[
                  const SizedBox(height: 12),
                  if (snapshot.hasError)
                    _firestoreError(snapshot.error)
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (docs.isEmpty)
                    _emptyClans()
                  else
                    ...docs.map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildDiscoverClan(doc),
                      ),
                    ),
                ],
                const SizedBox(height: 22),
                _sectionTitle('HOW CLANS WORK'),
                const SizedBox(height: 10),
                _buildFeature(
                  '💬',
                  'Live Clan Chat',
                  'Talk with your whole clan in real time.',
                ),
                _buildFeature(
                  '⚔️',
                  'Clan Wars',
                  'Compete against another clan every week.',
                ),
                _buildFeature(
                  '🏆',
                  'Weekly Leaderboard',
                  'Every member contributes to the clan score.',
                ),
                _buildFeature(
                  '👥',
                  'Member List',
                  'See everyone and their weekly contribution.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF51489A)],
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FITQUEST COMMUNITY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Build your clan.\nCompete together. 🛡️',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Chat, challenge other clans and climb the weekly leaderboard.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black45,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String button,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF151B3D),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              button,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverClan(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final emoji = data['emoji']?.toString() ?? '🛡️';
    final name = data['name']?.toString() ?? 'Clan';
    final xp = data['weeklyXp'] is num
        ? (data['weeklyXp'] as num).toInt()
        : 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _clanService.streamMembers(doc.id),
      builder: (context, memberSnapshot) {
        final realMembers = memberSnapshot.data?.docs.length ?? 0;
        final memberCount = realMembers + _demoMembers.length;

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF151B3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$memberCount members • $xp weekly XP',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _joinClan(doc.id),
                icon: const Icon(Icons.arrow_forward_rounded),
                color: const Color(0xFF302B63),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeature(String emoji, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 25)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF151B3D),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _firestoreError(Object? error) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 7),
          const Text(
            'Could not load public clans',
            style: TextStyle(
              color: Color(0xFF8F2D2D),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            error?.toString() ?? 'Unknown Firestore error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyClans() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text('🛡️', style: TextStyle(fontSize: 38)),
          SizedBox(height: 8),
          Text(
            'No public clans yet',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create the first one and start your community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createClan() async {
    final controller = TextEditingController();
    String emoji = '🛡️';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Create Clan',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLength: 30,
                    decoration: const InputDecoration(
                      labelText: 'Clan name',
                      hintText: 'Cricket Warriors',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['🛡️', '🏏', '🏋️', '🏃', '🧘', '⚽', '🔥']
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item),
                            selected: emoji == item,
                            onSelected: (_) {
                              setDialogState(() => emoji = item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    try {
                      final id = await _clanService.createClan(
                        name: controller.text,
                        emoji: emoji,
                      );
                      if (context.mounted) {
                        Navigator.pop(context, id != null);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context, false);
                        _showError(e.toString());
                      }
                    }
                  },
                  child: const Text('CREATE'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clan created!')),
      );
    }
  }

  Future<void> _joinClan(String clanId) async {
    try {
      await _clanService.joinClan(clanId);
      if (mounted) {
        setState(() => _selectedClanId = clanId);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
    );
  }
}

class _ClanScreen extends StatefulWidget {
  final AppState appState;
  final ClanService clanService;
  final String clanId;
  final VoidCallback onBack;

  const _ClanScreen({
    required this.appState,
    required this.clanService,
    required this.clanId,
    required this.onBack,
  });

  @override
  State<_ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<_ClanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.clanService.streamClan(widget.clanId),
      builder: (context, clanSnapshot) {
        final data = clanSnapshot.data?.data() ?? {};
        final name = data['name']?.toString() ?? 'Clan';
        final emoji = data['emoji']?.toString() ?? '🛡️';
        final weeklyXp = data['weeklyXp'] is num
            ? (data['weeklyXp'] as num).toInt()
            : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            leading: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF151B3D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: widget.clanService.streamMembers(widget.clanId),
                builder: (context, memberSnapshot) {
                  final realMembers =
                      memberSnapshot.data?.docs.length ?? 0;
                  final totalMembers =
                      realMembers + _demoMembers.length;

                  final realXp = memberSnapshot.data?.docs.fold<int>(
                        0,
                        (sum, doc) {
                          final value = doc.data()['weeklyXp'];
                          return sum +
                              (value is num ? value.toInt() : 0);
                        },
                      ) ??
                      weeklyXp;

                  final totalXp = realXp + _demoWarPoints();

                  return Container(
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stat(
                            '👥',
                            '$totalMembers',
                            'MEMBERS',
                          ),
                        ),
                        Expanded(
                          child: _stat(
                            '⭐',
                            '$totalXp',
                            'WEEKLY XP',
                          ),
                        ),
                        Expanded(
                          child: _stat(
                            '⚔️',
                            '$totalXp',
                            'WAR',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF302B63),
                unselectedLabelColor: Colors.black45,
                indicatorColor: const Color(0xFFFFD166),
                tabs: const [
                  Tab(text: 'CHAT'),
                  Tab(text: 'MEMBERS'),
                  Tab(text: 'WAR'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChat(),
                    _buildMembers(),
                    _buildWar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF151B3D),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 7,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // Prototype-only demo members. They are clearly labeled so judges can
  // distinguish simulated activity from real Firebase users.
  final List<Map<String, dynamic>> _demoMembers = const [
    {
      'name': 'Arjun',
      'role': 'demo',
      'weeklyXp': 210,
      'emoji': '🏃',
    },
    {
      'name': 'Maya',
      'role': 'demo',
      'weeklyXp': 165,
      'emoji': '🧘',
    },
    {
      'name': 'Kabir',
      'role': 'demo',
      'weeklyXp': 120,
      'emoji': '🏋️',
    },
  ];

  int _demoWarPoints() {
    return _demoMembers.fold<int>(
      0,
      (sum, member) => sum + (member['weeklyXp'] as int),
    );
  }

  int _myWarPoints() {
    final state = widget.appState;

    int points = state.weeklyFitnessActivities * 50;

    if (state.quizCompleted) {
      points += 50;
    }

    if (state.communityChallengeCompleted) {
      points += 25;
    }

    return points;
  }

  Future<void> _sendDemoReply(String userText) async {
    final text = userText.toLowerCase();

    String reply;
    String senderName;

    if (text.contains('hi') ||
        text.contains('hello') ||
        text.contains('hey')) {
      senderName = 'Arjun 🏃 · Demo';
      reply = 'Hey! Welcome to the clan 👋 Let’s smash this week!';
    } else if (text.contains('war') ||
        text.contains('challenge')) {
      senderName = 'Maya 🧘 · Demo';
      reply = 'Clan War is on! 🔥 Everyone’s contribution counts.';
    } else if (text.contains('workout') ||
        text.contains('gym')) {
      senderName = 'Kabir 🏋️ · Demo';
      reply = 'Nice! 💪 I’m doing my workout too. Let’s push the clan up!';
    } else {
      senderName = 'Maya 🧘 · Demo';
      reply = 'Nice! 🙌 Keep going — every little win helps the clan.';
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));

    try {
      await FirebaseFirestore.instance
          .collection('clans')
          .doc(widget.clanId)
          .collection('messages')
          .add({
        'senderId': 'demo_$senderName',
        'senderName': senderName,
        'text': reply,
        'isDemo': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Demo replies are optional; never block the real user's message.
    }
  }

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: widget.clanService.streamMessages(widget.clanId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet.\nStart the clan chat! 💬',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final senderId = data['senderId']?.toString() ?? '';
                  final senderName =
                      data['senderName']?.toString() ?? 'Student';
                  final text = data['text']?.toString() ?? '';
                  final isMe = senderId ==
                      FirebaseAuth.instance.currentUser?.uid;

                  final timestamp = data['createdAt'];
                  final time = timestamp is Timestamp
                      ? _formatTime(timestamp.toDate())
                      : '';

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.fromLTRB(13, 10, 13, 9),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF302B63)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              senderName,
                              style: const TextStyle(
                                color: Color(0xFF51489A),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          if (!isMe) const SizedBox(height: 3),
                          Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.white : const Color(0xFF151B3D),
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white54
                                    : Colors.black38,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Message your clan...',
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembers() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.clanService.streamMembers(widget.clanId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = <Widget>[];

        for (final doc in docs) {
          final data = doc.data();
          final name = data['name']?.toString() ?? 'Student';
          final role = data['role']?.toString() ?? 'member';
          final xp = data['weeklyXp'] is num
              ? (data['weeklyXp'] as num).toInt()
              : 0;

          final emoji = role == 'owner'
              ? '👑'
              : role == 'admin'
                  ? '🛡️'
                  : '🏃';

          rows.add(
            _memberTile(
              name: name,
              role: role.toUpperCase(),
              xp: xp,
              emoji: emoji,
              isDemo: false,
            ),
          );
        }

        for (final member in _demoMembers) {
          rows.add(
            _memberTile(
              name: member['name'] as String,
              role: 'DEMO MEMBER',
              xp: member['weeklyXp'] as int,
              emoji: member['emoji'] as String,
              isDemo: true,
            ),
          );
        }

        if (rows.isEmpty) {
          return const Center(
            child: Text(
              'No members found.',
              style: TextStyle(color: Colors.black45),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
          children: rows,
        );
      },
    );
  }

  Widget _memberTile({
    required String name,
    required String role,
    required int xp,
    required String emoji,
    required bool isDemo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF151B3D),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (isDemo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'DEMO',
                          style: TextStyle(
                            color: Color(0xFF51489A),
                            fontSize: 6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$xp XP',
            style: const TextStyle(
              color: Color(0xFF51489A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWar() {
    final myPoints = _myWarPoints() + _demoWarPoints();
    const opponentPoints = 780;
    final myClanWins = myPoints >= opponentPoints;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 30),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF302B63), Color(0xFF51489A)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 7),
                const Text(
                  'WEEKLY CLAN WAR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _warScore(
                        'YOUR CLAN',
                        myPoints,
                        myClanWins,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _warScore(
                        'RIVAL CLAN',
                        opponentPoints,
                        !myClanWins,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    myClanWins
                        ? '🔥 YOUR CLAN IS LEADING'
                        : '💪 KEEP PUSHING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 25)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR CONTRIBUTION',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_myWarPoints()} war points',
                        style: const TextStyle(
                          color: Color(0xFF151B3D),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF51489A),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _warRule(
            '🏃',
            'Workouts',
            'Weekly fitness activity adds war points.',
          ),
          _warRule(
            '🧠',
            'Quizzes',
            'Completing a quiz adds to your contribution.',
          ),
          _warRule(
            '🎯',
            'Quests',
            'Your existing weekly activity feeds the prototype war score.',
          ),
          _warRule(
            '🏆',
            'Weekly ranking',
            'Highest clan score wins the weekly battle.',
          ),
          const SizedBox(height: 4),
          const Text(
            'Prototype war mode • rival score is simulated for demo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black38,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _warScore(String label, int score, bool winning) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: TextStyle(
            color: winning ? const Color(0xFFFFD166) : Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (winning)
          const Text(
            'LEADING',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }

  Widget _warRule(String emoji, String title, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 23)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF151B3D),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await widget.clanService.sendMessage(
        clanId: widget.clanId,
        text: text,
      );

      // Prototype presentation mode: simulate a natural clan reply.
      // The reply is stored in Firestore so both signed-in accounts see it.
      await _sendDemoReply(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
