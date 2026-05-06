// lib/features/chat/services/faq_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/faq_model.dart';

class FaqService {
  static final _client = Supabase.instance.client;

  // ── Fetch all FAQs ordered by sort_order ─────────────────
  static Future<List<FaqItem>> fetchFaqs() async {
    try {
      final response = await _client
          .from('faqs')
          .select('id, question, answer, category, sort_order')
          .order('sort_order', ascending: true);

      return (response as List)
          .map((row) => FaqItem.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ── Build FAQ context string for Groq system prompt ──────
  static String buildContext(List<FaqItem> faqs) {
    return faqs.map((f) => f.toContextString()).join('\n\n');
  }

  // ── Direct keyword match → instant answer, no API call ───
  // Mirrors JS checkFAQFirst()
  static FaqItem? findDirectMatch(String userText, List<FaqItem> faqs) {
    if (faqs.isEmpty) return null;
    final input = userText.toLowerCase();
    final words = input.split(' ').where((w) => w.length > 3).toList();

    for (final faq in faqs) {
      final q = faq.question.toLowerCase();
      if (words.any((w) => q.contains(w))) return faq;
    }
    return null;
  }
}
