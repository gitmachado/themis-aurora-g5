import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/clients/data/datasources/lawyer_client_remote_data_source.dart';

import '../../../../helpers/fakes.dart';

void main() {
  test('uses authenticated lawyer clients route', () async {
    final client = {
      'id': 'client-1',
      'name': 'Joao Cliente',
      'whatsappNumber': '5511888888888',
      'cpf': '98765432100',
      'email': 'joao@cliente.com',
    };
    final apiClient = FakeApiClient()
      ..listResponses['GET /clients/my'] = [client]
      ..jsonResponses['GET /clients/client-1'] = client;
    final dataSource = LawyerClientRemoteDataSource(apiClient);

    final clients = await dataSource.getMyClients();
    final detail = await dataSource.getById('client-1');

    expect(clients.single.id, 'client-1');
    expect(clients.single.name, 'Joao Cliente');
    expect(clients.single.cpf, '98765432100');
    expect(detail.email, 'joao@cliente.com');
    expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
      'GET /clients/my',
      'GET /clients/client-1',
    ]);
  });
}
