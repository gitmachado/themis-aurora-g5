import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/auth_session.dart';
import '../entities/account.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> signInWithGoogle();

  Future<Either<Failure, AuthSession?>> restoreSession();

  Future<Either<Failure, Account>> getAccount();

  Future<Either<Failure, Account>> updateNotificationPreferences(
    Map<String, bool> notificationPreferences,
  );

  Future<Either<Failure, Account>> uploadAvatar({
    required String filePath,
    required String fileName,
  });

  Future<Either<Failure, Account>> changePassword({
    required String newPassword,
    String? currentPassword,
  });

  Future<Either<Failure, Unit>> logout();
}
