import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

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
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) {
    return guardRepository(() async {
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
    });
  }

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() {
    return guardRepository(() async {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) return null;

      final account = await _remoteDataSource.getAccount();
      return AuthSession(
        token: token,
        userId: account.id,
        role: account.role,
        account: account,
      );
    });
  }

  @override
  Future<Either<Failure, Account>> getAccount() {
    return guardRepository(_remoteDataSource.getAccount);
  }

  @override
  Future<Either<Failure, Account>> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  ) {
    return guardRepository(
      () => _remoteDataSource.updateNotificationPreferences(
        notificationPreferences,
      ),
    );
  }

  @override
  Future<Either<Failure, Account>> uploadAvatar({
    required String filePath,
    required String fileName,
  }) {
    return guardRepository(
      () => _remoteDataSource.uploadAvatar(
        filePath: filePath,
        fileName: fileName,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guardRepositoryUnit(_tokenStorage.clearToken);
  }
}
