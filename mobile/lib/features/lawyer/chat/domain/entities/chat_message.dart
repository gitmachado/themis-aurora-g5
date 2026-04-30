import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String? leadId;
  final String? userId;
  final String sender;
  final String content;
  final String? whatsappMessageId;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    this.leadId,
    this.userId,
    this.whatsappMessageId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    leadId,
    userId,
    sender,
    content,
    whatsappMessageId,
    createdAt,
  ];
}
