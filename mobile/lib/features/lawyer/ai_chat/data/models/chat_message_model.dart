import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.content,
    required super.isFromUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final contentValue = json['reply'] as String? ?? json['content'] as String? ?? '';
    final isFromUserValue = (json['isFromUser'] as bool?) ?? false;
    final timestampValue = json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now();

    return ChatMessageModel(
      content: contentValue,
      isFromUser: isFromUserValue,
      timestamp: timestampValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isFromUser': isFromUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
