import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/account.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/network/api_exception.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('login sends email, saves token, and loads account', () async {
    final apiClient = FakeApiClient()
      ..jsonResponses['POST /auth/login'] = {
        'token': 'jwt-token',
        'userId': 'login-user-id',
        'role': 'CLIENT',
      }
      ..jsonResponses['GET /account'] = {
        'id': 'account-user-id',
        'name': 'Lucas Silva',
        'whatsappNumber': '11999999999',
        'cpf': '12345678900',
        'email': 'lucas@example.com',
        'role': 'CLIENT',
        'notificationPreferences': {'documents': true},
      }
      ..jsonResponses['PATCH /account/notification-preferences'] = {
        'id': 'account-user-id',
        'name': 'Lucas Silva',
        'whatsappNumber': '11999999999',
        'cpf': '12345678900',
        'email': 'lucas@example.com',
        'role': 'CLIENT',
        'notificationPreferences': {'documents': false},
      };
    final tokenStorage = FakeTokenStorage();
    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(apiClient),
      tokenStorage: tokenStorage,
    );

    final session = (await repository.login(
      email: 'lucas@example.com',
      password: 'secret123',
    )).getOrElse((failure) => throw failure);
    final updated = (await repository.updateNotificationPreferences({
      'documents': false,
    })).getOrElse((failure) => throw failure);
    final restored = (await repository.restoreSession()).getOrElse(
      (failure) => throw failure,
    );
    expect(tokenStorage.token, 'jwt-token');
    await repository.logout();

    expect(apiClient.calls.first.method, 'POST');
    expect(apiClient.calls.first.path, '/auth/login');
    expect(apiClient.calls.first.data, {
      'email': 'lucas@example.com',
      'password': 'secret123',
    });
    expect(apiClient.calls.last.path, '/account');
    expect(session.userId, 'account-user-id');
    expect(session.role, UserRole.client);
    expect(session.account?.cpf, '12345678900');
    expect(session.account?.notificationPreferences['documents'], isTrue);
    expect(updated.notificationPreferences['documents'], isFalse);
    expect(restored?.account?.id, 'account-user-id');
    expect(tokenStorage.token, isNull);
    expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
      'POST /auth/login',
      'GET /account',
      'PATCH /account/notification-preferences',
      'GET /account',
    ]);
    expect(apiClient.calls[2].data, {
      'notificationPreferences': {'documents': false},
    });
  });

  test('login returns AuthFailure when remote login is unauthorized', () async {
    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(
        _ThrowingLoginApiClient(
          const ApiException(
            'Credenciais invalidas',
            statusCode: 401,
            type: ApiExceptionType.auth,
          ),
        ),
      ),
      tokenStorage: FakeTokenStorage(),
    );

    final result = await repository.login(
      email: 'lucas@example.com',
      password: 'wrong',
    );

    result.match((failure) {
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Credenciais invalidas');
    }, (_) => fail('Expected login to return a failure'));
  });
}

final class _ThrowingLoginApiClient extends FakeApiClient {
  final ApiException exception;

  _ThrowingLoginApiClient(this.exception);

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    throw exception;
  }
}
