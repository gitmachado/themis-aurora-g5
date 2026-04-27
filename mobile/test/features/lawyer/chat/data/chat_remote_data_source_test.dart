import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/chat/data/datasources/chat_remote_data_source.dart';

import '../../../../helpers/fakes.dart';

void main() {
  test('uses read-only mirrored WhatsApp history route', () async {
    final apiClient = FakeApiClient()
      ..listResponses['GET /messages/5511999999999'] = [
        {
          'id': 'message-1',
          'userId': 'client-1',
          'sender': 'CLIENT',
          'content': 'Ola',
          'whatsappMessageId': 'wamid.1',
          'createdAt': '2026-04-24T12:00:00.000Z',
        },
      ];
    final dataSource = ChatRemoteDataSource(apiClient);

    final messages = await dataSource.getHistoryByWhatsapp('5511999999999');

    expect(messages.single.sender, 'CLIENT');
    expect(messages.single.content, 'Ola');
    expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
      'GET /messages/5511999999999',
    ]);
  });
}
