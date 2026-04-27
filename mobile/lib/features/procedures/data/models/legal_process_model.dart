import '../../domain/entities/legal_process.dart';

final class LegalProcessModel extends LegalProcess {
  const LegalProcessModel({
    required super.id,
    required super.clientId,
    required super.title,
    required super.currentStatus,
    super.lawyerId,
    super.description,
    super.processNumber,
    super.caseType,
    super.lastNote,
    super.lastMovementDate,
    super.createdAt,
    super.updatedAt,
  });

  factory LegalProcessModel.fromJson(Map<String, dynamic> json) {
    return LegalProcessModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String? ?? '',
      lawyerId: json['lawyerId'] as String?,
      title: json['title'] as String? ?? 'Tramite',
      description: json['description'] as String?,
      currentStatus: json['currentStatus'] as String? ?? 'OPEN',
      processNumber: json['processNumber'] as String?,
      caseType: json['caseType'] as String?,
      lastNote: json['lastNote'] as String?,
      lastMovementDate: _date(json['lastMovementDate']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
