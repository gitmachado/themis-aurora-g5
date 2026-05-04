import '../../domain/entities/app_notification.dart';

final class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    super.extraData,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? 'STATUS_CHANGED',
      title: json['title'] as String? ?? 'Notificacao',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      extraData: json['extraData'] as Map<String, dynamic>?,
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'isRead': isRead,
      'extraData': extraData,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
