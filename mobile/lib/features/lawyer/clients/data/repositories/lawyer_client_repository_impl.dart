import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/lawyer_client.dart';
import '../../domain/repositories/lawyer_client_repository.dart';
import '../datasources/lawyer_client_remote_data_source.dart';

final class LawyerClientRepositoryImpl implements LawyerClientRepository {
  final LawyerClientRemoteDataSource _remoteDataSource;

  const LawyerClientRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<LawyerClient>>> getMyClients() {
    return guardRepository(_remoteDataSource.getMyClients);
  }

  @override
  Future<Either<Failure, LawyerClient>> getById(String id) {
    return guardRepository(() => _remoteDataSource.getById(id));
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) {
    return guardRepository(() => _remoteDataSource.deleteClient(id));
  }
}
