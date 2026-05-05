import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';
import '../../../../../../shared/network/websocket_client.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/lawyer_client_remote_data_source.dart';
import '../../data/repositories/lawyer_client_repository_impl.dart';
import '../../domain/entities/lawyer_client.dart';
import '../../domain/repositories/lawyer_client_repository.dart';
import '../../domain/usecases/lawyer_client_use_cases.dart';

final lawyerClientRemoteDataSourceProvider =
    Provider<LawyerClientRemoteDataSource>((ref) {
      return LawyerClientRemoteDataSource(ref.watch(apiClientProvider));
    });

final lawyerClientRepositoryProvider = Provider<LawyerClientRepository>((ref) {
  return LawyerClientRepositoryImpl(
    ref.watch(lawyerClientRemoteDataSourceProvider),
  );
});

final getMyLawyerClientsUseCaseProvider = Provider<GetMyLawyerClientsUseCase>((
  ref,
) {
  return GetMyLawyerClientsUseCase(ref.watch(lawyerClientRepositoryProvider));
});

final getLawyerClientByIdUseCaseProvider = Provider<GetLawyerClientByIdUseCase>(
  (ref) {
    return GetLawyerClientByIdUseCase(
      ref.watch(lawyerClientRepositoryProvider),
    );
  },
);

final myLawyerClientsProvider =
    AsyncNotifierProvider<LawyerClientsNotifier, List<LawyerClient>>(
      LawyerClientsNotifier.new,
    );

class LawyerClientsNotifier extends AsyncNotifier<List<LawyerClient>> {
  StreamSubscription? _subscription;

  @override
  Future<List<LawyerClient>> build() async {
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.watch(webSocketClientProvider).events.listen((event) {
      // Refresh when a lead is updated (e.g. converted to client)
      if (event.type == 'lead:updated' || event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<LawyerClient>> _fetch() async {
    return (await ref.read(getMyLawyerClientsUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }
}

final lawyerClientDetailsProvider = FutureProvider.family<LawyerClient, String>(
  (ref, id) async {
    return (await ref.watch(getLawyerClientByIdUseCaseProvider)(
      id,
    )).getOrThrow();
  },
);
