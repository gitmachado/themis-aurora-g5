import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

final class GetPendingLeadsUseCase {
  final LeadRepository _repository;

  const GetPendingLeadsUseCase(this._repository);

  Future<Either<Failure, List<Lead>>> call() {
    return _repository.getPending();
  }
}

final class GetLeadByIdUseCase {
  final LeadRepository _repository;

  const GetLeadByIdUseCase(this._repository);

  Future<Either<Failure, Lead>> call(String id) {
    return _repository.getById(id);
  }
}

final class GetLeadsByStatusUseCase {
  final LeadRepository _repository;

  const GetLeadsByStatusUseCase(this._repository);

  Future<Either<Failure, List<Lead>>> call(String status) {
    return _repository.getByStatus(status);
  }
}

final class ConvertLeadUseCase {
  final LeadRepository _repository;

  const ConvertLeadUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.convert(id);
  }
}

final class DiscardLeadUseCase {
  final LeadRepository _repository;

  const DiscardLeadUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id, {String? reason}) {
    return _repository.discard(id, reason: reason);
  }
}
