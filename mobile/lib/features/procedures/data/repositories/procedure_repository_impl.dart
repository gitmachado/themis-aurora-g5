import '../../domain/entities/legal_process.dart';
import '../../domain/entities/process_document.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repositories/procedure_repository.dart';
import '../datasources/procedure_remote_data_source.dart';

final class ProcedureRepositoryImpl implements ProcedureRepository {
  final ProcedureRemoteDataSource _remoteDataSource;

  const ProcedureRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LegalProcess>> getMyProcesses() =>
      _remoteDataSource.getMyProcesses();

  @override
  Future<LegalProcess> getProcessById(String id) =>
      _remoteDataSource.getProcessById(id);

  @override
  Future<List<TimelineEvent>> getTimeline(String processId) {
    return _remoteDataSource.getTimeline(processId);
  }

  @override
  Future<List<ProcessDocument>> getDocuments(String processId) {
    return _remoteDataSource.getDocuments(processId);
  }

  @override
  Future<List<ProcessDocument>> getMyDocuments() {
    return _remoteDataSource.getMyDocuments();
  }

  @override
  Future<ProcessDocument> getDocumentById(String id) {
    return _remoteDataSource.getDocumentById(id);
  }

  @override
  Future<ProcessDocument> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
  }) {
    return _remoteDataSource.uploadDocument(
      processId: processId,
      filePath: filePath,
      fileName: fileName,
    );
  }

  @override
  Future<void> deleteDocument(String id) {
    return _remoteDataSource.deleteDocument(id);
  }

  @override
  Future<LegalProcess> updateStatus({
    required String processId,
    required String status,
    String? reason,
  }) {
    return _remoteDataSource.updateStatus(
      processId: processId,
      status: status,
      reason: reason,
    );
  }
}
