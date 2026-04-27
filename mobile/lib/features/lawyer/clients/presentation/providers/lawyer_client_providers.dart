import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/lawyer_client_remote_data_source.dart';
import '../../data/repositories/lawyer_client_repository_impl.dart';
import '../../domain/entities/lawyer_client.dart';
import '../../domain/repositories/lawyer_client_repository.dart';

final lawyerClientRemoteDataSourceProvider =
    Provider<LawyerClientRemoteDataSource>((ref) {
      return LawyerClientRemoteDataSource(ref.watch(apiClientProvider));
    });

final lawyerClientRepositoryProvider = Provider<LawyerClientRepository>((ref) {
  return LawyerClientRepositoryImpl(
    ref.watch(lawyerClientRemoteDataSourceProvider),
  );
});

final myLawyerClientsProvider = FutureProvider<List<LawyerClient>>((ref) {
  return ref.watch(lawyerClientRepositoryProvider).getMyClients();
});

final lawyerClientDetailsProvider = FutureProvider.family<LawyerClient, String>(
  (ref, id) {
    return ref.watch(lawyerClientRepositoryProvider).getById(id);
  },
);
