import '../../domain/entities/appointment.dart';

DateTime? _dateTime(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

final class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.title,
    super.description,
    required super.type,
    required super.status,
    required super.scheduledAt,
    required super.durationMinutes,
    super.clientId,
    super.processId,
    required super.reminded,
    required super.createdAt,
    super.updatedAt,
    super.createdByAI,
    super.aiOriginalData,
    super.clientName,
    super.clientWhatsappNumber,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'OTHER',
      status: json['status'] as String? ?? 'SCHEDULED',
      scheduledAt: _dateTime(json['scheduledAt'])?.toLocal() ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      clientId: json['clientId'] as String?,
      processId: json['processId'] as String?,
      reminded: json['reminded'] as bool? ?? false,
      createdAt: _dateTime(json['createdAt'])?.toLocal() ?? DateTime.now(),
      updatedAt: _dateTime(json['updatedAt'])?.toLocal(),
      createdByAI: json['created_by_ai'] as bool? ?? false,
      aiOriginalData: json['ai_original_data'] as Map<String, dynamic>?,
      clientName: json['clientName'] as String?,
      clientWhatsappNumber: json['clientWhatsappNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'status': status,
    'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    'durationMinutes': durationMinutes,
    'clientId': clientId,
    'processId': processId,
    'reminded': reminded,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'created_by_ai': createdByAI,
    'ai_original_data': aiOriginalData,
    'clientName': clientName,
    'clientWhatsappNumber': clientWhatsappNumber,
  };
}
