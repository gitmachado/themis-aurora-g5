import '../../domain/entities/chat_message.dart';

final class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.content,
    super.leadId,
    super.userId,
    super.whatsappMessageId,
    super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      leadId: json['leadId'] as String?,
      userId: json['userId'] as String?,
      sender: json['sender'] as String? ?? 'BOT',
      content: json['content'] as String? ?? '',
      whatsappMessageId: json['whatsappMessageId'] as String?,
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'userId': userId,
      'sender': sender,
      'content': content,
      'whatsappMessageId': whatsappMessageId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
