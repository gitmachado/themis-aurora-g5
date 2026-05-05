import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/legal_process.dart';
import '../entities/process_document.dart';
import '../entities/timeline_event.dart';

abstract interface class ProcedureRepository {
  Future<Either<Failure, List<LegalProcess>>> getMyProcesses();
  Future<Either<Failure, LegalProcess>> getProcessById(String id);
  Future<Either<Failure, List<TimelineEvent>>> getTimeline(String processId);
  Future<Either<Failure, List<ProcessDocument>>> getDocuments(String processId);
  Future<Either<Failure, List<ProcessDocument>>> getMyDocuments();
  Future<Either<Failure, ProcessDocument>> getDocumentById(String id);
  Future<Either<Failure, ProcessDocument>> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
    void Function(int count, int total)? onSendProgress,
  });
  Future<Either<Failure, Unit>> deleteDocument(String id);
  Future<Either<Failure, LegalProcess>> updateStatus({
    required String processId,
    required String status,
    String? reason,
  });
  Future<Either<Failure, Unit>> addNote({
    required String processId,
    required String note,
  });
  Future<Either<Failure, Unit>> requestDocument({
    required String processId,
    required String documentName,
  });
  Future<Either<Failure, Unit>> scheduleEvent({
    required String processId,
    required String title,
    required DateTime date,
  });
}
