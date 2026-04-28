import '../../../../shared/network/token_storage.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _tokenStorage.saveToken(session.token);

    final account = await _remoteDataSource.getAccount();
    return session.copyWith(
      userId: account.id,
      role: account.role,
      account: account,
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) return null;

    final account = await _remoteDataSource.getAccount();
    return AuthSession(
      token: token,
      userId: account.id,
      role: account.role,
      account: account,
    );
  }

  @override
  Future<Account> getAccount() {
    return _remoteDataSource.getAccount();
  }

  @override
  Future<Account> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  ) {
    return _remoteDataSource.updateNotificationPreferences(
      notificationPreferences,
    );
  }

  @override
  Future<void> logout() => _tokenStorage.clearToken();
}
