import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../services/gemini_coach_service.dart';

class AiCoachScreen extends StatefulWidget {
  final AppState? appState;

  const AiCoachScreen({
    super.key,
    this.appState,
  });

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final GeminiCoachService _coachService;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hey! I'm your **FitQuest AI Coach** powered by Google Gemini. ⚡\n\nAsk me for custom dorm room workouts, cafeteria meal advice, posture fixes, or stress relief between classes!",
      isCoach: true,
    ),
  ];

  bool _typing = false;

  final List<Map<String, String>> _quickPrompts = [
    {'label': '🏠 15-Min Dorm Workout', 'prompt': 'Give me a 15-minute dorm room workout without any equipment.'},
    {'label': '🥗 Campus Canteen Diet', 'prompt': 'How should I choose healthy high-protein meals in a college mess/canteen?'},
    {'label': '🧠 Exam De-Stress', 'prompt': 'I feel stressed from exams. What are quick body stretches and breathing exercises to focus?'},
    {'label': '🏋️ Perfect Squat Form', 'prompt': 'How do I fix my squat form to prevent knee and lower back pain?'},
    {'label': '🔥 Boost My Streak', 'prompt': 'Give me quick motivation to stay consistent with my fitness streak today.'},
  ];

  @override
  void initState() {
    super.initState();
    _coachService = GeminiCoachService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickMessage]) async {
    final text = (quickMessage ?? _controller.text).trim();

    if (text.isEmpty || _typing) {
      return;
    }

    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isCoach: false));
      _typing = true;
    });

    _scrollToBottom();

    try {
      final responseText = await _coachService.sendMessage(
        userMessage: text,
        appState: widget.appState,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: responseText, isCoach: true));
        _typing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          const _ChatMessage(
            text: "I'm having a little trouble connecting right now, but remember: 20 minutes of daily movement keeps your streak alive! ⚡",
            isCoach: true,
          ),
        );
        _typing = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF302B63), Color(0xFF00F5D4)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FitQuest AI Coach',
                  style: TextStyle(
                    color: Color(0xFF151B3D),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00F5D4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Gemini AI Active',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF151B3D)),
      ),
      body: Column(
        children: [
          // Quick prompt chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _quickPrompts.map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      onPressed: () => _sendMessage(chip['prompt']),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text(
                        chip['label']!,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _typing) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Bottom Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isCoach = message.isCoach;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isCoach ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCoach) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF302B63),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCoach ? Colors.white : const Color(0xFF302B63),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isCoach ? 4 : 18),
                  bottomRight: Radius.circular(isCoach ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isCoach ? 0.05 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: isCoach
                    ? Border.all(color: const Color(0xFFE2E8F0))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCoach ? const Color(0xFF1E293B) : Colors.white,
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: isCoach ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                  if (isCoach) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Copied advice to clipboard!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isCoach) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF00F5D4),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 16))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF302B63),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF302B63)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Coach is typing...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  hintText: 'Ask your AI Coach anything...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF302B63),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.send_rounded,
                  color: Color(0xFF00F5D4),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
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