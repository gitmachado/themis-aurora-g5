import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/errors/failure_mapper.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/network/api_exception.dart';

void main() {
  test('maps auth ApiException to AuthFailure', () {
    final failure = mapExceptionToFailure(
      const ApiException(
        'Sessao expirada',
        statusCode: 401,
        type: ApiExceptionType.auth,
      ),
    );

    expect(failure, isA<AuthFailure>());
    expect((failure as AuthFailure).statusCode, 401);
    expect(failure.message, 'Sessao expirada');
  });

  test('maps network ApiException to NetworkFailure', () {
    final failure = mapExceptionToFailure(
      const ApiException('Sem conexao', type: ApiExceptionType.network),
    );

    expect(failure, isA<NetworkFailure>());
    expect(failure.message, 'Sem conexao');
  });

  test('maps server ApiException to ServerFailure', () {
    final failure = mapExceptionToFailure(
      const ApiException('Erro interno', statusCode: 500),
    );

    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 500);
    expect(failure.message, 'Erro interno');
  });
}
