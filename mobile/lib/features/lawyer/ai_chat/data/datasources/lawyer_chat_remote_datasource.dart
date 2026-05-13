import '../../../../../../shared/network/api_client.dart';
import '../models/chat_message_model.dart';

final class LawyerChatRemoteDataSource {
  final ApiClient _apiClient;

  const LawyerChatRemoteDataSource(this._apiClient);

  Future<ChatMessageModel> sendMessage(String message) async {
    final response = await _apiClient.postJson(
      '/ai/lawyer-chat',
      data: {'message': message},
    );
    return ChatMessageModel.fromJson(response);
  }
}
