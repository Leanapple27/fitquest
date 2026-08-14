import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../app_state.dart';

enum _QuizCategory {
  nutrition,
  fitness,
  gym,
  yoga,
  meditation,
  sleep,
  hydration,
  healthyHabits,
}

enum _QuizDifficulty {
  beginner,
  moderate,
  hard,
  adaptive,
}

enum _QuizMode {
  quick,
  knowledge,
  speed,
  streak,
  challenge,
  mixed,
}

class QuizScreen extends StatefulWidget {
  final AppState appState;

  const QuizScreen({
    super.key,
    required this.appState,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();

  _QuizCategory? _selectedCategory;
  _QuizDifficulty _selectedDifficulty = _QuizDifficulty.beginner;
  _QuizMode _selectedMode = _QuizMode.quick;

  List<_QuizQuestion> _questions = [];
  int _currentQuestion = 0;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hintsUsed = 0;
  int _secondsLeft = 0;
  int _timeBonus = 0;
  int _awardedXp = 0;
  int _lives = 3;
  bool _challengeFailed = false;
  bool _timedOut = false;
  int _speedCorrect = 0;
  

  bool _answered = false;
  bool _quizFinished = false;
  bool _hintShown = false;
  int? _selectedAnswer;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizFinished) {
      return _buildResults();
    }

    if (_questions.isEmpty) {
      return _buildQuizHub();
    }

    return _buildQuizSession();
  }

  Widget _buildQuizHub() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Quiz Hub',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHubHero(),
              const SizedBox(height: 20),
              _sectionTitle('CHOOSE A CATEGORY'),
              const SizedBox(height: 10),
              _buildCategories(),
              const SizedBox(height: 22),
              _sectionTitle('DIFFICULTY'),
              const SizedBox(height: 10),
              _buildDifficultySelector(),
              const SizedBox(height: 22),
              _sectionTitle('QUIZ MODE'),
              const SizedBox(height: 10),
              _buildModeSelector(),
              const SizedBox(height: 22),
              _buildDailyChallenge(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startSelectedQuiz,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _selectedCategory == null
                        ? 'START MIXED QUIZ'
                        : 'START ${_modeName(_selectedMode).toUpperCase()}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
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

  Widget _buildHubHero() {
    final level = (widget.appState.xp ~/ 250).clamp(1, 15);
    final xpIntoLevel = widget.appState.xp % 250;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FITQUEST QUIZ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Think fast.\nLearn more. 🧠',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat('⭐', '${widget.appState.xp}', 'XP'),
              const SizedBox(width: 10),
              _miniStat('🏆', '$level', 'LEVEL'),
              const SizedBox(width: 10),
              _miniStat('🔥', '${widget.appState.streak}', 'STREAK'),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: xpIntoLevel / 250,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD166),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$xpIntoLevel / 250 XP to the next level',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
        color: Colors.black45,
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      (_QuizCategory.nutrition, '🥗', 'Nutrition', 'Food & nutrients'),
      (_QuizCategory.fitness, '🏃', 'Fitness', 'Cardio & movement'),
      (_QuizCategory.gym, '🏋️', 'Gym', 'Training & form'),
      (_QuizCategory.yoga, '🧘', 'Yoga', 'Poses & practice'),
      (_QuizCategory.meditation, '😌', 'Meditation', 'Mind & breathing'),
      (_QuizCategory.sleep, '😴', 'Sleep', 'Rest & recovery'),
      (_QuizCategory.hydration, '💧', 'Hydration', 'Fluids & habits'),
      (_QuizCategory.healthyHabits, '❤️', 'Healthy Habits', 'Everyday choices'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = categories[index];
        final selected = _selectedCategory == item.$1;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEDEBFF) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? const Color(0xFF51489A)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(item.$2, style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$3,
                        style: const TextStyle(
                          color: Color(0xFF151B3D),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$4,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 9,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultySelector() {
    final values = [
      (_QuizDifficulty.beginner, '🟢', 'Beginner', 'Build confidence'),
      (_QuizDifficulty.moderate, '🟡', 'Moderate', 'Think deeper'),
      (_QuizDifficulty.hard, '🔴', 'Hard', 'Serious challenge'),
      (_QuizDifficulty.adaptive, '⚡', 'Adaptive', 'Difficulty changes'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((item) {
        final selected = _selectedDifficulty == item.$1;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedDifficulty = item.$1);
          },
          avatar: Text(item.$2),
          label: Text(item.$3),
          selectedColor: const Color(0xFFEDEBFF),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF302B63) : Colors.black54,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
          side: BorderSide(
            color: selected ? const Color(0xFF51489A) : Colors.transparent,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      (_QuizMode.quick, '⚡', 'Quick', '5 Q • 2 min'),
      (_QuizMode.knowledge, '🧠', 'Knowledge', '10 Q • deeper'),
      (_QuizMode.speed, '⏱️', 'Speed', '10 sec / Q'),
      (_QuizMode.streak, '🔥', 'Streak', 'combo run'),
      (_QuizMode.challenge, '🏆', 'Challenge', 'harder • 10 Q'),
      (_QuizMode.mixed, '🔀', 'Mixed', 'all topics'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final item = modes[index];
        final selected = _selectedMode == item.$1;

        return GestureDetector(
          onTap: () => setState(() => _selectedMode = item.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF302B63) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(item.$2, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$3,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF151B3D),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.$4,
                        style: TextStyle(
                          color: selected ? Colors.white60 : Colors.black45,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.6),
        ),
      ),
      child: const Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 30)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY QUIZ',
                  style: TextStyle(
                    color: Color(0xFF8A6510),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete a quiz today for bonus XP and keep your knowledge streak alive.',
                  style: TextStyle(
                    color: Color(0xFF6B5B2B),
                    fontSize: 11,
                    height: 1.3,
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

  Widget _buildQuizSession() {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          _modeName(_selectedMode),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedMode != _QuizMode.quick)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Center(
                child: Text(
                  '🔥 $_combo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE85D5D),
                  ),
                ),
              ),
            ),
          if (_selectedMode == _QuizMode.challenge)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '❤️ ' * _lives,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD166),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentQuestion + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF302B63),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _tag(_categoryName(question.category)),
                  const SizedBox(width: 7),
                  _tag(_difficultyName(question.difficulty)),
                  const Spacer(),
                  if (_secondsLeft > 0)
                    _timerPill(),
                ],
              ),
              const SizedBox(height: 14),
              if (_selectedMode == _QuizMode.speed)
                _modeBanner(
                  '⚡ SPEED MODE',
                  'Answer before the clock hits zero. Faster correct answers earn a bigger bonus.',
                ),
              if (_selectedMode == _QuizMode.knowledge)
                _modeBanner(
                  '🧠 KNOWLEDGE MODE',
                  'Take your time. Explanations are the focus, and every question tests understanding.',
                ),
              if (_selectedMode == _QuizMode.challenge)
                _modeBanner(
                  '🏆 CHALLENGE MODE',
                  'Hard questions, 3 lives and a passing target of 70%.',
                ),
              if (_selectedMode == _QuizMode.streak)
                _modeBanner(
                  '🔥 STREAK MODE',
                  'Build your combo. Every wrong answer breaks the streak.',
                ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF302B63),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUESTION ${_currentQuestion + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                question.answers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _answerButton(
                    index,
                    question.answers[index],
                    question.correctAnswer,
                  ),
                ),
              ),
              if (_hintShown) _buildHint(question),
              if (_answered) _buildFeedback(question),
              const SizedBox(height: 8),
              if (!_answered)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _hintShown ? null : _useHint,
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: Text(
                          _hintShown ? 'HINT USED' : 'USE HINT',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF51489A),
                          side: const BorderSide(
                            color: Color(0xFF51489A),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_answered) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF302B63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _currentQuestion == _questions.length - 1
                          ? 'SEE RESULTS'
                          : 'NEXT QUESTION',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeBanner(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _selectedMode == _QuizMode.challenge
            ? const Color(0xFFFFE9E7)
            : const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF302B63),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF302B63),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _timerPill() {
    final urgent = _secondsLeft <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFE9E7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '⏱ $_secondsLeft',
        style: TextStyle(
          color: urgent ? const Color(0xFFE85D5D) : const Color(0xFF302B63),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _answerButton(
    int index,
    String answer,
    int correctAnswer,
  ) {
    final selected = _selectedAnswer == index;
    final correct = index == correctAnswer;

    Color background = Colors.white;
    Color border = Colors.transparent;
    String indicator = String.fromCharCode(65 + index);

    if (_answered) {
      if (correct) {
        background = const Color(0xFFEAF6EE);
        border = const Color(0xFF4CAF50);
        indicator = '✓';
      } else if (selected) {
        background = const Color(0xFFFFE9E7);
        border = const Color(0xFFE85D5D);
        indicator = '✕';
      }
    } else if (selected) {
      background = const Color(0xFFEDEBFF);
      border = const Color(0xFF51489A);
    }

    return GestureDetector(
      onTap: _answered ? null : () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: border,
            width: border == Colors.transparent ? 0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EFFF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  indicator,
                  style: const TextStyle(
                    color: Color(0xFF151B3D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF151B3D),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint(_QuizQuestion question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              question.hint,
              style: const TextStyle(
                color: Color(0xFF6B5B2B),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(_QuizQuestion question) {
    final correct = _selectedAnswer == question.correctAnswer;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: correct
            ? const Color(0xFFEAF6EE)
            : const Color(0xFFFFE9E7),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? '🎉' : '💡',
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timedOut
                      ? '⏱ Time up!'
                      : (correct
                          ? 'Correct! +${_questionXp(question)} XP'
                          : 'Keep learning!'),
                  style: TextStyle(
                    color: correct
                        ? const Color(0xFF27733A)
                        : const Color(0xFFB54747),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.explanation,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final percentage =
        _questions.isEmpty ? 0.0 : _score / _questions.length;
    final passed = percentage >= 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(27),
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
                children: [
                  Text(
                    passed ? '🏆' : '💪',
                    style: const TextStyle(fontSize: 58),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedMode == _QuizMode.challenge)
                    Text(
                      _challengeFailed
                          ? 'Challenge Failed'
                          : (passed ? 'Challenge Complete!' : 'Challenge Failed'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      passed ? 'Quiz Complete!' : 'Keep Practicing!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${(_percentage() * 100).round()}% • $_score/${_questions.length} correct',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _awardedXp > 0 ? '+$_awardedXp XP' : '+0 XP',
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _resultStat('🔥', 'Combo', '$_bestCombo')),
                const SizedBox(width: 9),
                Expanded(child: _resultStat('⏱️', 'Bonus', '+$_timeBonus')),
                const SizedBox(width: 9),
                Expanded(child: _resultStat('💡', 'Hints', '$_hintsUsed')),
              ],
            ),
            const SizedBox(height: 18),
            _buildResultBreakdown(),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF302B63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF302B63),
                  side: const BorderSide(color: Color(0xFF302B63)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'BACK',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF151B3D),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBreakdown() {
    final correct = _questions.where((q) {
      final index = _questions.indexOf(q);
      return index < _score;
    }).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUIZ SUMMARY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('Category', _selectedCategory == null
              ? 'Mixed'
              : _categoryName(_selectedCategory!)),
          _summaryRow('Difficulty', _difficultyName(_selectedDifficulty)),
          _summaryRow('Mode', _modeName(_selectedMode)),
          _summaryRow('Correct answers', '$correct / ${_questions.length}'),
          _summaryRow('Hints used', '$_hintsUsed'),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF151B3D),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _startSelectedQuiz() {
    final all = _questionBank();
    var pool = all.where((q) {
      if (_selectedCategory != null &&
          _selectedMode != _QuizMode.mixed &&
          q.category != _selectedCategory) {
        return false;
      }

      if (_selectedMode == _QuizMode.challenge) {
        return q.difficulty == _QuizDifficulty.hard;
      }

      if (_selectedMode == _QuizMode.knowledge) {
        return q.difficulty == _QuizDifficulty.moderate ||
            q.difficulty == _QuizDifficulty.hard;
      }

      if (_selectedMode == _QuizMode.speed) {
        return q.difficulty != _QuizDifficulty.hard;
      }

      if (_selectedDifficulty != _QuizDifficulty.adaptive &&
          q.difficulty != _selectedDifficulty) {
        return false;
      }

      return true;
    }).toList();

    if (pool.length < _questionCount()) {
      pool = all.where((q) {
        if (_selectedCategory != null &&
            _selectedMode != _QuizMode.mixed &&
            q.category != _selectedCategory) {
          return false;
        }
        return true;
      }).toList();
    }

    if (pool.length < _questionCount()) {
      pool = all;
    }

    pool.shuffle(_random);
    final count = min(_questionCount(), pool.length);

    setState(() {
      _questions = pool.take(count).toList();
      _currentQuestion = 0;
      _score = 0;
      _combo = 0;
      _bestCombo = 0;
      _hintsUsed = 0;
      _timeBonus = 0;
      _awardedXp = 0;
      _lives = 3;
      _challengeFailed = false;
      _timedOut = false;
      _speedCorrect = 0;
      _answered = false;
      _quizFinished = false;
      _hintShown = false;
      _selectedAnswer = null;
    });

    _startTimerForQuestion();
  }

  int _questionCount() {
    switch (_selectedMode) {
      case _QuizMode.quick:
        return 5;
      case _QuizMode.knowledge:
      case _QuizMode.speed:
      case _QuizMode.streak:
      case _QuizMode.challenge:
      case _QuizMode.mixed:
        return 10;
    }
  }

  void _startTimerForQuestion() {
    _timer?.cancel();

    int seconds;
    switch (_selectedMode) {
      case _QuizMode.speed:
        seconds = 10;
        break;
      case _QuizMode.streak:
        seconds = 15;
        break;
      case _QuizMode.challenge:
        seconds = 20;
        break;
      default:
        seconds = 0;
    }

    if (seconds == 0) {
      setState(() => _secondsLeft = 0);
      return;
    }

    setState(() => _secondsLeft = seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _answered) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        _timedOut = true;
        _selectAnswer(-1);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    _timer?.cancel();

    final question = _questions[_currentQuestion];
    final correct = index == question.correctAnswer;

    setState(() {
      _selectedAnswer = index < 0 ? null : index;
      _answered = true;

      if (correct) {
        _score++;
        _combo++;
        _bestCombo = max(_bestCombo, _combo);

        if (_selectedMode == _QuizMode.speed) {
          _speedCorrect++;
        }

        if (_secondsLeft > 0) {
          _timeBonus += _secondsLeft;
        }
      } else {
        _combo = 0;

        if (_selectedMode == _QuizMode.challenge) {
          _lives--;
          if (_lives <= 0) {
            _challengeFailed = true;
          }
        }
      }
    });
  }

  void _useHint() {
    if (_hintShown || _answered) return;

    setState(() {
      _hintShown = true;
      _hintsUsed++;
    });
  }

  void _nextQuestion() {
    if (!_answered) return;

    if (_currentQuestion == _questions.length - 1) {
      _finishQuiz();
      return;
    }

    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
      _answered = false;
      _hintShown = false;
      _timedOut = false;
      _secondsLeft = 0;
    });

    _startTimerForQuestion();
  }

  void _finishQuiz() {
    _timer?.cancel();

    final percentage =
        _questions.isEmpty ? 0.0 : _score / _questions.length;

    final challengePassed =
        _selectedMode != _QuizMode.challenge || (!_challengeFailed && percentage >= 0.7);

    final baseXp = _score * 10;
    final modeBonus = _modeBonus(challengePassed);
    final comboBonus = min(_bestCombo * 3, 40);
    final timeBonus = min(_timeBonus, 40);
    final perfectBonus =
        _score == _questions.length ? 30 : 0;
    final speedBonus = _selectedMode == _QuizMode.speed
        ? min(_speedCorrect * 4, 30)
        : 0;
    final challengeBonus = _selectedMode == _QuizMode.challenge &&
            challengePassed
        ? 40
        : 0;
    final streakBonus = _selectedMode == _QuizMode.streak
        ? min(_bestCombo * 5, 50)
        : 0;

    final reward = baseXp +
        modeBonus +
        comboBonus +
        timeBonus +
        perfectBonus +
        speedBonus +
        challengeBonus +
        streakBonus;

    bool awarded = false;

    if (reward > 0 && !widget.appState.quizCompleted) {
      awarded = widget.appState.completeQuiz(reward);
    } else if (reward > 0) {
      widget.appState.addXp(reward);
      awarded = true;
    }

    setState(() {
      _awardedXp = awarded ? reward : 0;
      _quizFinished = true;
    });
  }

  int _modeBonus(bool challengePassed) {
    switch (_selectedMode) {
      case _QuizMode.quick:
        return 0;
      case _QuizMode.knowledge:
        return 15;
      case _QuizMode.speed:
        return 20;
      case _QuizMode.streak:
        return 20;
      case _QuizMode.challenge:
        return challengePassed ? 30 : 0;
      case _QuizMode.mixed:
        return 15;
    }
  }

  int _questionXp(_QuizQuestion question) {
    switch (question.difficulty) {
      case _QuizDifficulty.beginner:
        return 10;
      case _QuizDifficulty.moderate:
        return 12;
      case _QuizDifficulty.hard:
        return 15;
      case _QuizDifficulty.adaptive:
        return 12;
    }
  }

  double _percentage() {
    if (_questions.isEmpty) return 0;
    return _score / _questions.length;
  }

  void _restartQuiz() {
    setState(() {
      _questions = [];
      _currentQuestion = 0;
      _score = 0;
      _combo = 0;
      _bestCombo = 0;
      _hintsUsed = 0;
      _timeBonus = 0;
      _awardedXp = 0;
      _lives = 3;
      _challengeFailed = false;
      _timedOut = false;
      _speedCorrect = 0;
      _answered = false;
      _quizFinished = false;
      _hintShown = false;
      _selectedAnswer = null;
      _secondsLeft = 0;
    });
  }

  String _categoryName(_QuizCategory category) {
    switch (category) {
      case _QuizCategory.nutrition:
        return 'Nutrition';
      case _QuizCategory.fitness:
        return 'Fitness';
      case _QuizCategory.gym:
        return 'Gym';
      case _QuizCategory.yoga:
        return 'Yoga';
      case _QuizCategory.meditation:
        return 'Meditation';
      case _QuizCategory.sleep:
        return 'Sleep';
      case _QuizCategory.hydration:
        return 'Hydration';
      case _QuizCategory.healthyHabits:
        return 'Healthy Habits';
    }
  }

  String _difficultyName(_QuizDifficulty difficulty) {
    switch (difficulty) {
      case _QuizDifficulty.beginner:
        return 'Beginner';
      case _QuizDifficulty.moderate:
        return 'Moderate';
      case _QuizDifficulty.hard:
        return 'Hard';
      case _QuizDifficulty.adaptive:
        return 'Adaptive';
    }
  }

  String _modeName(_QuizMode mode) {
    switch (mode) {
      case _QuizMode.quick:
        return 'Quick Quiz';
      case _QuizMode.knowledge:
        return 'Knowledge Challenge';
      case _QuizMode.speed:
        return 'Speed Quiz';
      case _QuizMode.streak:
        return 'Streak Quiz';
      case _QuizMode.challenge:
        return 'Challenge Mode';
      case _QuizMode.mixed:
        return 'Mixed Quiz';
    }
  }

  List<_QuizQuestion> _questionBank() {
    return const [
      // NUTRITION
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which food is a good source of dietary fiber?',
        answers: ['Oats', 'Butter', 'Table salt', 'Soft drink'],
        correctAnswer: 0,
        explanation: 'Oats contain dietary fiber, which supports normal digestion.',
        hint: 'Think about a whole-grain breakfast food.',
      ),
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which nutrient is the body’s main source of energy?',
        answers: ['Carbohydrate', 'Water', 'Vitamin C', 'Calcium'],
        correctAnswer: 0,
        explanation: 'Carbohydrates are a major source of energy for the body.',
        hint: 'Think about the nutrient commonly found in grains and fruit.',
      ),
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which choice is a protein-rich food?',
        answers: ['Lentils', 'Olive oil', 'Apple juice', 'Table sugar'],
        correctAnswer: 0,
        explanation: 'Lentils are legumes that provide substantial protein.',
        hint: 'Look for the legume.',
      ),
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which vitamin is especially associated with citrus fruits such as oranges?',
        answers: ['Vitamin C', 'Vitamin B12', 'Vitamin D', 'Vitamin K'],
        correctAnswer: 0,
        explanation: 'Citrus fruits are well known for providing vitamin C.',
        hint: 'Think of the vitamin often linked with oranges.',
      ),
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.hard,
        question: 'Which macronutrient provides the most energy per gram?',
        answers: ['Fat', 'Carbohydrate', 'Protein', 'Water'],
        correctAnswer: 0,
        explanation: 'Fat provides about 9 kcal per gram, more than carbohydrate or protein.',
        hint: 'Compare the energy density of the three macronutrients.',
      ),
      _QuizQuestion(
        category: _QuizCategory.nutrition,
        difficulty: _QuizDifficulty.hard,
        question: 'Which mineral is important for normal oxygen transport in the blood?',
        answers: ['Iron', 'Sodium', 'Fluoride', 'Iodine'],
        correctAnswer: 0,
        explanation: 'Iron is a component of hemoglobin, which carries oxygen in red blood cells.',
        hint: 'Think about the mineral found in hemoglobin.',
      ),

      // FITNESS
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.beginner,
        question: 'What is a sensible first step before vigorous exercise?',
        answers: ['Warm up', 'Skip all movement', 'Hold your breath', 'Avoid fluids'],
        correctAnswer: 0,
        explanation: 'A warm-up gradually prepares the body for more demanding movement.',
        hint: 'Choose the action that prepares the body rather than stopping movement.',
      ),
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which activity mainly trains cardiovascular endurance?',
        answers: ['Brisk walking', 'Single biceps curl', 'Static finger stretch', 'Writing'],
        correctAnswer: 0,
        explanation: 'Brisk walking can raise heart rate and challenge cardiovascular endurance.',
        hint: 'Pick the activity that keeps large muscles moving continuously.',
      ),
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.moderate,
        question: 'What does a plank primarily challenge?',
        answers: ['Core stability', 'Hearing', 'Handwriting speed', 'Vision'],
        correctAnswer: 0,
        explanation: 'Planks require the trunk muscles to maintain a stable body position.',
        hint: 'Think about keeping the torso steady.',
      ),
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which training principle means gradually increasing a challenge over time?',
        answers: ['Progressive overload', 'Complete rest forever', 'Random inactivity', 'Dehydration'],
        correctAnswer: 0,
        explanation: 'Progressive overload increases training demands gradually so the body can adapt.',
        hint: 'Look for the term describing a gradual increase in training demand.',
      ),
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.hard,
        question: 'Which exercise is primarily a lower-body compound movement?',
        answers: ['Squat', 'Biceps curl', 'Wrist rotation', 'Neck tilt'],
        correctAnswer: 0,
        explanation: 'A squat uses several lower-body joints and muscle groups together.',
        hint: 'Choose the movement that involves hips and knees together.',
      ),
      _QuizQuestion(
        category: _QuizCategory.fitness,
        difficulty: _QuizDifficulty.hard,
        question: 'Which training variable describes how hard an exercise feels or how much load is used?',
        answers: ['Intensity', 'Frequency', 'Duration', 'Recovery day'],
        correctAnswer: 0,
        explanation: 'Intensity describes the relative difficulty or effort of a training bout.',
        hint: 'Think about the difference between how hard and how often you train.',
      ),

      // GYM
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which muscle group is strongly involved in a dumbbell row?',
        answers: ['Upper back', 'Calves only', 'Jaw muscles', 'Forehead'],
        correctAnswer: 0,
        explanation: 'A dumbbell row trains pulling muscles of the upper back, including the lats.',
        hint: 'Rows are pulling movements.',
      ),
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.beginner,
        question: 'What should you prioritize when learning a new gym exercise?',
        answers: ['Controlled form', 'Maximum weight immediately', 'Speed at any cost', 'Skipping instructions'],
        correctAnswer: 0,
        explanation: 'Controlled technique helps you learn the movement before adding more load.',
        hint: 'Choose the option that focuses on movement quality.',
      ),
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which movement is mainly a pushing exercise?',
        answers: ['Dumbbell press', 'Dumbbell row', 'Hamstring curl', 'Calf raise'],
        correctAnswer: 0,
        explanation: 'A dumbbell press pushes the weights away from the body.',
        hint: 'Think about whether the weight moves away from or toward you.',
      ),
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.moderate,
        question: 'Why is rest between demanding sets useful?',
        answers: ['It allows recovery before the next set', 'It removes the need for technique', 'It guarantees instant muscle growth', 'It replaces hydration'],
        correctAnswer: 0,
        explanation: 'Rest gives the body time to recover so the next set can be performed with better control.',
        hint: 'Think about what happens to effort during repeated sets.',
      ),
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.hard,
        question: 'Which exercise is a hip-hinge movement?',
        answers: ['Romanian deadlift', 'Biceps curl', 'Lateral raise', 'Wrist curl'],
        correctAnswer: 0,
        explanation: 'A Romanian deadlift emphasizes hinging at the hips while keeping a controlled back position.',
        hint: 'Look for the exercise centered on moving the hips backward.',
      ),
      _QuizQuestion(
        category: _QuizCategory.gym,
        difficulty: _QuizDifficulty.hard,
        question: 'What is the main purpose of a spotter during a heavy lift?',
        answers: ['Provide safety assistance when needed', 'Choose the lifter’s music', 'Count calories', 'Replace warm-up'],
        correctAnswer: 0,
        explanation: 'A spotter can assist if a lifter cannot safely complete a repetition.',
        hint: 'Think about what happens when a heavy repetition cannot be completed safely.',
      ),

      // YOGA
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which yoga pose is commonly practiced standing tall with feet grounded?',
        answers: ['Mountain Pose', 'Child’s Pose', 'Corpse Pose', 'Seated Twist'],
        correctAnswer: 0,
        explanation: 'Mountain Pose is a standing posture focused on alignment and grounded balance.',
        hint: 'Choose the pose whose name suggests a tall, stable shape.',
      ),
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which yoga practice commonly links movement with breathing?',
        answers: ['Vinyasa-style flow', 'Sleeping', 'Reading', 'Static typing'],
        correctAnswer: 0,
        explanation: 'Vinyasa-style practice commonly coordinates movement with the breath.',
        hint: 'Look for the practice associated with flowing movement.',
      ),
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.moderate,
        question: 'What is an important principle during a yoga stretch?',
        answers: ['Stay within a comfortable range', 'Force through sharp pain', 'Hold your breath', 'Bounce aggressively'],
        correctAnswer: 0,
        explanation: 'Yoga stretching should be controlled and comfortable rather than forced into pain.',
        hint: 'Choose the option that emphasizes control and comfort.',
      ),
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which pose is commonly performed on hands and knees while alternating spinal shapes?',
        answers: ['Cat-Cow', 'Mountain Pose', 'Warrior II', 'Tree Pose'],
        correctAnswer: 0,
        explanation: 'Cat-Cow alternates spinal flexion and extension from a tabletop position.',
        hint: 'Think of the pose named after two animals.',
      ),
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.hard,
        question: 'Which yoga pose is commonly used as a resting posture with the hips moving toward the heels?',
        answers: ['Child’s Pose', 'Chair Pose', 'Crow Pose', 'Boat Pose'],
        correctAnswer: 0,
        explanation: 'Child’s Pose commonly brings the hips toward the heels while the torso folds forward.',
        hint: 'Choose the pose often used for rest between sequences.',
      ),
      _QuizQuestion(
        category: _QuizCategory.yoga,
        difficulty: _QuizDifficulty.hard,
        question: 'What is a useful focus when practicing a balance pose?',
        answers: ['A steady gaze and controlled breathing', 'Looking around constantly', 'Holding the breath', 'Moving as quickly as possible'],
        correctAnswer: 0,
        explanation: 'A steady gaze and controlled breathing can support concentration during balance practice.',
        hint: 'Think about what helps attention and steadiness.',
      ),

      // MEDITATION
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.beginner,
        question: 'What is a common goal of mindfulness practice?',
        answers: ['Notice the present moment', 'Never have thoughts', 'Avoid all emotions', 'Stay awake all night'],
        correctAnswer: 0,
        explanation: 'Mindfulness involves paying attention to present-moment experience with awareness.',
        hint: 'Think about where attention is directed.',
      ),
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.beginner,
        question: 'During a simple breathing meditation, what can you use as an anchor?',
        answers: ['The sensation of breathing', 'A random noise only', 'A heavy workout', 'A meal'],
        correctAnswer: 0,
        explanation: 'The sensations of breathing can provide a simple focus point for attention.',
        hint: 'Choose something happening continuously while you sit.',
      ),
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.moderate,
        question: 'If your attention wanders during mindfulness practice, what is a useful response?',
        answers: ['Gently notice it and return attention', 'Criticize yourself', 'Stop breathing', 'Give up immediately'],
        correctAnswer: 0,
        explanation: 'Noticing distraction and gently returning attention is a normal part of mindfulness practice.',
        hint: 'Choose the response that is non-judgmental and returns focus.',
      ),
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which environment can make a short meditation easier to practice?',
        answers: ['A reasonably quiet comfortable space', 'A dangerous location', 'A place where you cannot sit safely', 'A loud alarm beside you'],
        correctAnswer: 0,
        explanation: 'A comfortable, reasonably quiet space can reduce distractions during a short practice.',
        hint: 'Look for the setting that supports concentration.',
      ),
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.hard,
        question: 'What does a body scan meditation mainly involve?',
        answers: ['Noticing sensations in different body areas', 'Maximizing lifting weight', 'Counting calories', 'Running intervals'],
        correctAnswer: 0,
        explanation: 'A body scan directs attention through different areas of the body and notices sensations.',
        hint: 'The name points toward systematically noticing the body.',
      ),
      _QuizQuestion(
        category: _QuizCategory.meditation,
        difficulty: _QuizDifficulty.hard,
        question: 'Which description best matches non-judgmental awareness?',
        answers: ['Notice an experience without immediately labeling it good or bad', 'Suppress every thought', 'Force one emotion', 'Ignore all sensations'],
        correctAnswer: 0,
        explanation: 'Non-judgmental awareness means observing experience without immediately judging it.',
        hint: 'Focus on observing rather than evaluating.',
      ),

      // SLEEP
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which habit can support a consistent sleep routine?',
        answers: ['Keeping a regular bedtime', 'Changing bedtime every hour', 'Skipping sleep after exercise', 'Using bright screens all night'],
        correctAnswer: 0,
        explanation: 'A regular sleep schedule can help keep sleep timing consistent.',
        hint: 'Look for the habit that creates a predictable routine.',
      ),
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.beginner,
        question: 'Why is sleep important for students?',
        answers: ['It supports recovery and learning', 'It makes hydration unnecessary', 'It replaces all exercise', 'It removes the need for meals'],
        correctAnswer: 0,
        explanation: 'Sleep supports physical recovery and cognitive processes involved in learning.',
        hint: 'Think about both body recovery and the brain.',
      ),
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which bedroom condition is generally more sleep-friendly?',
        answers: ['Cool, dark and quiet', 'Very bright and noisy', 'Extremely hot and loud', 'Constantly changing lights'],
        correctAnswer: 0,
        explanation: 'A cool, dark and quiet environment is generally more conducive to sleep.',
        hint: 'Choose the environment with fewer sensory distractions.',
      ),
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which behavior can make winding down before bed easier?',
        answers: ['A calm pre-sleep routine', 'Intense activity immediately before bed every night', 'Constant notifications', 'Skipping all relaxation'],
        correctAnswer: 0,
        explanation: 'A calm routine can provide a consistent transition toward sleep.',
        hint: 'Think about a predictable signal that the day is ending.',
      ),
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.hard,
        question: 'Which term describes the body’s roughly 24-hour timing system?',
        answers: ['Circadian rhythm', 'Sprint interval', 'Glycemic load', 'Progressive overload'],
        correctAnswer: 0,
        explanation: 'The circadian rhythm is an approximately 24-hour biological timing system.',
        hint: 'Think about the biological clock.',
      ),
      _QuizQuestion(
        category: _QuizCategory.sleep,
        difficulty: _QuizDifficulty.hard,
        question: 'Which practice is most consistent with good sleep hygiene?',
        answers: ['Keeping sleep and wake times consistent', 'Sleeping at completely random times', 'Using caffeine right before bed', 'Replacing sleep with naps only'],
        correctAnswer: 0,
        explanation: 'Consistent sleep and wake times are a common sleep-hygiene practice.',
        hint: 'Look for the habit that stabilizes the daily sleep schedule.',
      ),

      // HYDRATION
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which drink is a simple choice for everyday hydration?',
        answers: ['Water', 'Very sugary soda', 'Energy drink only', 'Syrup'],
        correctAnswer: 0,
        explanation: 'Water is a simple way to provide fluids without added sugar.',
        hint: 'Choose the basic fluid your body needs.',
      ),
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which sign can indicate that you may need fluids?',
        answers: ['Thirst', 'A louder ringtone', 'Faster typing', 'Brighter screen'],
        correctAnswer: 0,
        explanation: 'Thirst is a normal signal that can prompt you to drink fluids.',
        hint: 'Think about the body’s direct signal for needing a drink.',
      ),
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.moderate,
        question: 'Why can fluid needs increase during exercise?',
        answers: ['The body loses water through sweat', 'Muscles stop using energy', 'Breathing stops', 'Food becomes unnecessary'],
        correctAnswer: 0,
        explanation: 'Sweating during exercise can increase fluid loss, raising the need to replace fluids.',
        hint: 'Think about what leaves the body during sweating.',
      ),
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which food can also contribute water to the diet?',
        answers: ['Watermelon', 'Table salt', 'Dry flour', 'Hard candy'],
        correctAnswer: 0,
        explanation: 'Watermelon contains a high proportion of water and can contribute to fluid intake.',
        hint: 'Think of a fruit with a very high water content.',
      ),
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.hard,
        question: 'What is one reason very sugary drinks may not be the best everyday hydration choice?',
        answers: ['They can add a lot of added sugar', 'They contain no liquid', 'They always cause dehydration', 'They replace the need for food'],
        correctAnswer: 0,
        explanation: 'Sugary drinks can provide fluids but may also add substantial amounts of added sugar.',
        hint: 'Focus on what else comes with the fluid.',
      ),
      _QuizQuestion(
        category: _QuizCategory.hydration,
        difficulty: _QuizDifficulty.hard,
        question: 'Which statement about hydration during exercise is most accurate?',
        answers: ['Fluid needs vary with conditions and activity', 'Everyone needs exactly the same amount', 'Sweating never affects fluid needs', 'Water is never useful during activity'],
        correctAnswer: 0,
        explanation: 'Fluid needs can vary with activity level, heat, duration, and individual factors.',
        hint: 'Look for the option that recognizes differences between situations.',
      ),

      // HEALTHY HABITS
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.beginner,
        question: 'Which habit supports general wellness?',
        answers: ['Regular movement and adequate rest', 'Skipping sleep', 'Avoiding all movement', 'Skipping every meal'],
        correctAnswer: 0,
        explanation: 'Regular activity together with adequate rest supports a balanced routine.',
        hint: 'Choose the option that includes both activity and recovery.',
      ),
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.beginner,
        question: 'What is a useful way to make a new habit easier to maintain?',
        answers: ['Start small and repeat it consistently', 'Make it impossible to schedule', 'Change the goal every hour', 'Never track it'],
        correctAnswer: 0,
        explanation: 'Small, repeatable actions are often easier to build into a routine.',
        hint: 'Think consistency rather than intensity.',
      ),
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.moderate,
        question: 'Which choice is an example of active recovery?',
        answers: ['Gentle walking', 'Maximum-effort sprinting', 'A heavy maximal lift', 'Skipping all movement for weeks'],
        correctAnswer: 0,
        explanation: 'Gentle movement can be used as a lower-intensity recovery activity.',
        hint: 'Look for movement that is easy rather than maximal.',
      ),
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.moderate,
        question: 'Why can tracking habits be useful?',
        answers: ['It makes patterns and consistency easier to notice', 'It guarantees perfect results', 'It replaces action', 'It removes the need for rest'],
        correctAnswer: 0,
        explanation: 'Tracking can make patterns and consistency visible, which can support habit building.',
        hint: 'Choose the option about learning from your behavior.',
      ),
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.hard,
        question: 'Which approach is most sustainable when increasing physical activity?',
        answers: ['Increase gradually while allowing recovery', 'Increase everything at once', 'Train hard every day without rest', 'Ignore pain and fatigue'],
        correctAnswer: 0,
        explanation: 'Gradual progression with recovery allows the body time to adapt.',
        hint: 'Think about progression plus recovery.',
      ),
      _QuizQuestion(
        category: _QuizCategory.healthyHabits,
        difficulty: _QuizDifficulty.hard,
        question: 'Which combination best represents a balanced wellness routine?',
        answers: ['Movement, nutrition, hydration, sleep and recovery', 'Exercise only', 'Supplements only', 'Sleep only'],
        correctAnswer: 0,
        explanation: 'Wellness is supported by several connected habits rather than one behavior alone.',
        hint: 'Look for the option covering multiple parts of daily health.',
      ),
    ];
  }
}

class _QuizQuestion {
  final _QuizCategory category;
  final _QuizDifficulty difficulty;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String explanation;
  final String hint;

  const _QuizQuestion({
    required this.category,
    required this.difficulty,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
  });
}
