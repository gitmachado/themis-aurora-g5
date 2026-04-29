import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

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

final myLawyerClientsProvider = FutureProvider<List<LawyerClient>>((ref) async {
  return (await ref.watch(getMyLawyerClientsUseCaseProvider)()).getOrThrow();
});

final lawyerClientDetailsProvider = FutureProvider.family<LawyerClient, String>(
  (ref, id) async {
    return (await ref.watch(getLawyerClientByIdUseCaseProvider)(
      id,
    )).getOrThrow();
  },
);
