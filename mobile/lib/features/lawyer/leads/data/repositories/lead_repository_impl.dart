import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../datasources/lead_remote_data_source.dart';

final class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDataSource _remoteDataSource;

  const LeadRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Lead>> getPending() => _remoteDataSource.getPending();

  @override
  Future<Lead> getById(String id) => _remoteDataSource.getById(id);

  @override
  Future<void> convert(String id) => _remoteDataSource.convert(id);

  @override
  Future<void> discard(String id, {String? reason}) {
    return _remoteDataSource.discard(id, reason: reason);
  }
}
