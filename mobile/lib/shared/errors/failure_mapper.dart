import '../network/api_exception.dart';
import 'failures.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;

  if (error is ApiException) {
    return switch (error.type) {
      ApiExceptionType.auth => AuthFailure(
        error.message,
        statusCode: error.statusCode,
        cause: error,
      ),
      ApiExceptionType.network => NetworkFailure(error.message, cause: error),
      ApiExceptionType.server => ServerFailure(
        error.message,
        statusCode: error.statusCode,
        cause: error,
      ),
    };
  }

  return ServerFailure('Nao foi possivel concluir a operacao', cause: error);
}
