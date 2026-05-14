import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';
import '../../../../../../shared/network/websocket_client.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../../clients/presentation/providers/lawyer_client_providers.dart';
import '../../data/datasources/lead_remote_data_source.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/usecases/lead_use_cases.dart';
import '../../domain/usecases/delete_lead_use_case.dart';

final leadRemoteDataSourceProvider = Provider<LeadRemoteDataSource>((ref) {
  return LeadRemoteDataSource(ref.watch(apiClientProvider));
});

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepositoryImpl(ref.watch(leadRemoteDataSourceProvider));
});

final getPendingLeadsUseCaseProvider = Provider<GetPendingLeadsUseCase>((ref) {
  return GetPendingLeadsUseCase(ref.watch(leadRepositoryProvider));
});

final getAllLeadsUseCaseProvider = Provider<GetAllLeadsUseCase>((ref) {
  return GetAllLeadsUseCase(ref.watch(leadRepositoryProvider));
});

final getLeadByIdUseCaseProvider = Provider<GetLeadByIdUseCase>((ref) {
  return GetLeadByIdUseCase(ref.watch(leadRepositoryProvider));
});

final getLeadsByStatusUseCaseProvider = Provider<GetLeadsByStatusUseCase>((
  ref,
) {
  return GetLeadsByStatusUseCase(ref.watch(leadRepositoryProvider));
});

final convertLeadUseCaseProvider = Provider<ConvertLeadUseCase>((ref) {
  return ConvertLeadUseCase(ref.watch(leadRepositoryProvider));
});

final discardLeadUseCaseProvider = Provider<DiscardLeadUseCase>((ref) {
  return DiscardLeadUseCase(ref.watch(leadRepositoryProvider));
});

final updateLeadUseCaseProvider = Provider<UpdateLeadUseCase>((ref) {
  return UpdateLeadUseCase(ref.watch(leadRepositoryProvider));
});

final deleteLeadUseCaseProvider = Provider<DeleteLeadUseCase>((ref) {
  return DeleteLeadUseCase(ref.watch(leadRepositoryProvider));
});

final pendingLeadsProvider =
    AsyncNotifierProvider<PendingLeadsNotifier, List<Lead>>(
      PendingLeadsNotifier.new,
    );

class PendingLeadsNotifier extends AsyncNotifier<List<Lead>> {
  StreamSubscription? _subscription;

  @override
  Future<List<Lead>> build() async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      if (event.type == 'lead:updated' ||
          event.type == 'lead:locked' ||
          event.type == 'lead:unlocked' ||
          event.type == 'lead:deleted' ||
          event.type == 'leads:reset' ||
          event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<Lead>> _fetch() async {
    return (await ref.read(getPendingLeadsUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    try {
      final leads = await _fetch();
      state = AsyncValue.data(leads);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final allLeadsProvider = AsyncNotifierProvider<AllLeadsNotifier, List<Lead>>(
  AllLeadsNotifier.new,
);

class AllLeadsNotifier extends AsyncNotifier<List<Lead>> {
  StreamSubscription? _subscription;

  @override
  Future<List<Lead>> build() async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      if (event.type == 'lead:updated' ||
          event.type == 'lead:locked' ||
          event.type == 'lead:unlocked' ||
          event.type == 'lead:deleted' ||
          event.type == 'leads:reset' ||
          event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<Lead>> _fetch() async {
    return (await ref.read(getAllLeadsUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    try {
      final leads = await _fetch();
      state = AsyncValue.data(leads);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final archivedLeadsProvider = Provider<AsyncValue<List<Lead>>>((ref) {
  final allLeads = ref.watch(allLeadsProvider);
  return allLeads.whenData(
    (items) => items.where((l) => l.status == 'DISCARDED').toList(),
  );
});

final leadDetailsProvider = FutureProvider.family<Lead, String>((
  ref,
  id,
) async {
  return (await ref.watch(getLeadByIdUseCaseProvider)(id)).getOrThrow();
});

final leadActionsProvider = Provider<LeadActions>((ref) {
  return LeadActions(ref);
});

final class LeadActions {
  final Ref _ref;

  const LeadActions(this._ref);

  Future<void> convert(String id) async {
    (await _ref.read(convertLeadUseCaseProvider)(id)).getOrThrow();
    _ref.invalidate(pendingLeadsProvider);
    _ref.invalidate(allLeadsProvider);
    _ref.invalidate(archivedLeadsProvider);
    _ref.invalidate(leadDetailsProvider(id));
    _ref.invalidate(myLawyerClientsProvider);
  }

  Future<void> discard(String id, {String? reason}) async {
    (await _ref.read(discardLeadUseCaseProvider)(
      id,
      reason: reason,
    )).getOrThrow();
    _ref.invalidate(pendingLeadsProvider);
    _ref.invalidate(allLeadsProvider);
    _ref.invalidate(archivedLeadsProvider);
    _ref.invalidate(leadDetailsProvider(id));
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      debugPrint('LeadActions: Atualizando lead $id com dados $data');
      (await _ref.read(updateLeadUseCaseProvider)(id, data)).getOrThrow();
      debugPrint('LeadActions: Sucesso na API. Invalidando caches...');
      _ref.invalidate(pendingLeadsProvider);
      _ref.invalidate(allLeadsProvider);
      _ref.invalidate(archivedLeadsProvider);
      _ref.invalidate(leadDetailsProvider(id));
      debugPrint('LeadActions: Caches invalidados.');
    } catch (e) {
      debugPrint('LeadActions: Erro no update: $e');
      rethrow;
    }
  }

  Future<void> deleteLead(String id) async {
    try {
      debugPrint('LeadActions: Deletando lead $id');
      (await _ref.read(deleteLeadUseCaseProvider)(id)).getOrThrow();
      debugPrint('LeadActions: Sucesso na API. Invalidando caches...');

      _ref.invalidate(pendingLeadsProvider);
      _ref.invalidate(allLeadsProvider);
      _ref.invalidate(archivedLeadsProvider);

      debugPrint('LeadActions: Caches invalidados.');
    } catch (e) {
      debugPrint('LeadActions: Erro no delete: $e');
      rethrow;
    }
  }
}
