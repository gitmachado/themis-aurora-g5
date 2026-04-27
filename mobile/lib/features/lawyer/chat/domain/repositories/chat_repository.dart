import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<List<ChatMessage>> getHistoryByWhatsapp(String whatsappNumber);
}
