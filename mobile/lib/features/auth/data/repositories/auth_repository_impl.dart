import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      try {
        await GoogleSignIn.instance.initialize();
        _initialized = true;
      } catch (e) {
        // Se já estiver inicializado, o plugin pode lançar erro
        _initialized = true;
      }
    }
  }

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
  Future<Either<Failure, AuthSession>> signInWithGoogle() {
    return guardRepository(() async {
      try {
        await _ensureInitialized();

        // No google_sign_in 7.x, o método correto é authenticate()
        final googleUser = await GoogleSignIn.instance.authenticate();
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
      } catch (e) {
        if (kDebugMode) print('[GoogleSignIn Error]: $e');
        if (e.toString().contains('canceled')) {
          throw const ServerFailure('Login cancelado pelo usuário');
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() {
    return guardRepository(() async {
      final token = await _tokenStorage.readToken();
      if (token == null) return null;

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
    return guardRepository(() => _remoteDataSource.getAccount());
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
      // G5-75: tell the server to wipe the FCM token first so a logged-out
      // user keeps no push delivery target on the backend. Failures here
      // must not block the local sign-out: the user expects logout to work
      // even offline or with a flaky network.
      try {
        await _remoteDataSource.logout();
      } catch (error, stack) {
        log(
          'Backend logout failed, proceeding with local sign-out',
          error: error,
          stackTrace: stack,
        );
      }

      // Drop the device-side FCM token so Firebase rotates it on next sign-in.
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (error, stack) {
        log(
          'FirebaseMessaging.deleteToken failed during logout',
          error: error,
          stackTrace: stack,
        );
      }

      await _tokenStorage.clearToken();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      return unit;
    });
  }
}
