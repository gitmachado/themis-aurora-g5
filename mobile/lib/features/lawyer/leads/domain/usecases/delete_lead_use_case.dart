import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import '../repositories/lead_repository.dart';

class DeleteLeadUseCase {
  final LeadRepository _repository;

  DeleteLeadUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteLead(id);
  }
}
