import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? clientId;
  final String? processId;
  final bool reminded;
  final bool createdByAI;
  final Map<String, dynamic>? aiOriginalData;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? clientName;
  final String? clientWhatsappNumber;

  const Appointment({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    this.clientId,
    this.processId,
    required this.reminded,
    this.createdByAI = false,
    this.aiOriginalData,
    required this.createdAt,
    this.updatedAt,
    this.clientName,
    this.clientWhatsappNumber,
  });

  factory Appointment.fromModel(dynamic model) {
    if (model is Appointment) return model;
    return Appointment(
      id: model.id as String,
      title: model.title as String,
      description: model.description as String?,
      type: model.type as String,
      status: model.status as String,
      scheduledAt: model.scheduledAt as DateTime,
      durationMinutes: model.durationMinutes as int,
      clientId: model.clientId as String?,
      processId: model.processId as String?,
      reminded: model.reminded as bool,
      createdByAI: model.createdByAI as bool? ?? false,
      aiOriginalData: model.aiOriginalData as Map<String, dynamic>?,
      createdAt: model.createdAt as DateTime,
      updatedAt: model.updatedAt as DateTime?,
      clientName: model.clientName as String?,
      clientWhatsappNumber: model.clientWhatsappNumber as String?,
    );
  }

  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isDeadline => type == 'DEADLINE';
  bool get isMeeting => type == 'MEETING';
  bool get isHearing => type == 'HEARING';

  bool get isCompleted => status == 'COMPLETED';
  bool get isCanceled => status == 'CANCELED';
  bool get isScheduled => status == 'SCHEDULED';
  bool get isPendingApproval => status == 'PENDING_APPROVAL';

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());

  Duration? get timeUntilStart {
    final now = DateTime.now();
    if (scheduledAt.isAfter(now)) {
      return scheduledAt.difference(now);
    }
    return null;
  }

  String get typeLabel => switch (type) {
    'DEADLINE' => 'Prazo',
    'MEETING' => 'Reunião',
    'HEARING' => 'Audiência',
    _ => 'Outro',
  };

  String get statusLabel => switch (status) {
    'SCHEDULED' => 'Agendado',
    'COMPLETED' => 'Concluído',
    'CANCELED' => 'Cancelado',
    'PENDING_APPROVAL' => 'Pendente de Aprovação',
    _ => 'Desconhecido',
  };

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    status,
    scheduledAt,
    durationMinutes,
    clientId,
    processId,
    reminded,
    createdByAI,
    aiOriginalData,
    createdAt,
    updatedAt,
    clientName,
    clientWhatsappNumber,
  ];
}
