import '../../domain/entities/lawyer_client.dart';
import '../../domain/repositories/lawyer_client_repository.dart';
import '../datasources/lawyer_client_remote_data_source.dart';

final class LawyerClientRepositoryImpl implements LawyerClientRepository {
  final LawyerClientRemoteDataSource _remoteDataSource;

  const LawyerClientRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LawyerClient>> getMyClients() {
    return _remoteDataSource.getMyClients();
  }

  @override
  Future<LawyerClient> getById(String id) {
    return _remoteDataSource.getById(id);
  }
}
