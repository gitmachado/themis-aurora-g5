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

  Future<ChatMessageModel> sendMessage(
    String whatsappNumber,
    String content,
  ) async {
    final json = await _apiClient.postJson(
      '/messages/send',
      data: {'whatsappNumber': whatsappNumber, 'content': content},
    );
    return ChatMessageModel.fromJson(json);
  }

  Future<void> resumeAI(String whatsappNumber) async {
    await _apiClient.postJson(
      '/leads/handoff-return',
      data: {'whatsappNumber': whatsappNumber},
    );
  }

  Future<void> handoffToHuman(String whatsappNumber) async {
    await _apiClient.postJson(
      '/leads/handoff-start',
      data: {'whatsappNumber': whatsappNumber},
    );
  }

  Future<Map<String, dynamic>> getLeadByPhone(String phone) async {
    return await _apiClient.getJson('/leads/whatsapp/$phone');
  }

  Future<void> assignLead(String leadId) async {
    await _apiClient.postJson('/leads/$leadId/assign');
  }

  Future<void> releaseLead(String leadId) async {
    await _apiClient.postJson('/leads/$leadId/release');
  }
}
