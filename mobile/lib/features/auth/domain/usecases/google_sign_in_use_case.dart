import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class GoogleSignInUseCase {
  final AuthRepository _repository;

  const GoogleSignInUseCase(this._repository);

  Future<Either<Failure, AuthSession>> call() {
    return _repository.signInWithGoogle();
  }
}
