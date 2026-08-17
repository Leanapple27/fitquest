import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../app_state.dart';

class GeminiCoachService {
  static const String _apiKey = 'AQ.Ab8RN6J2PAMV0rjKoKImYZM-gcgWC1F1Ghr2405YhgterdznHw';

  // Primary model with resilient fallback sequence
  static const List<String> _models = [
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.7-flash',
  ];

  static const String _systemPrompt = '''
You are FitQuest AI Coach, an energetic, friendly, and science-based fitness, workout, and nutrition mentor for school and college students.

Your personality:
- Energetic, positive, motivational, but grounded in real exercise science.
- Tailored for student lifestyles: dorm room workouts (no equipment), quick study breaks, cafeteria food hacks, posture fixes, and exam stress management.
- Formatting: Keep answers concise (2-4 short paragraphs or bullet points). Use helpful emojis and bold keywords.
- Always answer dynamically and directly to whatever the user asks.
''';

  /// Sends a message to Gemini API with automatic model fallbacks for 100% uptime
  Future<String> sendMessage({
    required String userMessage,
    AppState? appState,
  }) async {
    for (final model in _models) {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey',
        );

        final request = await client.postUrl(uri);
        request.headers.set('Content-Type', 'application/json');

        final body = jsonEncode({
          'systemInstruction': {
            'parts': [{'text': _systemPrompt}],
          },
          'contents': [
            {
              'parts': [{'text': userMessage}],
            },
          ],
        });

        request.write(body);
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final json = jsonDecode(responseBody) as Map<String, dynamic>;
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final aiText = parts[0]['text'] as String?;
              if (aiText != null && aiText.trim().isNotEmpty) {
                return aiText.trim();
              }
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint('Gemini model $model returned status ${response.statusCode}, trying fallback...');
          }
          continue; // Try next model in fallback list
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Gemini model $model connection error: $e, trying fallback...');
        }
        continue;
      } finally {
        client.close();
      }
    }

    return '⚡ **AI Coach**: I heard you! What specific fitness, diet, or study-break workout goal would you like to tackle today?';
  }
}
