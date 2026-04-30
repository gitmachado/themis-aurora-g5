import 'package:equatable/equatable.dart';

class Lead extends Equatable {
  final String id;
  final String whatsappNumber;
  final String? name;
  final String? cpf;
  final String? caseType;
  final String? caseDescription;
  final String? urgency;
  final String? contactAvailability;
  final String status;
  final DateTime? createdAt;

  const Lead({
    required this.id,
    required this.whatsappNumber,
    required this.status,
    this.name,
    this.cpf,
    this.caseType,
    this.caseDescription,
    this.urgency,
    this.contactAvailability,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    whatsappNumber,
    name,
    cpf,
    caseType,
    caseDescription,
    urgency,
    contactAvailability,
    status,
    createdAt,
  ];
}
