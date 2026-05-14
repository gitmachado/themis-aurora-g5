import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';
import '../../../../shared/network/websocket_client.dart';

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

final addNoteUseCaseProvider = Provider<AddNoteUseCase>((ref) {
  return AddNoteUseCase(ref.watch(procedureRepositoryProvider));
});

final requestDocumentUseCaseProvider = Provider<RequestDocumentUseCase>((ref) {
  return RequestDocumentUseCase(ref.watch(procedureRepositoryProvider));
});

final scheduleEventUseCaseProvider = Provider<ScheduleEventUseCase>((ref) {
  return ScheduleEventUseCase(ref.watch(procedureRepositoryProvider));
});

final createProcedureUseCaseProvider = Provider<CreateProcedureUseCase>((ref) {
  return CreateProcedureUseCase(ref.watch(procedureRepositoryProvider));
});

final myProceduresProvider =
    AsyncNotifierProvider<MyProceduresNotifier, List<LegalProcess>>(
      MyProceduresNotifier.new,
    );

class MyProceduresNotifier extends AsyncNotifier<List<LegalProcess>> {
  StreamSubscription? _subscription;

  @override
  Future<List<LegalProcess>> build() async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      if (event.type == 'procedure:updated' || event.type == 'connected') {
        // Recarrega a lista completa quando houver qualquer atualização ou reconexão
        refresh();
      }
    });
  }

  Future<List<LegalProcess>> _fetch() async {
    return (await ref.read(getMyProceduresUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    // Não usamos loading state aqui para evitar flickering na UI principal
    // Apenas atualizamos os dados silenciosamente
    final newData = await _fetch();
    state = AsyncData(newData);
  }
}

final procedureDetailsProvider =
    AsyncNotifierProvider.family<
      ProcedureDetailsNotifier,
      LegalProcess,
      String
    >(ProcedureDetailsNotifier.new);

class ProcedureDetailsNotifier
    extends FamilyAsyncNotifier<LegalProcess, String> {
  StreamSubscription? _subscription;

  @override
  Future<LegalProcess> build(String arg) async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      if ((event.type == 'procedure:updated' && event.data['id'] == arg) ||
          event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<LegalProcess> _fetch() async {
    return (await ref.read(getProcedureByIdUseCaseProvider)(arg)).getOrThrow();
  }

  Future<void> refresh() async {
    final newData = await _fetch();
    state = AsyncData(newData);
  }
}

final procedureTimelineProvider =
    AsyncNotifierProvider.family<
      ProcedureTimelineNotifier,
      List<TimelineEvent>,
      String
    >(ProcedureTimelineNotifier.new);

class ProcedureTimelineNotifier
    extends FamilyAsyncNotifier<List<TimelineEvent>, String> {
  StreamSubscription? _subscription;

  @override
  Future<List<TimelineEvent>> build(String arg) async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      final processId = arg;
      // Se o evento for de atualização de processo e o ID bater, ou se reconectar
      if ((event.type == 'procedure:updated' &&
              event.data['id'] == processId) ||
          event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<TimelineEvent>> _fetch() async {
    return (await ref.read(getProcedureTimelineUseCaseProvider)(
      arg,
    )).getOrThrow();
  }

  Future<void> refresh() async {
    final newData = await _fetch();
    state = AsyncData(newData);
  }
}

final procedureDocumentsProvider =
    AsyncNotifierProvider.family<
      ProcedureDocumentsNotifier,
      List<ProcessDocument>,
      String
    >(ProcedureDocumentsNotifier.new);

class ProcedureDocumentsNotifier
    extends FamilyAsyncNotifier<List<ProcessDocument>, String> {
  StreamSubscription? _subscription;

  @override
  Future<List<ProcessDocument>> build(String processId) async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents(processId);
    ref.onDispose(() => _subscription?.cancel());
    return _fetch(processId);
  }

  void _listenToEvents(String processId) {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      if (event.type == 'document:uploaded' ||
          event.type == 'document:deleted') {
        refresh();
      }
    });
  }

  Future<List<ProcessDocument>> _fetch(String processId) async {
    return (await ref.read(getProcedureDocumentsUseCaseProvider)(
      processId,
    )).getOrThrow();
  }

  Future<void> refresh() async {
    final processId = arg;
    try {
      final documents = await _fetch(processId);
      state = AsyncValue.data(documents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

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
    void Function(int count, int total)? onSendProgress,
  }) async {
    (await _ref
            .read(uploadDocumentUseCaseProvider)
            .call(
              processId: processId,
              filePath: filePath,
              fileName: fileName,
              onSendProgress: onSendProgress,
            ))
        .getOrThrow();
    _ref.invalidate(procedureDocumentsProvider(processId));
    _ref.invalidate(myDocumentsProvider);
    _ref.invalidate(myRecentDocumentsProvider);
  }

  Future<void> addNote({
    required String processId,
    required String note,
  }) async {
    (await _ref
            .read(addNoteUseCaseProvider)
            .call(processId: processId, note: note))
        .getOrThrow();
    _ref.invalidate(procedureDetailsProvider(processId));
    _ref.invalidate(procedureTimelineProvider(processId));
  }

  Future<void> requestDocument({
    required String processId,
    required String documentName,
  }) async {
    (await _ref
            .read(requestDocumentUseCaseProvider)
            .call(processId: processId, documentName: documentName))
        .getOrThrow();
    _ref.invalidate(procedureDetailsProvider(processId));
    _ref.invalidate(procedureTimelineProvider(processId));
  }

  Future<void> scheduleEvent({
    required String processId,
    required String title,
    required DateTime date,
  }) async {
    (await _ref
            .read(scheduleEventUseCaseProvider)
            .call(processId: processId, title: title, date: date))
        .getOrThrow();
    _ref.invalidate(procedureDetailsProvider(processId));
    _ref.invalidate(procedureTimelineProvider(processId));
  }

  Future<LegalProcess> createProcess({
    required String clientId,
    required String title,
    required String caseType,
    String? description,
    String? processNumber,
  }) async {
    final process =
        (await _ref
                .read(createProcedureUseCaseProvider)
                .call(
                  clientId: clientId,
                  title: title,
                  caseType: caseType,
                  description: description,
                  processNumber: processNumber,
                ))
            .getOrThrow();
    _ref.invalidate(myProceduresProvider);
    return process;
  }
}
