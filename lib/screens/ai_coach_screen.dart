import 'package:flutter/material.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hey! I'm your FitQuest Coach. Tell me your goal, your available time, or what you're struggling with.",
      isCoach: true,
    ),
  ];

  bool _typing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickMessage]) {
    final text =
        (quickMessage ?? _controller.text).trim();

    if (text.isEmpty || _typing) {
      return;
    }

    _controller.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isCoach: false,
        ),
      );

      _typing = true;
    });

    _scrollToBottom();

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        setState(() {
          _messages.add(
            _ChatMessage(
              text: _generateCoachResponse(text),
              isCoach: true,
            ),
          );

          _typing = false;
        });

        _scrollToBottom();
      },
    );
  }

  String _generateCoachResponse(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('20') ||
        lower.contains('workout') ||
        lower.contains('exercise')) {
      return 'Perfect! Here is a 20-minute workout:\n\n'
          '3 min warm-up\n'
          '8 min bodyweight circuit\n'
          '5 min cardio\n'
          '2 min core\n'
          '2 min cooldown\n\n'
          'You can do it without equipment. Stay consistent!';
    }

    if (lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('nutrition') ||
        lower.contains('diet')) {
      return 'For a simple fitness-friendly meal, aim for '
          'protein, vegetables or fruit, healthy carbohydrates, '
          'and healthy fats.\n\n'
          'And remember to stay hydrated!';
    }

    if (lower.contains('steps') ||
        lower.contains('walking')) {
      return 'Walking is a great way to increase your daily '
          'activity.\n\n'
          'Set a realistic target and gradually increase it. '
          'Your FitQuest Step Counter can track your progress.';
    }

    if (lower.contains('motivat') ||
        lower.contains('tired') ||
        lower.contains('lazy')) {
      return 'You do not need a perfect workout today.\n\n'
          'Start with just 5 minutes. The hardest part is '
          'getting started. Progress beats perfection!';
    }

    if (lower.contains('streak')) {
      return 'Protect that streak!\n\n'
          'Even a short walk or quick workout keeps your '
          'momentum going. Keep showing up!';
    }

    return 'Great question!\n\n'
        'Start small, stay consistent, and track your progress. '
        'Tell me how much time you have today and I can suggest '
        'a workout.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Color(0xFF302B63),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'FitQuest Coach',
                  style: TextStyle(
                    color: Color(0xFF151B3D),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                Text(
                  'Your personal fitness companion',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcomeCard(),

                const SizedBox(height: 16),

                ..._messages.map(
                  (message) =>
                      _buildMessage(message),
                ),

                if (_typing)
                  _buildTypingIndicator(),
              ],
            ),
          ),

          _buildQuickActions(),

          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF302B63),
            Color(0xFF51489A),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR AI FITNESS COACH',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Train smarter.\nStay consistent.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Ask about workouts, nutrition, motivation, '
            'steps, or your fitness goals.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(
    _ChatMessage message,
  ) {
    return Align(
      alignment: message.isCoach
          ? Alignment.centerLeft
          : Alignment.centerRight,

      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 330,
        ),

        margin:
            const EdgeInsets.only(bottom: 12),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),

        decoration: BoxDecoration(
          color: message.isCoach
              ? Colors.white
              : const Color(0xFF302B63),

          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft:
                Radius.circular(
              message.isCoach ? 4 : 18,
            ),
            bottomRight:
                Radius.circular(
              message.isCoach ? 18 : 4,
            ),
          ),
        ),

        child: Text(
          message.text,
          style: TextStyle(
            color: message.isCoach
                ? const Color(0xFF151B3D)
                : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: const Text(
          'Coach is thinking...',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      'Workout',
      'Nutrition',
      'My steps',
      'Motivation',
    ];

    return SizedBox(
      height: 48,

      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),

        scrollDirection:
            Axis.horizontal,

        itemCount: actions.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(width: 8),

        itemBuilder:
            (context, index) {
          final action =
              actions[index];

          return OutlinedButton(
            onPressed: () {
              _sendMessage(
                'Tell me about '
                '${action.toLowerCase()}',
              );
            },

            style:
                OutlinedButton.styleFrom(
              backgroundColor:
                  Colors.white,

              side: const BorderSide(
                color: Color(0xFFE3E4EA),
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),

            child: Text(
              action,
              style: const TextStyle(
                color:
                    Color(0xFF151B3D),
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,

      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          12,
        ),

        color: Colors.white,

        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,

                textInputAction:
                    TextInputAction.send,

                onSubmitted:
                    (_) => _sendMessage(),

                decoration:
                    InputDecoration(
                  hintText:
                      'Ask your coach...',

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF5F6FA,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 48,
              height: 48,

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFF302B63),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: IconButton(
                onPressed: _typing
                    ? null
                    : () => _sendMessage(),

                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isCoach;

  const _ChatMessage({
    required this.text,
    required this.isCoach,
  });
}