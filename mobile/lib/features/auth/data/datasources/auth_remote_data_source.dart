import '../../../../shared/network/api_client.dart';
import '../models/account_model.dart';
import '../models/auth_session_model.dart';

final class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return AuthSessionModel.fromJson(json);
  }

  Future<AccountModel> getAccount() async {
    final json = await _apiClient.getJson('/account');
    return AccountModel.fromJson(_normalizeAccountJson(json));
  }

  Future<AccountModel> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  ) async {
    final json = await _apiClient.patchJson(
      '/account/notification-preferences',
      data: {'notificationPreferences': notificationPreferences},
    );
    return AccountModel.fromJson(_normalizeAccountJson(json));
  }

  Future<AccountModel> uploadAvatar({
    required String filePath,
    required String fileName,
  }) async {
    final json = await _apiClient.postMultipart(
      '/account/avatar',
      fileField: 'file',
      filePath: filePath,
      fileName: fileName,
    );
    return AccountModel.fromJson(_normalizeAccountJson(json));
  }

  Map<String, dynamic> _normalizeAccountJson(Map<String, dynamic> json) {
    final avatarUrl = json['avatarUrl'];
    if (avatarUrl is! String || avatarUrl.isEmpty) {
      return json;
    }

    return {...json, 'avatarUrl': _apiClient.buildAbsoluteUrl(avatarUrl)};
  }
}
