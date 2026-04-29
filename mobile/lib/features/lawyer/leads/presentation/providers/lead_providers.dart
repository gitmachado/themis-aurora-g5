import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/lead_remote_data_source.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/usecases/lead_use_cases.dart';

final leadRemoteDataSourceProvider = Provider<LeadRemoteDataSource>((ref) {
  return LeadRemoteDataSource(ref.watch(apiClientProvider));
});

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepositoryImpl(ref.watch(leadRemoteDataSourceProvider));
});

final getPendingLeadsUseCaseProvider = Provider<GetPendingLeadsUseCase>((ref) {
  return GetPendingLeadsUseCase(ref.watch(leadRepositoryProvider));
});

final getLeadByIdUseCaseProvider = Provider<GetLeadByIdUseCase>((ref) {
  return GetLeadByIdUseCase(ref.watch(leadRepositoryProvider));
});

final convertLeadUseCaseProvider = Provider<ConvertLeadUseCase>((ref) {
  return ConvertLeadUseCase(ref.watch(leadRepositoryProvider));
});

final discardLeadUseCaseProvider = Provider<DiscardLeadUseCase>((ref) {
  return DiscardLeadUseCase(ref.watch(leadRepositoryProvider));
});

final pendingLeadsProvider = FutureProvider<List<Lead>>((ref) async {
  return (await ref.watch(getPendingLeadsUseCaseProvider)()).getOrThrow();
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
    _ref.invalidate(leadDetailsProvider(id));
  }

  Future<void> discard(String id, {String? reason}) async {
    (await _ref.read(discardLeadUseCaseProvider)(
      id,
      reason: reason,
    )).getOrThrow();
    _ref.invalidate(pendingLeadsProvider);
    _ref.invalidate(leadDetailsProvider(id));
  }
}
