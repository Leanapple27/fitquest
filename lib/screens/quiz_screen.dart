import 'package:flutter/material.dart';
import '../app_state.dart';

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
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;
  bool answered = false;
  bool quizFinished = false;

  // XP actually awarded for this attempt.
  int awardedXp = 0;

  final List<_QuizQuestion> questions = [
    _QuizQuestion(
      question:
          'How much physical activity is generally recommended for teenagers each day?',
      answers: [
        'About 60 minutes',
        'About 5 minutes',
        'About 10 minutes',
        'Only on weekends',
      ],
      correctAnswer: 0,
    ),
    _QuizQuestion(
      question:
          'Which drink is usually the best choice for staying hydrated during the day?',
      answers: [
        'Water',
        'Energy drink',
        'Very sugary soda',
        'Only milkshakes',
      ],
      correctAnswer: 0,
    ),
    _QuizQuestion(
      question:
          'What should you do before intense physical activity?',
      answers: [
        'Warm up',
        'Skip all movement',
        'Immediately sprint',
        'Avoid drinking water',
      ],
      correctAnswer: 0,
    ),
    _QuizQuestion(
      question:
          'Which is an important part of a balanced lifestyle?',
      answers: [
        'Regular activity and enough rest',
        'Never sleeping',
        'Skipping meals',
        'Exercising without rest',
      ],
      correctAnswer: 0,
    ),
    _QuizQuestion(
      question: 'Why is stretching useful?',
      answers: [
        'It can help prepare and loosen the body',
        'It replaces sleep',
        'It makes hydration unnecessary',
        'It means you never need to warm up',
      ],
      correctAnswer: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return _buildResultsScreen();
    }

    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'FitQuest Quiz',
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
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildProgress(),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF302B63),
                  borderRadius:
                      BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUESTION ${currentQuestion + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        height: 1.3,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'CHOOSE YOUR ANSWER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.black45,
                ),
              ),

              const SizedBox(height: 10),

              ...List.generate(
                question.answers.length,
                (index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _buildAnswerButton(
                      index,
                      question.answers[index],
                      question.correctAnswer,
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              if (answered)
                _buildFeedback(question),

              if (answered)
                const SizedBox(height: 14),

              if (answered)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF302B63),
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: Text(
                      currentQuestion ==
                              questions.length - 1
                          ? 'SEE RESULTS'
                          : 'NEXT QUESTION',
                      style: const TextStyle(
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

  Widget _buildProgress() {
    final double progress =
        (currentQuestion + 1) /
            questions.length;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor:
                  Colors.black12,
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
          '${currentQuestion + 1}/${questions.length}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF302B63),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
    int index,
    String answer,
    int correctAnswer,
  ) {
    final bool isSelected =
        selectedAnswer == index;

    final bool isCorrect =
        index == correctAnswer;

    Color backgroundColor =
        Colors.white;

    Color borderColor =
        Colors.transparent;

    Color textColor =
        const Color(0xFF151B3D);

    String? indicator;

    if (answered) {
      if (isCorrect) {
        backgroundColor =
            const Color(0xFFEAF6EE);
        borderColor =
            const Color(0xFF4CAF50);
        indicator = '✓';
      } else if (isSelected) {
        backgroundColor =
            const Color(0xFFFFE9E7);
        borderColor =
            const Color(0xFFE85D5D);
        indicator = '✕';
      }
    } else if (isSelected) {
      backgroundColor =
          const Color(0xFFEDEBFF);
      borderColor =
          const Color(0xFF51489A);
    }

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              _selectAnswer(index);
            },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: borderColor,
            width:
                borderColor ==
                        Colors.transparent
                    ? 0
                    : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: answered
                    ? Colors.white
                    : const Color(0xFFF0EFFF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  indicator ??
                      String.fromCharCode(
                        65 + index,
                      ),
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
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

  Widget _buildFeedback(
    _QuizQuestion question,
  ) {
    final bool correct =
        selectedAnswer ==
            question.correctAnswer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct
            ? const Color(0xFFEAF6EE)
            : const Color(0xFFFFE9E7),
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Text(
            correct ? '🎉' : '💡',
            style:
                const TextStyle(fontSize: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  correct
                      ? 'Correct!'
                      : 'Not quite!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                    color: correct
                        ? const Color(
                            0xFF27733A,
                          )
                        : const Color(
                            0xFFB54747,
                          ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  correct
                      ? '+20 XP'
                      : 'The correct answer is: '
                          '${question.answers[question.correctAnswer]}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final int total =
        questions.length;

    final double percentage =
        total == 0
            ? 0
            : score / total;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF302B63),
                      Color(0xFF51489A),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      percentage >= 0.8
                          ? '🏆'
                          : percentage >= 0.5
                              ? '🎉'
                              : '💪',
                      style:
                          const TextStyle(
                        fontSize: 58,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      percentage >= 0.8
                          ? 'Excellent!'
                          : percentage >= 0.5
                              ? 'Good Job!'
                              : 'Keep Practicing!',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $total correct',
                      style:
                          const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      awardedXp > 0
                          ? '+$awardedXp XP'
                          : 'No additional XP',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFFFFD166),
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'QUIZ SUMMARY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1,
                        color:
                            Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _resultRow(
                      'Questions',
                      '$total',
                    ),
                    _resultRow(
                      'Correct',
                      '$score',
                    ),
                    _resultRow(
                      'Score',
                      '${(percentage * 100).round()}%',
                    ),
                    _resultRow(
                      'XP Earned',
                      awardedXp > 0
                          ? '+$awardedXp XP'
                          : '+0 XP',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _restartQuiz();
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF302B63,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: const Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF302B63,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(0xFF302B63),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: const Text(
                    'BACK TO HOME',
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

  Widget _resultRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int index) {
    if (answered) {
      return;
    }

    final question =
        questions[currentQuestion];

    final bool correct =
        index == question.correctAnswer;

    setState(() {
      selectedAnswer = index;
      answered = true;

      if (correct) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (!answered) {
      return;
    }

    if (currentQuestion ==
        questions.length - 1) {
      final int xpReward =
          score * 20;

      // AppState prevents this quiz from
      // awarding XP more than once.
      final bool wasAwarded =
          widget.appState.completeQuiz(
        xpReward,
      );

      setState(() {
        awardedXp =
            wasAwarded ? xpReward : 0;
        quizFinished = true;
      });

      return;
    }

    setState(() {
      currentQuestion++;
      selectedAnswer = null;
      answered = false;
    });
  }

  void _restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      answered = false;
      quizFinished = false;
      awardedXp = 0;
    });
  }
}

class _QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctAnswer;

  const _QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });
}
