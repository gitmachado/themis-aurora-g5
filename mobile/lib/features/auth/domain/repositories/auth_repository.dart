import '../entities/auth_session.dart';
import '../entities/account.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String identifier,
    required String password,
  });

  Future<AuthSession?> restoreSession();

  Future<Account> getAccount();

  Future<Account> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  );

  Future<void> logout();
}
