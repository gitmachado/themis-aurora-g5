import '../../../shared/utils/api_formatters.dart';
import '../domain/entities/app_notification.dart';

extension AppNotificationDisplay on AppNotification {
  String get timeLabel => formatRelativeDate(createdAt);

  String get tileType => switch (type) {
    'NEW_LEAD' => 'lead',
    'DOCUMENT_SENT' => 'file',
    'HUMAN_SUPPORT' => 'chat',
    'STATUS_CHANGED' => 'procedure',
    _ => 'alert',
  };
}
