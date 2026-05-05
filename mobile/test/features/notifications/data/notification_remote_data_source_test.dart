import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/datasources/notification_remote_data_source.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('uses notification inbox routes for list and read actions', () async {
    final apiClient = FakeApiClient()
      ..jsonResponses['PATCH /notifications/notification-1/read'] = {}
      ..listResponses['GET /notifications/my'] = [
        {
          'id': 'notification-1',
          'userId': 'user-1',
          'type': 'STATUS_CHANGED',
          'title': 'Atualizacao',
          'body': 'Seu tramite mudou',
          'isRead': false,
          'createdAt': '2026-04-24T12:00:00.000Z',
        },
      ];
    final dataSource = NotificationRemoteDataSource(apiClient);

    final notifications = await dataSource.getMyNotifications();
    await dataSource.markAsRead('notification-1');
    await dataSource.markAllAsRead();
    await dataSource.delete('notification-1');

    expect(notifications.single.id, 'notification-1');
    expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
      'GET /notifications/my',
      'PATCH /notifications/notification-1/read',
      'POST /notifications/read-all',
      'DELETE /notifications/notification-1',
    ]);
  });
}
