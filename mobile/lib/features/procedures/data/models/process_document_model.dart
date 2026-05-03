import '../../domain/entities/process_document.dart';

final class ProcessDocumentModel extends ProcessDocument {
  const ProcessDocumentModel({
    required super.id,
    required super.legalProcessId,
    required super.fileName,
    required super.fileUrl,
    required super.sentById,
    super.sizeBytes,
    super.mimeType,
    super.createdAt,
  });

  factory ProcessDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProcessDocumentModel(
      id: json['id'] as String,
      legalProcessId: json['legalProcessId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'documento',
      fileUrl: json['fileUrl'] as String? ?? '',
      sizeBytes: _int(json['sizeBytes']),
      mimeType: json['mimeType'] as String?,
      sentById: json['sentById'] as String? ?? '',
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legalProcessId': legalProcessId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'sentById': sentById,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int? _int(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
