// lib/features/chat/models/faq_model.dart

class FaqItem {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int sortOrder;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.sortOrder,
  });

  factory FaqItem.fromMap(Map<String, dynamic> map) => FaqItem(
    id: map['id'] as int,
    question: map['question'] as String,
    answer: map['answer'] as String,
    category: map['category'] as String? ?? 'General',
    sortOrder: map['sort_order'] as int? ?? 0,
  );

  String toContextString() => 'Q: $question\nA: $answer';
}
