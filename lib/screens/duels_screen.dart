import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../theme/fq_animations.dart';
import 'ai_vision_workout_screen.dart';

class DuelsScreen extends StatefulWidget {
  final AppState appState;

  const DuelsScreen({
    super.key,
    required this.appState,
  });

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeDuels = [
    {
      'id': 'duel_1',
      'opponent': 'Rohan (Ignis House)',
      'avatar': '🦁',
      'exercise': 'Squat Sprint (15 Reps)',
      'exerciseKey': 'Squats',
      'targetReps': 15,
      'pot': 100,
      'myScore': 12,
      'opponentScore': 15,
      'status': 'Opponent Finished! Beat 15 reps to tie/win!',
      'timeRemaining': '3h 14m',
    },
    {
      'id': 'duel_2',
      'opponent': 'Sneha (Terra House)',
      'avatar': '🌿',
      'exercise': 'Jumping Jacks (20 Reps)',
      'exerciseKey': 'Jumping Jacks',
      'targetReps': 20,
      'pot': 200,
      'myScore': 0,
      'opponentScore': 0,
      'status': 'Ready to start! First to finish wins 200 XP.',
      'timeRemaining': '8h 45m',
    },
  ];

  final List<Map<String, dynamic>> _duelHistory = [
    {
      'opponent': 'Arjun (Vayu House)',
      'exercise': 'Push-up Blitz',
      'result': 'VICTORY 🏆',
      'won': true,
      'xpGained': '+100 XP',
      'date': 'Yesterday',
    },
    {
      'opponent': 'Priya (Aqua House)',
      'exercise': '10,000 Step Race',
      'result': 'DEFEAT 💀',
      'won': false,
      'xpGained': '-50 XP',
      'date': '3 days ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateDuelDialog() {
    String selectedExercise = 'Squats';
    int targetReps = 15;
    int selectedWager = 50;
    final opponentController = TextEditingController(text: 'Campus Challenger');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text('⚔️', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text(
                        'Create 1v1 Workout Duel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Challenge Exercise Selector
                  const Text('CHOOSE BATTLE EVENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _choiceChip(
                        label: '🏋️ 15 Squats',
                        selected: selectedExercise == 'Squats',
                        onSelected: () => setModalState(() {
                          selectedExercise = 'Squats';
                          targetReps = 15;
                        }),
                      ),
                      _choiceChip(
                        label: '⭐ 20 Jumping Jacks',
                        selected: selectedExercise == 'Jumping Jacks',
                        onSelected: () => setModalState(() {
                          selectedExercise = 'Jumping Jacks';
                          targetReps = 20;
                        }),
                      ),
                      _choiceChip(
                        label: '💪 10 Push-ups',
                        selected: selectedExercise == 'Push-ups',
                        onSelected: () => setModalState(() {
                          selectedExercise = 'Push-ups';
                          targetReps = 10;
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // XP Wager Selector
                  const Text('XP PRIZE POT WAGER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Row(
                    children: [50, 100, 200].map((wager) {
                      final isSelected = selectedWager == wager;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedWager = wager),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF302B63) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00F5D4) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '+${wager * 2} XP',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF00F5D4) : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Wager $wager',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Launch Challenge Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _activeDuels.insert(0, {
                            'id': 'duel_${DateTime.now().millisecondsSinceEpoch}',
                            'opponent': opponentController.text,
                            'avatar': '⚔️',
                            'exercise': '$selectedExercise ($targetReps Reps)',
                            'exerciseKey': selectedExercise,
                            'targetReps': targetReps,
                            'pot': selectedWager * 2,
                            'myScore': 0,
                            'opponentScore': 0,
                            'status': 'Challenge Sent! Start your set now.',
                            'timeRemaining': '24h 00m',
                          });
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚔️ Duel Created! $selectedWager XP locked in prize pot.'),
                            backgroundColor: const Color(0xFF302B63),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF302B63),
                        foregroundColor: const Color(0xFF00F5D4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'ISSUE 1v1 CHALLENGE ⚡',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _choiceChip({required String label, required bool selected, required VoidCallback onSelected}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF302B63),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF334155),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _startDuelMatch(Map<String, dynamic> duel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiVisionWorkoutScreen(
          appState: widget.appState,
          exerciseName: duel['exerciseKey'] ?? 'Squats',
          targetReps: duel['targetReps'] ?? 15,
          rewardXp: duel['pot'] ?? 100,
          questId: duel['id'] ?? 'duel_match',
        ),
      ),
    ).then((_) {
      setState(() {
        duel['myScore'] = duel['targetReps'];
        duel['status'] = 'MATCH WON! +${duel['pot']} XP Claimed! 🏆';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '1v1 Workout Duels',
          style: TextStyle(
            color: Color(0xFF151B3D),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF151B3D)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF302B63),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF00F5D4),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(text: 'ACTIVE DUELS'),
            Tab(text: 'VICTORY LOG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveDuelsTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDuelDialog,
        backgroundColor: const Color(0xFF302B63),
        foregroundColor: const Color(0xFF00F5D4),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'CHALLENGE FRIEND',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildActiveDuelsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // High Stakes Header Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF302B63).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🥊', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HIGH STAKES ARENA',
                      style: TextStyle(
                        color: Color(0xFF00F5D4),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Wager XP & Prove Your Form',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI Vision verifies reps to eliminate cheating.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ..._activeDuels.asMap().entries.map((entry) {
          final i = entry.key;
          final duel = entry.value;
          return FQFadeSlide(
            index: i,
            child: FQBounce(
              child: _buildDuelCard(duel),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDuelCard(Map<String, dynamic> duel) {
    final int myScore = duel['myScore'] ?? 0;
    final int target = duel['targetReps'] ?? 15;
    final int pot = duel['pot'] ?? 100;
    final bool finished = myScore >= target;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: finished ? const Color(0xFF00F5D4) : const Color(0xFFE2E8F0),
          width: finished ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Opponent Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(duel['avatar'], style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duel['opponent'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        duel['exercise'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFD97706)),
                    Text(
                      'POT: $pot XP',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status & Countdown
          Text(
            duel['status'],
            style: TextStyle(
              color: finished ? const Color(0xFF10B981) : const Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: finished ? null : () => _startDuelMatch(duel),
              style: ElevatedButton.styleFrom(
                backgroundColor: finished ? const Color(0xFF10B981) : const Color(0xFF302B63),
                foregroundColor: finished ? Colors.white : const Color(0xFF00F5D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(finished ? Icons.check_circle_rounded : Icons.camera_alt_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    finished ? 'DUEL COMPLETED ✓' : 'LAUNCH AI CAMERA DUEL ⚔️',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: _duelHistory.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final won = item['won'] as bool;
        return FQFadeSlide(
          index: i,
          child: FQBounce(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['opponent'],
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item['exercise']} • ${item['date']}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: won ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item['result']} (${item['xpGained']})',
                      style: TextStyle(
                        color: won ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
