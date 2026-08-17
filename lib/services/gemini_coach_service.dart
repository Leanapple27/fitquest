import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../app_state.dart';

class GeminiCoachService {
  static const String _defaultApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.Ab8RN6J2PAMV0rjKoKImYZM-gcgWC1F1Ghr2405YhgterdznHw',
  );

  static const String _systemPrompt = '''
You are FitQuest Coach, a high-energy, friendly, and science-based fitness, workout, and nutrition AI mentor for school and college students.

Your personality:
- Energetic, positive, motivational, but grounded in real exercise science.
- Tailored for student lifestyles: dorm room workouts (no equipment), quick 15-minute study breaks, cafeteria food hacks, and exam stress management.
- Formatting: Keep answers concise (2-4 short paragraphs or bullet points). Use helpful emojis and bold keywords.
- Always encourage consistency and safety over extreme workouts.
''';

  GenerativeModel? _model;
  ChatSession? _chatSession;
  final String _apiKey;

  GeminiCoachService({String? apiKey}) : _apiKey = apiKey ?? _defaultApiKey {
    _initModel();
  }

  void _initModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 800,
        ),
      );
      _chatSession = _model?.startChat();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Gemini Model: $e');
      }
    }
  }

  /// Sends a message to Gemini and returns the dynamic AI response
  Future<String> sendMessage({
    required String userMessage,
    AppState? appState,
  }) async {
    // 1. Try Direct REST API call (most reliable with latest model endpoints)
    if (_apiKey.isNotEmpty) {
      try {
        final restResponse = await _queryGeminiRest(userMessage);
        if (restResponse != null && restResponse.trim().isNotEmpty) {
          return restResponse.trim();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('REST Gemini query error: $e');
        }
      }
    }

    // 2. Try SDK ChatSession
    if (_chatSession != null && _apiKey.isNotEmpty) {
      try {
        final response = await _chatSession!.sendMessage(
          Content.text(userMessage),
        );

        final text = response.text;
        if (text != null && text.trim().isNotEmpty) {
          return text.trim();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SDK Gemini API Error: $e');
        }
      }
    }

    // 3. Fallback to contextual intelligence
    return _generateContextualResponse(userMessage, appState);
  }

  Future<String?> _queryGeminiRest(String message) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_apiKey',
      );

      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final body = jsonEncode({
        'systemInstruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': [
          {
            'parts': [{'text': message}],
          },
        ],
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final candidates = json['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String?;
          }
        }
      }
    } finally {
      client.close();
    }
    return null;
  }

  String _generateContextualResponse(String query, AppState? appState) {
    final lower = query.toLowerCase();
    final streak = appState?.streak ?? 12;
    final level = appState?.currentLevel ?? 7;

    if (lower.contains('dorm') || lower.contains('room') || lower.contains('no equipment')) {
      return '🏠 **15-Minute Dorm Room Quick Blast** (No Equipment!)\n\n'
          '• **Warmup (2m)**: 30s Arm circles + 30s Jumping jacks + 1m High knees\n'
          '• **Circuit (3 rounds)**:\n'
          '  - 15 Bodyweight Squats\n'
          '  - 10 Incline Desk/Chair Push-ups\n'
          '  - 20 Mountain Climbers\n'
          '  - 30s Plank Hold\n'
          '• **Cooldown (2m)**: Hamstring & chest stretches.\n\n'
          '💡 *Tip: Do this right between your study sessions to boost brain focus!*';
    }

    if (lower.contains('canteen') || lower.contains('mess') || lower.contains('food') || lower.contains('diet') || lower.contains('eat')) {
      return '🥗 **Campus Canteen & Mess Nutrition Guide**:\n\n'
          '1. **Protein First**: Prioritize eggs, paneer, dal/lentils, curd/yogurt, or grilled chicken.\n'
          '2. **Smart Carbs**: Choose roti/brown rice over oily fried items like samosas.\n'
          '3. **Hydration**: Drink 1 glass of water 15 minutes before your meal.\n'
          '4. **Hostel Snack Stash**: Keep roasted chana, almonds, peanut butter, and fruit in your room!';
    }

    if (lower.contains('exam') || lower.contains('stress') || lower.contains('study') || lower.contains('tired')) {
      return '🧠 **Exam De-Stress & Focus Protocol**:\n\n'
          '• **The 20-20-20 Body Reset**: After every 50 mins of studying, stand up and do 20 gentle body twists + 10 deep box breaths (Inhale 4s, Hold 4s, Exhale 4s, Hold 4s).\n'
          '• **5-Min Neck & Shoulder Relief**: Roll shoulders backward 10 times to release desk tension.\n'
          '• **Sleep Anchor**: Avoid phone screens 30 minutes before bed so your memory consolidates.';
    }

    if (lower.contains('squat') || lower.contains('form') || lower.contains('posture')) {
      return '🏋️ **Mastering Your Squat Form**:\n\n'
          '1. **Feet Placement**: Shoulder-width apart, toes pointed slightly outward (15°).\n'
          '2. **Chest Up**: Keep your chest tall and eyes looking straight ahead.\n'
          '3. **Knees Out**: Push knees in the direction of your toes, don\'t let them cave inward.\n'
          '4. **Depth**: Lower until hips are at least parallel to your knees, then drive through your heels!';
    }

    if (lower.contains('streak') || lower.contains('motivat')) {
      return '🔥 **Keep The Momentum Going!**\n\n'
          'You are currently at **Level $level** with an active **$streak-Day Streak**!\n\n'
          'Consistency is the secret superpower. Even a 5-minute stretch or a brisk 1,000-step campus walk keeps your streak alive and builds mental toughness. You got this! ⚡';
    }

    return '⚡ **FitQuest AI Coach Insight**:\n\n'
        'Great question! For maximum progress on campus:\n'
        '• Aim for at least **6,000 to 8,000 steps** walking between lecture halls.\n'
        '• Complete your **3 Daily Quests** to keep your streak burning.\n'
        '• Prioritize **7-8 hours of quality sleep** to recover faster.\n\n'
        'Would you like a custom workout plan, canteen meal ideas, or posture relief stretches?';
  }
}
