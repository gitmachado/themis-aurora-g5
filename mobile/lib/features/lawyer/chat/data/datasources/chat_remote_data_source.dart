import '../../../../../../shared/network/api_client.dart';
import '../models/chat_message_model.dart';

final class ChatRemoteDataSource {
  final ApiClient _apiClient;

  const ChatRemoteDataSource(this._apiClient);

  Future<List<ChatMessageModel>> getHistoryByWhatsapp(
    String whatsappNumber,
  ) async {
    final list = await _apiClient.getList('/messages/$whatsappNumber');
    return list
        .map(
          (json) =>
              ChatMessageModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }
}
