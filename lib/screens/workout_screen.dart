import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/fq_animations.dart';
import 'posture_correction_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final AppState appState;

  const WorkoutScreen({
    super.key,
    required this.appState,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<String> _categories = [
    'All',
    'Full Body',
    'Abs & Core',
    'Legs',
    'Arms',
    'HIIT',
    'Yoga',
    'Gym',
    'No Equipment',
    'Stretching',
  ];

  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Moderate',
    'Hard',
  ];

  final Set<String> _completedProgramDays = {};

  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  @override
  Widget build(BuildContext context) {
    final workouts = _filteredWorkouts();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Workout Center',
          style: TextStyle(
            color: Color(0xFF151B3D),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF151B3D),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 16),
          _buildPostureLabBanner(),
          const SizedBox(height: 24),
          _buildSectionTitle('FITNESS PROGRAMS'),
          const SizedBox(height: 12),
          _buildProgramsSection(),
          const SizedBox(height: 26),
          _buildSectionTitle('CHOOSE YOUR LEVEL'),
          const SizedBox(height: 12),
          _buildDifficultySelector(),
          const SizedBox(height: 24),
          _buildSectionTitle('WORKOUT TYPE'),
          const SizedBox(height: 12),
          _buildCategorySelector(),
          const SizedBox(height: 24),
          _buildSectionTitle('AVAILABLE WORKOUTS'),
          const SizedBox(height: 12),
          if (workouts.isEmpty)
            _buildEmptyState()
          else
            ...workouts.map(
              (workout) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildWorkoutCard(workout),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostureLabBanner() {
    return FQBounce(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostureCorrectionScreen(appState: widget.appState),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00F5D4).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF302B63).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🔬', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F5D4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW AI FEATURE',
                          style: TextStyle(
                            color: Color(0xFF0F0C29),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Joint Tracking',
                        style: TextStyle(color: Color(0xFF00F5D4), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Posture & Form Correction Lab',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Check squat depth, push-up alignment & tech-neck',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00F5D4), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FITQUEST WORKOUTS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Move. Play. Level Up. 💪',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a workout or follow a structured fitness program.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStat('⏱️', 'Timed'),
              const SizedBox(width: 10),
              _heroStat('⭐', 'XP'),
              const SizedBox(width: 10),
              _heroStat('🔥', 'Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Colors.black45,
      ),
    );
  }

  // ============================================================
  // PROGRAMS
  // ============================================================

  Widget _buildProgramsSection() {
    return SizedBox(
      height: 185,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _programs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildProgramCard(_programs[index]);
        },
      ),
    );
  }

  Widget _buildProgramCard(_WorkoutProgram program) {
    final completedCount = _programCompletedCount(program);
    final progress = completedCount / program.days.length;

    return GestureDetector(
      onTap: () => _openProgram(program),
      child: Container(
        width: 275,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              program.color,
              program.color.withValues(alpha: 0.72),
            ],
          ),
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: program.color.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      program.emoji,
                      style: const TextStyle(fontSize: 27),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${program.days.length} DAYS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              program.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              program.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  '$completedCount/${program.days.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _programCompletedCount(_WorkoutProgram program) {
    var count = 0;

    for (var i = 0; i < program.days.length; i++) {
      if (_completedProgramDays.contains(
        '${program.id}_$i',
      )) {
        count++;
      }
    }

    return count;
  }

  _WorkoutPlan? _findWorkout(String title) {
    for (final workout in _workouts) {
      if (workout.title == title) {
        return workout;
      }
    }

    return null;
  }

  void _openProgram(_WorkoutProgram program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6FA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: program.color.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Center(
                            child: Text(
                              program.emoji,
                              style: const TextStyle(fontSize: 31),
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
                                program.title,
                                style: const TextStyle(
                                  color: Color(0xFF151B3D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                program.description,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildProgramProgress(program),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${program.days.length}-DAY JOURNEY',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: program.days.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildProgramDayTile(
                            program,
                            index,
                            setModalState,
                            sheetContext,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgramProgress(_WorkoutProgram program) {
    final completed = _programCompletedCount(program);
    final progress = completed / program.days.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'PROGRAM PROGRESS',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '$completed / ${program.days.length}',
                style: const TextStyle(
                  color: Color(0xFF302B63),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black12,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                program.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramDayTile(
    _WorkoutProgram program,
    int index,
    StateSetter setModalState,
    BuildContext sheetContext,
  ) {
    final dayNumber = index + 1;
    final dayKey = '${program.id}_$index';

    final completed =
        _completedProgramDays.contains(dayKey);

    final unlocked =
        index == 0 ||
        _completedProgramDays.contains(
          '${program.id}_${index - 1}',
        );

    final workoutTitle = program.days[index];
    final workout = _findWorkout(workoutTitle);

    final isToday = unlocked && !completed;

    return GestureDetector(
      onTap: !unlocked || workout == null
          ? null
          : () {
              Navigator.pop(sheetContext);

              _openProgramWorkout(
                program,
                index,
                workout,
              );
            },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: completed
              ? const Color(0xFFEAF6EE)
              : isToday
                  ? Colors.white
                  : const Color(0xFFECECF1),
          borderRadius: BorderRadius.circular(16),
          border: isToday
              ? Border.all(
                  color: program.color.withValues(
                    alpha: 0.45,
                  ),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFF36A269)
                    : isToday
                        ? program.color
                        : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : unlocked
                        ? Text(
                            '$dayNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          )
                        : const Icon(
                            Icons.lock_rounded,
                            color: Colors.black38,
                            size: 18,
                          ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY $dayNumber',
                    style: TextStyle(
                      color: completed
                          ? const Color(0xFF27733A)
                          : isToday
                              ? program.color
                              : Colors.black45,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    workoutTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: completed || isToday
                          ? const Color(0xFF151B3D)
                          : Colors.black45,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (completed)
              const Text(
                'DONE',
                style: TextStyle(
                  color: Color(0xFF27733A),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              )
            else if (isToday)
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFF302B63),
                size: 27,
              )
            else
              const Icon(
                Icons.lock_outline_rounded,
                color: Colors.black26,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _openProgramWorkout(
    _WorkoutProgram program,
    int index,
    _WorkoutPlan workout,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WorkoutSessionScreen(
          workout: workout,
          appState: widget.appState,
          onCompleted: () {
            if (!mounted) return;

            setState(() {
              _completedProgramDays.add(
                '${program.id}_$index',
              );
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildDifficultySelector() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _difficulties.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final difficulty = _difficulties[index];
          final selected =
              _selectedDifficulty == difficulty;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficulty = difficulty;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 17),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF302B63)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Row(
                  children: [
                    if (difficulty != 'All') ...[
                      Text(
                        _difficultyEmoji(difficulty),
                        style:
                            const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      difficulty,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF151B3D),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected =
              _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF7545)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF151B3D),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WORKOUT LIST
  // ============================================================

  Widget _buildWorkoutCard(_WorkoutPlan workout) {
    return GestureDetector(
      onTap: () => _openWorkoutPreview(workout),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color:
                    workout.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  workout.emoji,
                  style:
                      const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(
                      color: Color(0xFF151B3D),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    workout.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    children: [
                      _smallTag(
                        workout.difficulty,
                        _difficultyColor(
                          workout.difficulty,
                        ),
                      ),
                      _smallTag(
                        '${workout.totalSeconds ~/ 60} min',
                        const Color(0xFF302B63),
                      ),
                      _smallTag(
                        '+${workout.xp} XP',
                        const Color(0xFFFF7545),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF302B63),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Text(
            '🧘',
            style: TextStyle(fontSize: 42),
          ),
          SizedBox(height: 10),
          Text(
            'No workouts match those filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF151B3D),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another category or difficulty.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT PREVIEW
  // ============================================================

  void _openWorkoutPreview(
    _WorkoutPlan workout,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(22, 12, 22, 25),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      workout.emoji,
                      style:
                          const TextStyle(fontSize: 42),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF151B3D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.difficulty} • ${workout.category}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  workout.description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _previewStat(
                      'Exercises',
                      '${workout.exercises.length}',
                    ),
                    const SizedBox(width: 10),
                    _previewStat(
                      'Duration',
                      '${workout.totalSeconds ~/ 60} min',
                    ),
                    const SizedBox(width: 10),
                    _previewStat(
                      'Reward',
                      '+${workout.xp} XP',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'EXERCISE POSITIONS',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: workout.exercises.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      final details = _detailsForExercise(exercise);

                      return Container(
                        width: 180,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Text(
                              exercise.emoji,
                              style: const TextStyle(fontSize: 27),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF151B3D),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    details.position,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 9,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _WorkoutSessionScreen(
                            workout: workout,
                            appState: widget.appState,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    label: const Text(
                      'START WORKOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF302B63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _previewStat(
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WorkoutPlan> _filteredWorkouts() {
    return _workouts.where((workout) {
      final categoryMatch =
          _selectedCategory == 'All' ||
          workout.category == _selectedCategory;

      final difficultyMatch =
          _selectedDifficulty == 'All' ||
          workout.difficulty == _selectedDifficulty;

      return categoryMatch && difficultyMatch;
    }).toList();
  }

  String _difficultyEmoji(
    String difficulty,
  ) {
    switch (difficulty) {
      case 'Beginner':
        return '🟢';
      case 'Moderate':
        return '🟡';
      case 'Hard':
        return '🔴';
      default:
        return '';
    }
  }

  Color _difficultyColor(
    String difficulty,
  ) {
    switch (difficulty) {
      case 'Beginner':
        return const Color(0xFF27733A);
      case 'Moderate':
        return const Color(0xFFE19A00);
      case 'Hard':
        return const Color(0xFFE24A4A);
      default:
        return const Color(0xFF302B63);
    }
  }
}

// ============================================================
// EXERCISE DETAILS
// ============================================================

class _ExerciseDetails {
  final String position;
  final String equipment;
  final String muscles;
  final String formTip;
  final String safetyTip;

  const _ExerciseDetails({
    required this.position,
    required this.equipment,
    required this.muscles,
    required this.formTip,
    required this.safetyTip,
  });
}

_ExerciseDetails _detailsForExercise(_WorkoutExercise exercise) {
  switch (exercise.name) {
    case 'March in Place':
      return const _ExerciseDetails(
        position: 'Standing • upright posture',
        equipment: 'No equipment',
        muscles: 'Core • legs • hips',
        formTip: 'Stand tall, keep your chest open, and lift each knee with control.',
        safetyTip: 'Keep the pace comfortable and land softly.',
      );
    case 'Bodyweight Squats':
    case 'Squats':
    case 'Fast Squats':
      return const _ExerciseDetails(
        position: 'Standing • feet about shoulder-width',
        equipment: 'No equipment',
        muscles: 'Quads • glutes • hamstrings',
        formTip: 'Send your hips back, keep your chest lifted, and track your knees over your feet.',
        safetyTip: 'Use a smaller range of motion if your knees or hips feel uncomfortable.',
      );
    case 'Wall Push-Ups':
      return const _ExerciseDetails(
        position: 'Standing • hands on wall',
        equipment: 'Wall',
        muscles: 'Chest • shoulders • triceps',
        formTip: 'Keep your body in one straight line and bend your elbows under control.',
        safetyTip: 'Use a stable wall and keep your feet planted.',
      );
    case 'Standing Knee Raises':
    case 'High Knees':
      return const _ExerciseDetails(
        position: 'Standing • tall torso',
        equipment: 'No equipment',
        muscles: 'Hip flexors • core • legs',
        formTip: 'Brace your core and raise alternate knees without leaning backward.',
        safetyTip: 'Slow the movement down if balance becomes difficult.',
      );
    case 'Crunches':
      return const _ExerciseDetails(
        position: 'Lying on back • knees bent',
        equipment: 'Exercise mat recommended',
        muscles: 'Abdominals • core',
        formTip: 'Lift your shoulders gently and keep your neck relaxed.',
        safetyTip: 'Do not pull on your head or neck.',
      );
    case 'Mountain Climbers':
      return const _ExerciseDetails(
        position: 'High plank • hands under shoulders',
        equipment: 'Exercise mat recommended',
        muscles: 'Core • shoulders • legs',
        formTip: 'Keep your hips controlled while alternating your knees toward your chest.',
        safetyTip: 'Choose a slower pace before increasing speed.',
      );
    case 'Plank':
      return const _ExerciseDetails(
        position: 'Forearm or high plank',
        equipment: 'Exercise mat recommended',
        muscles: 'Core • shoulders • glutes',
        formTip: 'Make a straight line from shoulders through hips to heels.',
        safetyTip: 'Stop if you cannot maintain a controlled position.',
      );
    case 'Dead Bug':
      return const _ExerciseDetails(
        position: 'Lying on back • arms and knees raised',
        equipment: 'Exercise mat recommended',
        muscles: 'Deep core • abs',
        formTip: 'Keep your lower back comfortable while moving opposite arm and leg slowly.',
        safetyTip: 'Reduce the range of motion if your back lifts from the floor.',
      );
    case 'Reverse Lunges':
      return const _ExerciseDetails(
        position: 'Standing • step one foot backward',
        equipment: 'No equipment',
        muscles: 'Glutes • quads • hamstrings',
        formTip: 'Step back softly and lower with control while keeping your torso upright.',
        safetyTip: 'Hold a stable surface if you need balance support.',
      );
    case 'Calf Raises':
      return const _ExerciseDetails(
        position: 'Standing • feet hip-width',
        equipment: 'Optional wall support',
        muscles: 'Calves • ankles',
        formTip: 'Rise through the balls of your feet and lower slowly.',
        safetyTip: 'Use support if your balance is limited.',
      );
    case 'Wall Sit':
      return const _ExerciseDetails(
        position: 'Back supported • knees bent',
        equipment: 'Wall',
        muscles: 'Quads • glutes',
        formTip: 'Keep your back against the wall and hold a comfortable knee angle.',
        safetyTip: 'Do not force a deep position.',
      );
    case 'Jumping Jacks':
      return const _ExerciseDetails(
        position: 'Standing • jump or step out',
        equipment: 'No equipment',
        muscles: 'Full body • legs • shoulders',
        formTip: 'Open and close your arms and legs rhythmically.',
        safetyTip: 'Step instead of jumping if you need a lower-impact option.',
      );
    case 'Goblet Squat':
      return const _ExerciseDetails(
        position: 'Standing • weight held at chest',
        equipment: 'Light dumbbell or kettlebell',
        muscles: 'Quads • glutes • core',
        formTip: 'Hold the weight close to your chest and squat with a stable torso.',
        safetyTip: 'Start with a light weight and prioritize form.',
      );
    case 'Dumbbell Row':
      return const _ExerciseDetails(
        position: 'Hinged stance • neutral back',
        equipment: 'Light dumbbell',
        muscles: 'Upper back • lats • biceps',
        formTip: 'Keep your back neutral and pull the weight toward your hip.',
        safetyTip: 'Use a lighter weight if you cannot keep your back controlled.',
      );
    case 'Dumbbell Press':
      return const _ExerciseDetails(
        position: 'Standing or seated • weights at shoulders',
        equipment: 'Light dumbbells',
        muscles: 'Shoulders • chest • triceps',
        formTip: 'Press smoothly without locking your elbows aggressively.',
        safetyTip: 'Use a weight you can control throughout the movement.',
      );
    case 'Neck Stretch':
      return const _ExerciseDetails(
        position: 'Standing or seated • relaxed shoulders',
        equipment: 'No equipment',
        muscles: 'Neck • upper shoulders',
        formTip: 'Tilt gently until you feel a light stretch.',
        safetyTip: 'Never force or bounce the neck.',
      );
    case 'Shoulder Stretch':
      return const _ExerciseDetails(
        position: 'Standing • relaxed posture',
        equipment: 'No equipment',
        muscles: 'Shoulders • upper back',
        formTip: 'Keep the shoulder relaxed while holding the stretch.',
        safetyTip: 'Stay within a comfortable range.',
      );
    case 'Hamstring Stretch':
      return const _ExerciseDetails(
        position: 'Standing or seated • one leg extended',
        equipment: 'No equipment',
        muscles: 'Hamstrings • calves',
        formTip: 'Hinge gently from the hips instead of rounding aggressively.',
        safetyTip: 'A mild stretch is enough; do not force the range.',
      );
    case 'Mountain Pose':
      return const _ExerciseDetails(
        position: 'Standing • feet grounded • spine tall',
        equipment: 'Yoga mat optional',
        muscles: 'Posture muscles • legs • core',
        formTip: 'Ground through your feet, lengthen your spine, and relax your shoulders.',
        safetyTip: 'Breathe slowly and keep your stance comfortable.',
      );
    case 'Forward Fold':
      return const _ExerciseDetails(
        position: 'Standing • torso folding forward',
        equipment: 'Yoga mat optional',
        muscles: 'Hamstrings • calves • back',
        formTip: 'Soften your knees and hinge from your hips.',
        safetyTip: 'Never force your hands to reach the floor.',
      );
    case 'Cat-Cow':
      return const _ExerciseDetails(
        position: 'Hands and knees • tabletop',
        equipment: 'Yoga mat recommended',
        muscles: 'Spine • core • shoulders',
        formTip: 'Move slowly with your breathing as you alternate the two shapes.',
        safetyTip: 'Keep the movement gentle and pain-free.',
      );
    case 'Child’s Pose':
      return const _ExerciseDetails(
        position: 'Kneeling • hips toward heels',
        equipment: 'Yoga mat recommended',
        muscles: 'Back • hips • shoulders',
        formTip: 'Relax your shoulders and breathe into a comfortable position.',
        safetyTip: 'Place a cushion under your knees or hips if needed.',
      );
    case 'Push-Ups':
      return const _ExerciseDetails(
        position: 'High plank • hands slightly wider than shoulders',
        equipment: 'Exercise mat optional',
        muscles: 'Chest • shoulders • triceps • core',
        formTip: 'Keep your body aligned and lower with control.',
        safetyTip: 'Use knees or an elevated surface for an easier variation.',
      );
    case 'Plank Shoulder Taps':
      return const _ExerciseDetails(
        position: 'High plank • feet slightly wider',
        equipment: 'Exercise mat optional',
        muscles: 'Core • shoulders • chest',
        formTip: 'Tap opposite shoulders while keeping your hips as still as possible.',
        safetyTip: 'Widen your feet or slow down for better control.',
      );
    case 'Tricep Dips':
      return const _ExerciseDetails(
        position: 'Seated edge position • hands behind',
        equipment: 'Stable bench or chair',
        muscles: 'Triceps • shoulders • chest',
        formTip: 'Keep the movement shallow and your shoulders controlled.',
        safetyTip: 'Only use a completely stable surface.',
      );
    default:
      return const _ExerciseDetails(
        position: 'Use the position shown in the instructions',
        equipment: 'See exercise instructions',
        muscles: 'Full-body movement',
        formTip: 'Move slowly and prioritize controlled form.',
        safetyTip: 'Stop if you feel pain, dizziness, or unusual discomfort.',
      );
  }
}

Widget _exercisePositionVisual(
  _WorkoutExercise exercise, {
  bool dark = false,
}) {
  final details = _detailsForExercise(exercise);

  final background = dark
      ? Colors.white.withValues(alpha: 0.10)
      : const Color(0xFFF0F1F7);

  final primary = dark
      ? Colors.white
      : const Color(0xFF151B3D);

  final secondary = dark
      ? Colors.white70
      : Colors.black54;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  exercise.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POSITION',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    details.position,
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _exerciseInfoPill(
                'EQUIPMENT',
                details.equipment,
                dark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _exerciseInfoPill(
                'MUSCLES',
                details.muscles,
                dark,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _exerciseInfoPill(
  String label,
  String value,
  bool dark,
) {
  return Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: dark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dark ? Colors.white54 : Colors.black45,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF151B3D),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// WORKOUT SESSION
// ============================================================

class _WorkoutSessionScreen extends StatefulWidget {
  final _WorkoutPlan workout;
  final AppState appState;
  final VoidCallback? onCompleted;

  const _WorkoutSessionScreen({
    required this.workout,
    required this.appState,
    this.onCompleted,
  });

  @override
  State<_WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends State<_WorkoutSessionScreen> {
  Timer? _timer;

  int _exerciseIndex = 0;
  int _secondsRemaining = 0;

  bool _isResting = false;
  bool _isPaused = false;
  bool _completed = false;
  bool _rewardGiven = false;

  _WorkoutExercise get _currentExercise =>
      widget.workout.exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();

    _secondsRemaining =
        _currentExercise.duration;

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted ||
            _isPaused ||
            _completed) {
          return;
        }

        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        }

        if (_secondsRemaining <= 0) {
          _moveToNextStage();
        }
      },
    );
  }

  void _moveToNextStage() {
    _timer?.cancel();

    if (_isResting) {
      _goToNextExercise();
      return;
    }

    if (_exerciseIndex ==
        widget.workout.exercises.length - 1) {
      _finishWorkout();
      return;
    }

    setState(() {
      _isResting = true;
      _secondsRemaining = 15;
    });

    _startTimer();
  }

  void _goToNextExercise() {
    setState(() {
      _exerciseIndex++;
      _isResting = false;

      _secondsRemaining =
          widget
              .workout
              .exercises[_exerciseIndex]
              .duration;
    });

    _startTimer();
  }

  void _skipExercise() {
    _timer?.cancel();

    if (_exerciseIndex ==
        widget.workout.exercises.length - 1) {
      _finishWorkout();
      return;
    }

    _goToNextExercise();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishWorkout() {
    _timer?.cancel();

    if (!_rewardGiven) {
      _rewardGiven = true;

      widget.appState.addXp(
        widget.workout.xp,
      );

      widget.appState
          .completeWeeklyFitnessActivity();

      widget.onCompleted?.call();
    }

    setState(() {
      _completed = true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _buildCompletionScreen();
    }

    final totalExercises =
        widget.workout.exercises.length;

    final progress =
        (_exerciseIndex +
                (_isResting ? 0.5 : 0)) /
            totalExercises;

    return Scaffold(
      backgroundColor:
          const Color(0xFF151B3D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          widget.workout.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _confirmExit,
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            25,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child:
                          LinearProgressIndicator(
                        value:
                            progress.clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 8,
                        backgroundColor:
                            Colors.white12,
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          Color(0xFFFFD166),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_exerciseIndex + 1}/$totalExercises',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Expanded(
                child: _isResting
                    ? _buildRestView()
                    : _buildExerciseView(),
              ),
              _buildSessionControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseView() {
    final exercise = _currentExercise;
    final details = _detailsForExercise(exercise);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'CURRENT EXERCISE',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _exercisePositionVisual(
            exercise,
            dark: true,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOW TO DO IT',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  exercise.instructions,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓',
                      style: TextStyle(
                        color: Color(0xFF8FE3B1),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        details.formTip,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '!',
                      style: TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        details.safetyTip,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(_secondsRemaining),
            style: const TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestView() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text(
          '💧',
          style:
              TextStyle(fontSize: 72),
        ),
        const SizedBox(height: 25),
        const Text(
          'REST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Catch your breath. Next exercise coming up!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          _formatTime(
            _secondsRemaining,
          ),
          style: const TextStyle(
            color: Color(0xFFFFD166),
            fontSize: 60,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionControls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _skipExercise,
            icon: const Icon(
              Icons.skip_next_rounded,
            ),
            label: const Text('SKIP'),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  Colors.white,
              side: const BorderSide(
                color: Colors.white24,
              ),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(
              _isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
            ),
            label: Text(
              _isPaused
                  ? 'RESUME'
                  : 'PAUSE',
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.white,
              foregroundColor:
                  const Color(0xFF151B3D),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor:
          const Color(0xFF151B3D),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style:
                    TextStyle(fontSize: 90),
              ),
              const SizedBox(height: 25),
              const Text(
                'WORKOUT COMPLETE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You completed ${widget.workout.title}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Text(
                      'REWARD',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${widget.workout.xp} XP ⭐',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFFFFD166),
                        fontSize: 26,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      '+1 weekly fitness activity',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                  ),
                  child: const Text(
                    'BACK TO WORKOUTS',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    _timer?.cancel();

    final leave =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Leave workout?',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          content: const Text(
            'Your current workout session will not be completed.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('KEEP GOING'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text('LEAVE'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (leave == true) {
      Navigator.pop(context);
    } else {
      _startTimer();
    }
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _WorkoutPlan {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String emoji;
  final Color color;
  final int xp;
  final List<_WorkoutExercise> exercises;

  const _WorkoutPlan({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.emoji,
    required this.color,
    required this.xp,
    required this.exercises,
  });

  int get totalSeconds {
    final exerciseTime =
        exercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.duration,
    );

    final restTime =
        exercises.length > 1
            ? (exercises.length - 1) * 15
            : 0;

    return exerciseTime + restTime;
  }
}

class _WorkoutExercise {
  final String name;
  final String emoji;
  final int duration;
  final String instructions;

  const _WorkoutExercise({
    required this.name,
    required this.emoji,
    required this.duration,
    required this.instructions,
  });
}

class _WorkoutProgram {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final List<String> days;

  const _WorkoutProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.days,
  });
}

// ============================================================
// PROGRAM DATA
// ============================================================

const List<_WorkoutProgram> _programs = [
  _WorkoutProgram(
    id: 'core_30',
    title: '30-Day Core Challenge',
    description:
        'Build consistency with a progressive core-focused journey.',
    emoji: '🔥',
    color: Color(0xFFFF7545),
    days: [
      'Core Quest',
      'Quick Full Body',
      'Core Quest',
      'Stretch & Recover',
      'Core Quest',
      'No Equipment Express',
      'Core Quest',
      'Quick Full Body',
      'Core Quest',
      'Stretch & Recover',
      'Core Quest',
      'No Equipment Express',
      'Core Quest',
      'Quick Full Body',
      'Core Quest',
      'Stretch & Recover',
      'Core Quest',
      'No Equipment Express',
      'Core Quest',
      'Quick Full Body',
      'Core Quest',
      'Stretch & Recover',
      'Core Quest',
      'No Equipment Express',
      'Core Quest',
      'Quick Full Body',
      'Core Quest',
      'Stretch & Recover',
      'Core Quest',
      'Core Quest',
    ],
  ),
  _WorkoutProgram(
    id: 'full_body_30',
    title: '30-Day Full Body',
    description:
        'A balanced month of movement for the whole body.',
    emoji: '💪',
    color: Color(0xFF5B8DEF),
    days: [
      'Quick Full Body',
      'Leg Power',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Leg Power',
      'Quick Full Body',
      'Stretch & Recover',
      'HIIT Sprint',
      'Quick Full Body',
      'Leg Power',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Leg Power',
      'Quick Full Body',
      'Stretch & Recover',
      'HIIT Sprint',
      'Quick Full Body',
      'Leg Power',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Leg Power',
      'Quick Full Body',
      'Stretch & Recover',
      'HIIT Sprint',
      'Quick Full Body',
      'Leg Power',
      'Quick Full Body',
    ],
  ),
  _WorkoutProgram(
    id: 'starter_30',
    title: '30-Day Fitness Starter',
    description:
        'Start small, stay consistent, and build your fitness habit.',
    emoji: '🏃',
    color: Color(0xFF36A269),
    days: [
      'Quick Full Body',
      'Stretch & Recover',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Quick Full Body',
      'Stretch & Recover',
      'No Equipment Express',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Quick Full Body',
      'No Equipment Express',
      'Quick Full Body',
      'Morning Yoga Flow',
      'Quick Full Body',
    ],
  ),
  _WorkoutProgram(
    id: 'yoga_14',
    title: '14-Day Yoga & Mobility',
    description:
        'Gentle movement, mobility, balance, and recovery.',
    emoji: '🧘',
    color: Color(0xFF8A72D8),
    days: [
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
      'Morning Yoga Flow',
      'Stretch & Recover',
    ],
  ),
  _WorkoutProgram(
    id: 'gym_30',
    title: '30-Day Gym Strength',
    description:
        'A beginner-friendly strength journey for gym users.',
    emoji: '🏋️',
    color: Color(0xFF3D82C6),
    days: [
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Stretch & Recover',
      'Gym Starter',
      'Quick Full Body',
      'Gym Starter',
      'Gym Starter',
    ],
  ),
];

// ============================================================
// WORKOUT DATA
// ============================================================

const List<_WorkoutPlan> _workouts = [
  _WorkoutPlan(
    title: 'Quick Full Body',
    description:
        'A simple full-body starter session with no equipment.',
    category: 'Full Body',
    difficulty: 'Beginner',
    emoji: '💪',
    color: Color(0xFF5B8DEF),
    xp: 80,
    exercises: [
      _WorkoutExercise(
        name: 'March in Place',
        emoji: '🚶',
        duration: 30,
        instructions:
            'Stand tall and march with controlled movement.',
      ),
      _WorkoutExercise(
        name: 'Bodyweight Squats',
        emoji: '🦵',
        duration: 30,
        instructions:
            'Keep your chest up and sit your hips back.',
      ),
      _WorkoutExercise(
        name: 'Wall Push-Ups',
        emoji: '🙌',
        duration: 30,
        instructions:
            'Keep your body straight as you push from the wall.',
      ),
      _WorkoutExercise(
        name: 'Standing Knee Raises',
        emoji: '🏃',
        duration: 30,
        instructions:
            'Lift alternate knees while keeping your core steady.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Core Quest',
    description:
        'A focused core workout for building consistency.',
    category: 'Abs & Core',
    difficulty: 'Moderate',
    emoji: '🔥',
    color: Color(0xFFFF7545),
    xp: 110,
    exercises: [
      _WorkoutExercise(
        name: 'Crunches',
        emoji: '🔥',
        duration: 35,
        instructions:
            'Lift your shoulders gently and avoid pulling your neck.',
      ),
      _WorkoutExercise(
        name: 'Mountain Climbers',
        emoji: '🏔️',
        duration: 35,
        instructions:
            'Keep your core engaged while alternating your knees.',
      ),
      _WorkoutExercise(
        name: 'Plank',
        emoji: '🧱',
        duration: 30,
        instructions:
            'Keep your body in a straight line and breathe steadily.',
      ),
      _WorkoutExercise(
        name: 'Dead Bug',
        emoji: '🐞',
        duration: 35,
        instructions:
            'Move opposite arm and leg slowly while bracing your core.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Leg Power',
    description:
        'Build lower-body strength with controlled movements.',
    category: 'Legs',
    difficulty: 'Moderate',
    emoji: '🦵',
    color: Color(0xFF36A269),
    xp: 110,
    exercises: [
      _WorkoutExercise(
        name: 'Squats',
        emoji: '🦵',
        duration: 40,
        instructions:
            'Lower under control and drive back up through your feet.',
      ),
      _WorkoutExercise(
        name: 'Reverse Lunges',
        emoji: '🏃',
        duration: 40,
        instructions:
            'Step back and lower gently before returning to standing.',
      ),
      _WorkoutExercise(
        name: 'Calf Raises',
        emoji: '👟',
        duration: 35,
        instructions:
            'Rise onto your toes and lower slowly.',
      ),
      _WorkoutExercise(
        name: 'Wall Sit',
        emoji: '🧱',
        duration: 30,
        instructions:
            'Keep your back supported and hold a comfortable position.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'HIIT Sprint',
    description:
        'A short high-energy session for students who want a challenge.',
    category: 'HIIT',
    difficulty: 'Hard',
    emoji: '⚡',
    color: Color(0xFFE24A4A),
    xp: 150,
    exercises: [
      _WorkoutExercise(
        name: 'High Knees',
        emoji: '🏃',
        duration: 30,
        instructions:
            'Drive your knees upward while staying light on your feet.',
      ),
      _WorkoutExercise(
        name: 'Jumping Jacks',
        emoji: '⭐',
        duration: 30,
        instructions:
            'Jump with controlled, comfortable movements.',
      ),
      _WorkoutExercise(
        name: 'Mountain Climbers',
        emoji: '🏔️',
        duration: 35,
        instructions:
            'Maintain a strong plank position as you alternate knees.',
      ),
      _WorkoutExercise(
        name: 'Fast Squats',
        emoji: '🔥',
        duration: 30,
        instructions:
            'Use a controlled pace that you can maintain safely.',
      ),
      _WorkoutExercise(
        name: 'High Knees',
        emoji: '🏃',
        duration: 30,
        instructions:
            'Finish strong while maintaining good posture.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Morning Yoga Flow',
    description:
        'A gentle mobility and breathing session to start the day.',
    category: 'Yoga',
    difficulty: 'Beginner',
    emoji: '🧘',
    color: Color(0xFF8A72D8),
    xp: 90,
    exercises: [
      _WorkoutExercise(
        name: 'Mountain Pose',
        emoji: '🧘',
        duration: 30,
        instructions:
            'Stand tall, relax your shoulders, and breathe slowly.',
      ),
      _WorkoutExercise(
        name: 'Forward Fold',
        emoji: '🌿',
        duration: 35,
        instructions:
            'Hinge gently and stop at a comfortable stretch.',
      ),
      _WorkoutExercise(
        name: 'Cat-Cow',
        emoji: '🐈',
        duration: 40,
        instructions:
            'Move slowly between rounded and extended spine positions.',
      ),
      _WorkoutExercise(
        name: 'Child’s Pose',
        emoji: '🌱',
        duration: 40,
        instructions:
            'Relax into a comfortable position and breathe deeply.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Gym Starter',
    description:
        'A beginner-friendly gym session using simple strength movements.',
    category: 'Gym',
    difficulty: 'Beginner',
    emoji: '🏋️',
    color: Color(0xFF3D82C6),
    xp: 120,
    exercises: [
      _WorkoutExercise(
        name: 'Goblet Squat',
        emoji: '🏋️',
        duration: 40,
        instructions:
            'Use a light weight and keep your movement controlled.',
      ),
      _WorkoutExercise(
        name: 'Dumbbell Row',
        emoji: '💪',
        duration: 40,
        instructions:
            'Pull the weight toward your side while keeping your back stable.',
      ),
      _WorkoutExercise(
        name: 'Dumbbell Press',
        emoji: '🏋️',
        duration: 40,
        instructions:
            'Use a comfortable weight and press with control.',
      ),
      _WorkoutExercise(
        name: 'Bodyweight Squats',
        emoji: '🦵',
        duration: 40,
        instructions:
            'Finish with controlled bodyweight repetitions.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Stretch & Recover',
    description:
        'Gentle stretching for recovery, mobility, and relaxation.',
    category: 'Stretching',
    difficulty: 'Beginner',
    emoji: '🌿',
    color: Color(0xFF4BAE8A),
    xp: 70,
    exercises: [
      _WorkoutExercise(
        name: 'Neck Stretch',
        emoji: '🧘',
        duration: 25,
        instructions:
            'Move gently and never force the stretch.',
      ),
      _WorkoutExercise(
        name: 'Shoulder Stretch',
        emoji: '🙆',
        duration: 30,
        instructions:
            'Keep the movement comfortable and breathe normally.',
      ),
      _WorkoutExercise(
        name: 'Hamstring Stretch',
        emoji: '🦵',
        duration: 30,
        instructions:
            'Extend gently until you feel a comfortable stretch.',
      ),
      _WorkoutExercise(
        name: 'Child’s Pose',
        emoji: '🌱',
        duration: 35,
        instructions:
            'Relax and take slow, comfortable breaths.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'Arm & Shoulder Burn',
    description:
        'A focused upper-body session using bodyweight movements.',
    category: 'Arms',
    difficulty: 'Hard',
    emoji: '💪',
    color: Color(0xFFEF5DA8),
    xp: 140,
    exercises: [
      _WorkoutExercise(
        name: 'Push-Ups',
        emoji: '💪',
        duration: 35,
        instructions:
            'Keep your body aligned and use a comfortable variation.',
      ),
      _WorkoutExercise(
        name: 'Plank Shoulder Taps',
        emoji: '🔥',
        duration: 35,
        instructions:
            'Keep your hips steady while alternating shoulder taps.',
      ),
      _WorkoutExercise(
        name: 'Tricep Dips',
        emoji: '💪',
        duration: 35,
        instructions:
            'Use a stable surface and keep the movement controlled.',
      ),
      _WorkoutExercise(
        name: 'Wall Push-Ups',
        emoji: '🙌',
        duration: 35,
        instructions:
            'Finish with a controlled upper-body movement.',
      ),
    ],
  ),
  _WorkoutPlan(
    title: 'No Equipment Express',
    description:
        'A quick workout you can do almost anywhere.',
    category: 'No Equipment',
    difficulty: 'Moderate',
    emoji: '🏠',
    color: Color(0xFFF2A93B),
    xp: 100,
    exercises: [
      _WorkoutExercise(
        name: 'Jumping Jacks',
        emoji: '⭐',
        duration: 30,
        instructions:
            'Use a comfortable pace and land softly.',
      ),
      _WorkoutExercise(
        name: 'Squats',
        emoji: '🦵',
        duration: 35,
        instructions:
            'Keep your knees aligned and chest lifted.',
      ),
      _WorkoutExercise(
        name: 'Mountain Climbers',
        emoji: '🏔️',
        duration: 30,
        instructions:
            'Move steadily while keeping your core engaged.',
      ),
      _WorkoutExercise(
        name: 'Plank',
        emoji: '🧱',
        duration: 30,
        instructions:
            'Hold a strong, comfortable plank position.',
      ),
    ],
  ),
];