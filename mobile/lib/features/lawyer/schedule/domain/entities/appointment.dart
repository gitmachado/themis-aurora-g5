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
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    required this.createdAt,
    this.updatedAt,
  });

  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isDeadline => type == 'DEADLINE';
  bool get isMeeting => type == 'MEETING';
  bool get isHearing => type == 'HEARING';

  bool get isCompleted => status == 'COMPLETED';
  bool get isCanceled => status == 'CANCELED';
  bool get isScheduled => status == 'SCHEDULED';

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
    createdAt,
    updatedAt,
  ];
}
