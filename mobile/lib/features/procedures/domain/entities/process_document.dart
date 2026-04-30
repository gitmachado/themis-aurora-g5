import 'package:equatable/equatable.dart';

class ProcessDocument extends Equatable {
  final String id;
  final String legalProcessId;
  final String fileName;
  final String fileUrl;
  final int? sizeBytes;
  final String? mimeType;
  final String sentById;
  final DateTime? createdAt;

  const ProcessDocument({
    required this.id,
    required this.legalProcessId,
    required this.fileName,
    required this.fileUrl,
    required this.sentById,
    this.sizeBytes,
    this.mimeType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    legalProcessId,
    fileName,
    fileUrl,
    sizeBytes,
    mimeType,
    sentById,
    createdAt,
  ];
}
