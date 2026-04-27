import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/network/api_client.dart';
import '../../data/datasources/procedure_remote_data_source.dart';
import '../../data/repositories/procedure_repository_impl.dart';
import '../../domain/entities/legal_process.dart';
import '../../domain/entities/process_document.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repositories/procedure_repository.dart';

final procedureRemoteDataSourceProvider = Provider<ProcedureRemoteDataSource>((
  ref,
) {
  return ProcedureRemoteDataSource(ref.watch(apiClientProvider));
});

final procedureRepositoryProvider = Provider<ProcedureRepository>((ref) {
  return ProcedureRepositoryImpl(ref.watch(procedureRemoteDataSourceProvider));
});

final myProceduresProvider = FutureProvider<List<LegalProcess>>((ref) {
  return ref.watch(procedureRepositoryProvider).getMyProcesses();
});

final procedureDetailsProvider = FutureProvider.family<LegalProcess, String>((
  ref,
  processId,
) {
  return ref.watch(procedureRepositoryProvider).getProcessById(processId);
});

final procedureTimelineProvider =
    FutureProvider.family<List<TimelineEvent>, String>((ref, processId) {
      return ref.watch(procedureRepositoryProvider).getTimeline(processId);
    });

final procedureDocumentsProvider =
    FutureProvider.family<List<ProcessDocument>, String>((ref, processId) {
      return ref.watch(procedureRepositoryProvider).getDocuments(processId);
    });

final myDocumentsProvider = FutureProvider<List<ProcessDocument>>((ref) {
  return ref.watch(procedureRepositoryProvider).getMyDocuments();
});

final documentDetailsProvider = FutureProvider.family<ProcessDocument, String>((
  ref,
  documentId,
) {
  return ref.watch(procedureRepositoryProvider).getDocumentById(documentId);
});

final myRecentDocumentsProvider = FutureProvider<List<ProcessDocument>>((
  ref,
) async {
  final documents = await ref
      .watch(procedureRepositoryProvider)
      .getMyDocuments();
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
    await _ref
        .read(procedureRepositoryProvider)
        .updateStatus(processId: processId, status: status, reason: reason);
    _ref.invalidate(myProceduresProvider);
    _ref.invalidate(procedureDetailsProvider(processId));
    _ref.invalidate(procedureTimelineProvider(processId));
  }

  Future<void> deleteDocument({
    required String processId,
    required String documentId,
  }) async {
    await _ref.read(procedureRepositoryProvider).deleteDocument(documentId);
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
    await _ref
        .read(procedureRepositoryProvider)
        .uploadDocument(
          processId: processId,
          filePath: filePath,
          fileName: fileName,
        );
    _ref.invalidate(procedureDocumentsProvider(processId));
    _ref.invalidate(myDocumentsProvider);
    _ref.invalidate(myRecentDocumentsProvider);
  }
}
