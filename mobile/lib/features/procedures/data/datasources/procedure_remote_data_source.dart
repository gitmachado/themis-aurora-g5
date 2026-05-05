import '../../../../shared/network/api_client.dart';
import '../models/legal_process_model.dart';
import '../models/process_document_model.dart';
import '../models/timeline_event_model.dart';

final class ProcedureRemoteDataSource {
  final ApiClient _apiClient;

  const ProcedureRemoteDataSource(this._apiClient);

  Future<List<LegalProcessModel>> getMyProcesses() async {
    final list = await _apiClient.getList('/processes/my');
    return list
        .map(
          (json) => LegalProcessModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<LegalProcessModel> getProcessById(String id) async {
    final json = await _apiClient.getJson('/processes/$id');
    return LegalProcessModel.fromJson(json);
  }

  Future<List<TimelineEventModel>> getTimeline(String processId) async {
    final list = await _apiClient.getList('/timeline/process/$processId');
    return list
        .map(
          (json) => TimelineEventModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<List<ProcessDocumentModel>> getDocuments(String processId) async {
    final list = await _apiClient.getList('/documents/process/$processId');
    return list
        .map(
          (json) => ProcessDocumentModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<List<ProcessDocumentModel>> getMyDocuments() async {
    final list = await _apiClient.getList('/documents/my');
    return list
        .map(
          (json) => ProcessDocumentModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<ProcessDocumentModel> getDocumentById(String id) async {
    final json = await _apiClient.getJson('/documents/$id');
    return ProcessDocumentModel.fromJson(json);
  }

  Future<ProcessDocumentModel> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
    void Function(int count, int total)? onSendProgress,
  }) async {
    final json = await _apiClient.postMultipart(
      '/documents/upload',
      fileField: 'file',
      filePath: filePath,
      fileName: fileName,
      fields: {'legalProcessId': processId},
      onSendProgress: onSendProgress,
    );
    return ProcessDocumentModel.fromJson(json);
  }

  Future<void> deleteDocument(String id) async {
    await _apiClient.deleteVoid('/documents/$id');
  }

  Future<LegalProcessModel> updateStatus({
    required String processId,
    required String status,
    String? reason,
  }) async {
    final json = await _apiClient.patchJson(
      '/processes/$processId/status',
      data: {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return LegalProcessModel.fromJson(json);
  }

  Future<void> addNote({
    required String processId,
    required String note,
  }) async {
    await _apiClient.postVoid(
      '/processes/$processId/note',
      data: {'note': note},
    );
  }

  Future<void> requestDocument({
    required String processId,
    required String documentName,
  }) async {
    await _apiClient.postVoid(
      '/processes/$processId/request-document',
      data: {'documentName': documentName},
    );
  }

  Future<void> scheduleEvent({
    required String processId,
    required String title,
    required DateTime date,
  }) async {
    await _apiClient.postVoid(
      '/processes/$processId/schedule-event',
      data: {
        'title': title,
        'date': date.toIso8601String(),
      },
    );
  }
}
