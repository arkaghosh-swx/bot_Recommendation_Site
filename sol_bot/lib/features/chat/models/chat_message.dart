// lib/features/chat/models/chat_message.dart

enum MessageRole { user, bot }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.time,
  });

  String get formattedTime {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.name,
        'text': text,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        role: MessageRole.values.firstWhere((r) => r.name == map['role']),
        text: map['text'] as String,
        time: DateTime.parse(map['time'] as String),
      );

  ChatMessage copyWith({String? text}) => ChatMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        time: time,
      );
}