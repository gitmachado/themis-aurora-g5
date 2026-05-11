import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/legal_process.dart';
import '../entities/process_document.dart';
import '../entities/timeline_event.dart';
import '../repositories/procedure_repository.dart';

final class GetMyProceduresUseCase {
  final ProcedureRepository _repository;

  const GetMyProceduresUseCase(this._repository);

  Future<Either<Failure, List<LegalProcess>>> call() {
    return _repository.getMyProcesses();
  }
}

final class GetProcedureByIdUseCase {
  final ProcedureRepository _repository;

  const GetProcedureByIdUseCase(this._repository);

  Future<Either<Failure, LegalProcess>> call(String id) {
    return _repository.getProcessById(id);
  }
}

final class GetProcedureTimelineUseCase {
  final ProcedureRepository _repository;

  const GetProcedureTimelineUseCase(this._repository);

  Future<Either<Failure, List<TimelineEvent>>> call(String processId) {
    return _repository.getTimeline(processId);
  }
}

final class GetProcedureDocumentsUseCase {
  final ProcedureRepository _repository;

  const GetProcedureDocumentsUseCase(this._repository);

  Future<Either<Failure, List<ProcessDocument>>> call(String processId) {
    return _repository.getDocuments(processId);
  }
}

final class GetMyDocumentsUseCase {
  final ProcedureRepository _repository;

  const GetMyDocumentsUseCase(this._repository);

  Future<Either<Failure, List<ProcessDocument>>> call() {
    return _repository.getMyDocuments();
  }
}

final class GetDocumentByIdUseCase {
  final ProcedureRepository _repository;

  const GetDocumentByIdUseCase(this._repository);

  Future<Either<Failure, ProcessDocument>> call(String id) {
    return _repository.getDocumentById(id);
  }
}

final class UploadDocumentUseCase {
  final ProcedureRepository _repository;

  const UploadDocumentUseCase(this._repository);

  Future<Either<Failure, ProcessDocument>> call({
    required String processId,
    required String filePath,
    required String fileName,
    void Function(int count, int total)? onSendProgress,
  }) {
    return _repository.uploadDocument(
      processId: processId,
      filePath: filePath,
      fileName: fileName,
      onSendProgress: onSendProgress,
    );
  }
}

final class DeleteDocumentUseCase {
  final ProcedureRepository _repository;

  const DeleteDocumentUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteDocument(id);
  }
}

final class UpdateProcedureStatusUseCase {
  final ProcedureRepository _repository;

  const UpdateProcedureStatusUseCase(this._repository);

  Future<Either<Failure, LegalProcess>> call({
    required String processId,
    required String status,
    String? reason,
  }) {
    return _repository.updateStatus(
      processId: processId,
      status: status,
      reason: reason,
    );
  }
}

final class AddNoteUseCase {
  final ProcedureRepository _repository;

  const AddNoteUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String processId,
    required String note,
  }) {
    return _repository.addNote(processId: processId, note: note);
  }
}

final class RequestDocumentUseCase {
  final ProcedureRepository _repository;

  const RequestDocumentUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String processId,
    required String documentName,
  }) {
    return _repository.requestDocument(
      processId: processId,
      documentName: documentName,
    );
  }
}

final class ScheduleEventUseCase {
  final ProcedureRepository _repository;

  const ScheduleEventUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String processId,
    required String title,
    required DateTime date,
  }) {
    return _repository.scheduleEvent(
      processId: processId,
      title: title,
      date: date,
    );
  }
}

final class CreateProcedureUseCase {
  final ProcedureRepository _repository;

  const CreateProcedureUseCase(this._repository);

  Future<Either<Failure, LegalProcess>> call({
    required String clientId,
    required String title,
    required String caseType,
    String? description,
    String? processNumber,
  }) {
    return _repository.createProcess(
      clientId: clientId,
      title: title,
      caseType: caseType,
      description: description,
      processNumber: processNumber,
    );
  }
}
