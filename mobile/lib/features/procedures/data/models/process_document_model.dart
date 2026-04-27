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
      sizeBytes: json['sizeBytes'] as int?,
      mimeType: json['mimeType'] as String?,
      sentById: json['sentById'] as String? ?? '',
      createdAt: _date(json['createdAt']),
    );
  }
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
