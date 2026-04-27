import '../../domain/entities/lead.dart';

final class LeadModel extends Lead {
  const LeadModel({
    required super.id,
    required super.whatsappNumber,
    required super.status,
    super.name,
    super.cpf,
    super.caseType,
    super.caseDescription,
    super.urgency,
    super.contactAvailability,
    super.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String,
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      caseType: json['caseType'] as String?,
      caseDescription: json['caseDescription'] as String?,
      urgency: json['urgency'] as String?,
      contactAvailability: json['contactAvailability'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: _date(json['createdAt']),
    );
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
