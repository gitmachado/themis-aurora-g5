import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/lawyer_client.dart';

abstract interface class LawyerClientRepository {
  Future<Either<Failure, List<LawyerClient>>> getMyClients();
  Future<Either<Failure, LawyerClient>> getById(String id);
  Future<Either<Failure, void>> deleteClient(String id);
}
