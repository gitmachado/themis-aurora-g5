import '../../../../shared/network/api_client.dart';
import '../models/app_notification_model.dart';

final class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  const NotificationRemoteDataSource(this._apiClient);

  Future<List<AppNotificationModel>> getMyNotifications() async {
    final list = await _apiClient.getList('/notifications/my');
    return list
        .map(
          (json) => AppNotificationModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patchJson('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.postVoid('/notifications/read-all');
  }

  Future<void> delete(String id) async {
    await _apiClient.deleteVoid('/notifications/$id');
  }
}
