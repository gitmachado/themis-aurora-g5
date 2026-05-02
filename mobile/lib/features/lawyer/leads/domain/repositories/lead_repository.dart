import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/lead.dart';

abstract interface class LeadRepository {
  Future<Either<Failure, List<Lead>>> getPending();
  Future<Either<Failure, List<Lead>>> getByStatus(String status);
  Future<Either<Failure, Lead>> getById(String id);
  Future<Either<Failure, Unit>> convert(String id);
  Future<Either<Failure, Unit>> discard(String id, {String? reason});
}
