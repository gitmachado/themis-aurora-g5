import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/lawyer_client.dart';
import '../repositories/lawyer_client_repository.dart';

final class GetMyLawyerClientsUseCase {
  final LawyerClientRepository _repository;

  const GetMyLawyerClientsUseCase(this._repository);

  Future<Either<Failure, List<LawyerClient>>> call() {
    return _repository.getMyClients();
  }
}

final class GetLawyerClientByIdUseCase {
  final LawyerClientRepository _repository;

  const GetLawyerClientByIdUseCase(this._repository);

  Future<Either<Failure, LawyerClient>> call(String id) {
    return _repository.getById(id);
  }
}

final class DeleteLawyerClientUseCase {
  final LawyerClientRepository _repository;

  const DeleteLawyerClientUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteClient(id);
  }
}
