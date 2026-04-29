import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/legal_process.dart';
import '../../domain/entities/process_document.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repositories/procedure_repository.dart';
import '../datasources/procedure_remote_data_source.dart';

final class ProcedureRepositoryImpl implements ProcedureRepository {
  final ProcedureRemoteDataSource _remoteDataSource;

  const ProcedureRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<LegalProcess>>> getMyProcesses() {
    return guardRepository(_remoteDataSource.getMyProcesses);
  }

  @override
  Future<Either<Failure, LegalProcess>> getProcessById(String id) {
    return guardRepository(() => _remoteDataSource.getProcessById(id));
  }

  @override
  Future<Either<Failure, List<TimelineEvent>>> getTimeline(String processId) {
    return guardRepository(() => _remoteDataSource.getTimeline(processId));
  }

  @override
  Future<Either<Failure, List<ProcessDocument>>> getDocuments(
    String processId,
  ) {
    return guardRepository(() => _remoteDataSource.getDocuments(processId));
  }

  @override
  Future<Either<Failure, List<ProcessDocument>>> getMyDocuments() {
    return guardRepository(_remoteDataSource.getMyDocuments);
  }

  @override
  Future<Either<Failure, ProcessDocument>> getDocumentById(String id) {
    return guardRepository(() => _remoteDataSource.getDocumentById(id));
  }

  @override
  Future<Either<Failure, ProcessDocument>> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
  }) {
    return guardRepository(
      () => _remoteDataSource.uploadDocument(
        processId: processId,
        filePath: filePath,
        fileName: fileName,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteDocument(String id) {
    return guardRepositoryUnit(() => _remoteDataSource.deleteDocument(id));
  }

  @override
  Future<Either<Failure, LegalProcess>> updateStatus({
    required String processId,
    required String status,
    String? reason,
  }) {
    return guardRepository(
      () => _remoteDataSource.updateStatus(
        processId: processId,
        status: status,
        reason: reason,
      ),
    );
  }
}
