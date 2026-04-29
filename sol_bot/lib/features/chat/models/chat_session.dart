// lib/features/chat/models/chat_session.dart

import 'chat_message.dart';

class ChatSession {
  final String id;
  String label;
  final List<ChatMessage> messages;
  final List<Map<String, String>> apiHistory; // for Groq context
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.label,
    List<ChatMessage>? messages,
    List<Map<String, String>>? apiHistory,
    DateTime? createdAt,
  }) : messages = messages ?? [],
       apiHistory = apiHistory ?? [],
       createdAt = createdAt ?? DateTime.now();

  bool get isEmpty => messages.isEmpty;

  bool get hasUserMessages => messages.any((m) => m.role == MessageRole.user);

  void addMessage(ChatMessage msg) {
    messages.add(msg);
    // Auto-label from first user message
    if (msg.role == MessageRole.user && !hasUserMessages) {
      label = msg.text.length > 38 ? '${msg.text.substring(0, 38)}…' : msg.text;
    } else if (msg.role == MessageRole.user &&
        messages.where((m) => m.role == MessageRole.user).length == 1) {
      label = msg.text.length > 38 ? '${msg.text.substring(0, 38)}…' : msg.text;
    }
  }

  void addToApiHistory(String role, String content) {
    apiHistory.add({'role': role, 'content': content});
  }

  List<Map<String, String>> get trimmedApiHistory {
    const max = 20;
    if (apiHistory.length <= max) return List.from(apiHistory);
    return apiHistory.sublist(apiHistory.length - max);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'messages': messages.map((m) => m.toMap()).toList(),
    'apiHistory': apiHistory,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatSession.fromMap(Map<String, dynamic> map) => ChatSession(
    id: map['id'] as String,
    label: map['label'] as String,
    messages: (map['messages'] as List)
        .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
        .toList(),
    apiHistory: (map['apiHistory'] as List)
        .map((h) => Map<String, String>.from(h as Map))
        .toList(),
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
