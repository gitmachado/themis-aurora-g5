import '../entities/legal_process.dart';
import '../entities/process_document.dart';
import '../entities/timeline_event.dart';

abstract interface class ProcedureRepository {
  Future<List<LegalProcess>> getMyProcesses();
  Future<LegalProcess> getProcessById(String id);
  Future<List<TimelineEvent>> getTimeline(String processId);
  Future<List<ProcessDocument>> getDocuments(String processId);
  Future<List<ProcessDocument>> getMyDocuments();
  Future<ProcessDocument> getDocumentById(String id);
  Future<ProcessDocument> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
  });
  Future<void> deleteDocument(String id);
  Future<LegalProcess> updateStatus({
    required String processId,
    required String status,
    String? reason,
  });
}
