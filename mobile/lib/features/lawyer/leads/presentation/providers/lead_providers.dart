import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/lead_remote_data_source.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';

final leadRemoteDataSourceProvider = Provider<LeadRemoteDataSource>((ref) {
  return LeadRemoteDataSource(ref.watch(apiClientProvider));
});

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepositoryImpl(ref.watch(leadRemoteDataSourceProvider));
});

final pendingLeadsProvider = FutureProvider<List<Lead>>((ref) {
  return ref.watch(leadRepositoryProvider).getPending();
});

final leadDetailsProvider = FutureProvider.family<Lead, String>((ref, id) {
  return ref.watch(leadRepositoryProvider).getById(id);
});

final leadActionsProvider = Provider<LeadActions>((ref) {
  return LeadActions(ref);
});

final class LeadActions {
  final Ref _ref;

  const LeadActions(this._ref);

  Future<void> convert(String id) async {
    await _ref.read(leadRepositoryProvider).convert(id);
    _ref.invalidate(pendingLeadsProvider);
    _ref.invalidate(leadDetailsProvider(id));
  }

  Future<void> discard(String id, {String? reason}) async {
    await _ref.read(leadRepositoryProvider).discard(id, reason: reason);
    _ref.invalidate(pendingLeadsProvider);
    _ref.invalidate(leadDetailsProvider(id));
  }
}
