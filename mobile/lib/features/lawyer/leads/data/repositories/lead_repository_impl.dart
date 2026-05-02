import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../datasources/lead_remote_data_source.dart';

final class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDataSource _remoteDataSource;

  const LeadRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Lead>>> getPending() {
    return guardRepository(_remoteDataSource.getPending);
  }

  @override
  Future<Either<Failure, List<Lead>>> getByStatus(String status) {
    return guardRepository(() => _remoteDataSource.getByStatus(status));
  }

  @override
  Future<Either<Failure, Lead>> getById(String id) {
    return guardRepository(() => _remoteDataSource.getById(id));
  }

  @override
  Future<Either<Failure, Unit>> convert(String id) {
    return guardRepositoryUnit(() => _remoteDataSource.convert(id));
  }

  @override
  Future<Either<Failure, Unit>> discard(String id, {String? reason}) {
    return guardRepositoryUnit(
      () => _remoteDataSource.discard(id, reason: reason),
    );
  }
}
