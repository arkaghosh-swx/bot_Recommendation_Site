// lib/features/chat/services/groq_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sol_bot/core/constants/app_constants.dart';

class GroqService {
  static Future<String> chat({
    required String userMessage,
    required List<Map<String, String>> history,
    required String faqContext,
  }) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': '${AppConstants.systemPrompt}\n\nFAQs:\n$faqContext',
        },
        ...history,
      ];

      final response = await http.post(
        Uri.parse(AppConstants.groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          return choices[0]['message']['content'] as String;
        }
        return 'No response received.';
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'] as Map<String, dynamic>?;
        return '⚠️ API Error: ${error?['message'] ?? response.statusCode}';
      }
    } catch (e) {
      return '⚠️ Connection failed. Please check your network and try again.';
    }
  }
}