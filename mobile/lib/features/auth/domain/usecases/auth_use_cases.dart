import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/account.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}

final class RestoreSessionUseCase {
  final AuthRepository _repository;

  const RestoreSessionUseCase(this._repository);

  Future<Either<Failure, AuthSession?>> call() {
    return _repository.restoreSession();
  }
}

final class GetCurrentAccountUseCase {
  final AuthRepository _repository;

  const GetCurrentAccountUseCase(this._repository);

  Future<Either<Failure, Account>> call() {
    return _repository.getAccount();
  }
}

final class UpdateNotificationPreferencesUseCase {
  final AuthRepository _repository;

  const UpdateNotificationPreferencesUseCase(this._repository);

  Future<Either<Failure, Account>> call(Map<String, bool> preferences) {
    return _repository.updateNotificationPreferences(preferences);
  }
}

final class UploadAvatarUseCase {
  final AuthRepository _repository;

  const UploadAvatarUseCase(this._repository);

  Future<Either<Failure, Account>> call({
    required String filePath,
    required String fileName,
  }) {
    return _repository.uploadAvatar(filePath: filePath, fileName: fileName);
  }
}

final class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
