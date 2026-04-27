import '../../../../shared/network/api_client.dart';
import '../models/account_model.dart';
import '../models/auth_session_model.dart';

final class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  Future<AuthSessionModel> login({
    required String identifier,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
    );

    return AuthSessionModel.fromJson(json);
  }

  Future<AccountModel> getAccount() async {
    final json = await _apiClient.getJson('/account');
    return AccountModel.fromJson(json);
  }

  Future<AccountModel> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  ) async {
    final json = await _apiClient.patchJson(
      '/account/notification-preferences',
      data: {'notificationPreferences': notificationPreferences},
    );
    return AccountModel.fromJson(json);
  }
}
