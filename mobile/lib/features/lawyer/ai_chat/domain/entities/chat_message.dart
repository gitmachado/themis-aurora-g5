import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [content, isFromUser, timestamp];
}
