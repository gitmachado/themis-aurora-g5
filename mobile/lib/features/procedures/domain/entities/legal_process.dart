import 'package:equatable/equatable.dart';

class LegalProcess extends Equatable {
  final String id;
  final String clientId;
  final String? lawyerId;
  final String title;
  final String? description;
  final String currentStatus;
  final String? processNumber;
  final String? caseType;
  final String? lastNote;
  final DateTime? lastMovementDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LegalProcess({
    required this.id,
    required this.clientId,
    required this.title,
    required this.currentStatus,
    this.lawyerId,
    this.description,
    this.processNumber,
    this.caseType,
    this.lastNote,
    this.lastMovementDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    clientId,
    lawyerId,
    title,
    description,
    currentStatus,
    processNumber,
    caseType,
    lastNote,
    lastMovementDate,
    createdAt,
    updatedAt,
  ];
}
