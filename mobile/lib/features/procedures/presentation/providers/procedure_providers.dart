import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

import '../../../../shared/network/api_client.dart';
import '../../data/datasources/procedure_remote_data_source.dart';
import '../../data/repositories/procedure_repository_impl.dart';
import '../../domain/entities/legal_process.dart';
import '../../domain/entities/process_document.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repositories/procedure_repository.dart';
import '../../domain/usecases/procedure_use_cases.dart';

final procedureRemoteDataSourceProvider = Provider<ProcedureRemoteDataSource>((
  ref,
) {
  return ProcedureRemoteDataSource(ref.watch(apiClientProvider));
});

final procedureRepositoryProvider = Provider<ProcedureRepository>((ref) {
  return ProcedureRepositoryImpl(ref.watch(procedureRemoteDataSourceProvider));
});

final getMyProceduresUseCaseProvider = Provider<GetMyProceduresUseCase>((ref) {
  return GetMyProceduresUseCase(ref.watch(procedureRepositoryProvider));
});

final getProcedureByIdUseCaseProvider = Provider<GetProcedureByIdUseCase>((
  ref,
) {
  return GetProcedureByIdUseCase(ref.watch(procedureRepositoryProvider));
});

final getProcedureTimelineUseCaseProvider =
    Provider<GetProcedureTimelineUseCase>((ref) {
      return GetProcedureTimelineUseCase(
        ref.watch(procedureRepositoryProvider),
      );
    });

final getProcedureDocumentsUseCaseProvider =
    Provider<GetProcedureDocumentsUseCase>((ref) {
      return GetProcedureDocumentsUseCase(
        ref.watch(procedureRepositoryProvider),
      );
    });

final getMyDocumentsUseCaseProvider = Provider<GetMyDocumentsUseCase>((ref) {
  return GetMyDocumentsUseCase(ref.watch(procedureRepositoryProvider));
});

final getDocumentByIdUseCaseProvider = Provider<GetDocumentByIdUseCase>((ref) {
  return GetDocumentByIdUseCase(ref.watch(procedureRepositoryProvider));
});

final uploadDocumentUseCaseProvider = Provider<UploadDocumentUseCase>((ref) {
  return UploadDocumentUseCase(ref.watch(procedureRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  return DeleteDocumentUseCase(ref.watch(procedureRepositoryProvider));
});

final updateProcedureStatusUseCaseProvider =
    Provider<UpdateProcedureStatusUseCase>((ref) {
      return UpdateProcedureStatusUseCase(
        ref.watch(procedureRepositoryProvider),
      );
    });

final myProceduresProvider = FutureProvider<List<LegalProcess>>((ref) async {
  return (await ref.watch(getMyProceduresUseCaseProvider)()).getOrThrow();
});

final procedureDetailsProvider = FutureProvider.family<LegalProcess, String>((
  ref,
  processId,
) async {
  return (await ref.watch(getProcedureByIdUseCaseProvider)(
    processId,
  )).getOrThrow();
});

final procedureTimelineProvider =
    FutureProvider.family<List<TimelineEvent>, String>((ref, processId) async {
      return (await ref.watch(getProcedureTimelineUseCaseProvider)(
        processId,
      )).getOrThrow();
    });

final procedureDocumentsProvider =
    FutureProvider.family<List<ProcessDocument>, String>((
      ref,
      processId,
    ) async {
      return (await ref.watch(getProcedureDocumentsUseCaseProvider)(
        processId,
      )).getOrThrow();
    });

final myDocumentsProvider = FutureProvider<List<ProcessDocument>>((ref) async {
  return (await ref.watch(getMyDocumentsUseCaseProvider)()).getOrThrow();
});

final documentDetailsProvider = FutureProvider.family<ProcessDocument, String>((
  ref,
  documentId,
) async {
  return (await ref.watch(getDocumentByIdUseCaseProvider)(
    documentId,
  )).getOrThrow();
});

final myRecentDocumentsProvider = FutureProvider<List<ProcessDocument>>((
  ref,
) async {
  final documents = (await ref.watch(
    getMyDocumentsUseCaseProvider,
  )()).getOrThrow();
  documents.sort((a, b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });

  return documents.take(5).toList();
});

final procedureActionsProvider = Provider<ProcedureActions>((ref) {
  return ProcedureActions(ref);
});

final class ProcedureActions {
  final Ref _ref;

  const ProcedureActions(this._ref);

  Future<void> updateStatus({
    required String processId,
    required String status,
    String? reason,
  }) async {
    (await _ref
            .read(updateProcedureStatusUseCaseProvider)
            .call(processId: processId, status: status, reason: reason))
        .getOrThrow();
    _ref.invalidate(myProceduresProvider);
    _ref.invalidate(procedureDetailsProvider(processId));
    _ref.invalidate(procedureTimelineProvider(processId));
  }

  Future<void> deleteDocument({
    required String processId,
    required String documentId,
  }) async {
    (await _ref.read(deleteDocumentUseCaseProvider)(documentId)).getOrThrow();
    _ref.invalidate(procedureDocumentsProvider(processId));
    _ref.invalidate(documentDetailsProvider(documentId));
    _ref.invalidate(myDocumentsProvider);
    _ref.invalidate(myRecentDocumentsProvider);
  }

  Future<void> uploadDocument({
    required String processId,
    required String filePath,
    required String fileName,
  }) async {
    (await _ref
            .read(uploadDocumentUseCaseProvider)
            .call(processId: processId, filePath: filePath, fileName: fileName))
        .getOrThrow();
    _ref.invalidate(procedureDocumentsProvider(processId));
    _ref.invalidate(myDocumentsProvider);
    _ref.invalidate(myRecentDocumentsProvider);
  }
}
