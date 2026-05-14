import 'package:fpdart/fpdart.dart';
import '../../../../../../shared/errors/failures.dart';
import '../entities/appointment.dart';

abstract interface class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<Failure, Appointment>> create(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Appointment>> updateStatus(
    String id,
    String status,
  );
}
