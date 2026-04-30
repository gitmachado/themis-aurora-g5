sealed class Failure implements Exception {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode, super.cause});
}

final class AuthFailure extends Failure {
  final int? statusCode;

  const AuthFailure(super.message, {this.statusCode, super.cause});
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}
