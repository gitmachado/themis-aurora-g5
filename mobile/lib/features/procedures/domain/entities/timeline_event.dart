import 'package:equatable/equatable.dart';

class TimelineEvent extends Equatable {
  final String id;
  final String legalProcessId;
  final String type;
  final String content;
  final String? previousStatus;
  final DateTime? createdAt;

  const TimelineEvent({
    required this.id,
    required this.legalProcessId,
    required this.type,
    required this.content,
    this.previousStatus,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    legalProcessId,
    type,
    content,
    previousStatus,
    createdAt,
  ];
}
