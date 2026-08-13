import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';

class QuestsScreen extends StatefulWidget {
  final AppState appState;

    const QuestsScreen({super.key, required this.appState});

    @override
    State<QuestsScreen> createState() => _QuestsScreenState();
    }

    class _QuestsScreenState extends State<QuestsScreen> {
    final Map<String, double> _progress = {};
    List<QueryDocumentSnapshot<Map<String, dynamic>>> _quests = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> _weeklyQuests = [];
    bool _loading = true;
    String? _error;

    @override
    void initState() {
        super.initState();
        _loadQuests();
    }

    Future<void> _loadQuests() async {
        try {
        await widget.appState.ensureDailyQuestDay();
        final snapshot = await FirebaseFirestore.instance
        .collection('quests')
    .get(const GetOptions(source: Source.server));
        debugPrint('FIRESTORE QUEST COUNT: ${snapshot.docs.length}');

    for (final doc in snapshot.docs) {
    final data = doc.data();
    debugPrint(
    'QUEST RAW: id=${doc.id}, '
    'title=${data['title']}, '
    'active=${data['active']} (${data['active'].runtimeType}), '
    'type=${data['type']} (${data['type'].runtimeType})',
  );
}

     final dailyDocs = snapshot.docs.where((doc) {
  final data = doc.data();

  return data['active'] == true &&
      data['type']?.toString().toLowerCase() == 'daily';
}).toList();

final weeklyDocs = snapshot.docs.where((doc) {
  final data = doc.data();

  debugPrint(
    'WEEKLY CHECK: id=${doc.id}, '
    'title=${data['title']}, '
    'active=${data['active']} (${data['active'].runtimeType}), '
    'type=${data['type']} (${data['type'].runtimeType})',
  );

  return data['active'] == true &&
      data['type']?.toString().toLowerCase() == 'weekly';
}).toList();
for (final doc in dailyDocs) {
  _progress[doc.id] =
      widget.appState.isDailyQuestCompleted(doc.id) ? 1.0 : 0.0;
}

      if (!mounted) return;
      setState(() {
        _quests = dailyDocs;
_weeklyQuests = weeklyDocs;
        _loading = false;
        _error = null;
      });
    } catch (e) {
  debugPrint('QUEST LOAD ERROR: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load quests. Check your internet connection.';
      });
    }
  }

  bool _isCompleted(String id) =>
      widget.appState.isDailyQuestCompleted(id);

  void _startQuest(String id) {
    setState(() {
      if ((_progress[id] ?? 0) == 0) _progress[id] = 0.1;
    });
  }

  void _continueQuest(String id) {
    setState(() {
      final next = (_progress[id] ?? 0) + 0.25;
      _progress[id] = next > 1 ? 1 : next;
    });
  }
void _completeQuest(String id, int xp) {
  if (_isCompleted(id)) return;

  final awarded = widget.appState.completeDynamicQuest(
    questId: id,
    rewardXp: xp,
  );

  if (!awarded) return;

  setState(() => _progress[id] = 1.0);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          widget.appState.weeklyFitnessWarriorCompleted
              ? '+$xp XP earned! 🎉 Weekly Warrior completed! +300 XP 🏆'
              : '+$xp XP earned! 🎉',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    final completed = _quests.where((q) => _isCompleted(q.id)).length;
    final total = _quests.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Daily Quests',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadQuests,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuests,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _buildProgressCard(
              progress: progress,
              completedCount: completed,
              totalQuests: total,
              xp: widget.appState.xp,
            ),
            const SizedBox(height: 20),
            const Text(
              "TODAY'S QUESTS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _messageCard(_error!, 'TRY AGAIN', _loadQuests)
            else if (_quests.isEmpty)
              _messageCard(
                'No daily quests are active right now.',
                'REFRESH',
                _loadQuests,
              )
            else
              ..._questWidgets(),
            const SizedBox(height: 24),
            _bonusQuestCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _questWidgets() {
    final widgets = <Widget>[];
    for (var i = 0; i < _quests.length; i++) {
      final data = _quests[i].data();
      final title = data['title'] as String? ?? 'Daily Quest';
      final description = data['description'] as String? ??
          "Complete today's fitness challenge.";
      final icon = data['icon'] as String? ?? '🎯';
      final xp = (data['xp'] as num?)?.toInt() ?? 0;

      if (i > 0) widgets.add(const SizedBox(height: 14));
      widgets.add(
        _questCard(
          questId: _quests[i].id,
          emoji: icon,
          title: title,
          description: description,
          xp: xp,
        ),
      );
        }

    // -----------------------------
    // WEEKLY CHALLENGES
    // -----------------------------

    widgets.add(const SizedBox(height: 28));

    widgets.add(
      const Text(
        'WEEKLY CHALLENGE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          color: Colors.black45,
        ),
      ),
    );

    widgets.add(const SizedBox(height: 12));

    if (_weeklyQuests.isEmpty) {
      widgets.add(
        _messageCard(
          'No weekly challenge available right now.',
          'REFRESH',
          _loadQuests,
        ),
      );
    } else {
      for (var i = 0; i < _weeklyQuests.length; i++) {
        final data = _weeklyQuests[i].data();

        final title =
            data['title'] as String? ?? 'Weekly Challenge';

        final description = data['description'] as String? ??
            'Complete this week\'s fitness challenge.';

        final icon = data['icon'] as String? ?? '🏆';

        final xp = (data['xp'] as num?)?.toInt() ?? 0;

        widgets.add(
          _weeklyQuestPreviewCard(
            questId: _weeklyQuests[i].id,
            emoji: icon,
            title: title,
            description: description,
            xp: xp,
          ),
        );

        if (i < _weeklyQuests.length - 1) {
          widgets.add(const SizedBox(height: 14));
        }
      }
    }

    return widgets;
  }
Widget _weeklyQuestPreviewCard({
  required String questId,
  required String emoji,
  required String title,
  required String description,
  required int xp,
}) {
  final progress = widget.appState.weeklyFitnessActivities;
  final completed =
      widget.appState.weeklyFitnessWarriorCompleted;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                completed
                    ? '5 / 5 activities ✓'
                    : '$progress / 5 activities',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 5) / 5,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                completed ? 'COMPLETED • +$xp XP' : '+$xp XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),

            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _messageCard(
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 42,
            color: Color(0xFF302B63),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required double progress,
    required int completedCount,
    required int totalQuests,
    required int xp,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF51489A)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S PROGRESS",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedCount / $totalQuests',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD166),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$xp XP total',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).round()}% of today's quests complete",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questCard({
    required String questId,
    required String emoji,
    required String title,
    required String description,
    required int xp,
  }) {
    final completed = _isCompleted(questId);
    final current = _progress[questId] ?? 0;
    final started = current > 0;

    final buttonText = completed
        ? 'COMPLETED ✓'
        : !started
            ? 'START QUEST'
            : current < 1
                ? 'CONTINUE QUEST'
                : 'COMPLETE QUEST';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFEAF6EE)
                      : const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    completed ? '✅' : emoji,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+$xp XP',
                style: const TextStyle(
                  color: Color(0xFFFF7545),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (started && !completed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: current),
                ),
                const SizedBox(width: 10),
                Text('${(current * 100).round()}%'),
              ],
            ),
          ],
          if (completed) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '✓ Quest completed! XP added once.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF27733A),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: completed
                  ? null
                  : () {
                      if (!started) {
                        _startQuest(questId);
                      } else if (current < 1) {
                        _continueQuest(questId);
                      } else {
                        _completeQuest(questId, xp);
                      }
                    },
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonusQuestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: const Row(
        children: [
          Text('🏆', style: TextStyle(fontSize: 35)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekend Champion',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Complete 60 minutes of activity this weekend.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '+250 XP',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF7545),
            ),
          ),
        ],
      ),
    );
  }
}
