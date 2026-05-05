import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/network/token_storage.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
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

  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.googleClientId,
      );
      _googleSignInInitialized = true;
    }
  }

  @override
  Future<Either<Failure, AuthSession>> signInWithGoogle() {
    return guardRepository(() async {
      await _ensureGoogleSignInInitialized();
      final googleSignIn = GoogleSignIn.instance;

      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerFailure('Falha ao obter token do Google');
      }

      final session = await _remoteDataSource.googleSignIn(idToken);
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
  Future<Either<Failure, Account>> changePassword({
    required String newPassword,
    String? currentPassword,
  }) {
    return guardRepository(
      () => _remoteDataSource.changePassword(
        newPassword: newPassword,
        currentPassword: currentPassword,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guardRepositoryUnit(() async {
      await _tokenStorage.clearToken();
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    });
  }
}
