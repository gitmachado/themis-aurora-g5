import '../../domain/entities/timeline_event.dart';

final class TimelineEventModel extends TimelineEvent {
  const TimelineEventModel({
    required super.id,
    required super.legalProcessId,
    required super.type,
    required super.content,
    super.previousStatus,
    super.createdAt,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      id: json['id'] as String,
      legalProcessId: json['legalProcessId'] as String? ?? '',
      type: json['type'] as String? ?? 'STATUS_UPDATE',
      content: json['content'] as String? ?? '',
      previousStatus: json['previousStatus'] as String?,
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legalProcessId': legalProcessId,
      'type': type,
      'content': content,
      'previousStatus': previousStatus,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
