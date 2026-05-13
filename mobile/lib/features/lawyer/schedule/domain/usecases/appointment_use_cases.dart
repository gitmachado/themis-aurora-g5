import 'package:fpdart/fpdart.dart';
import '../../../../../../shared/errors/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

final class GetAppointmentsUseCase {
  final AppointmentRepository _repository;

  const GetAppointmentsUseCase(this._repository);

  Future<Either<Failure, List<Appointment>>> call(
    DateTime startDate,
    DateTime endDate,
  ) =>
      _repository.getByDateRange(startDate, endDate);
}

final class CreateAppointmentUseCase {
  final AppointmentRepository _repository;

  const CreateAppointmentUseCase(this._repository);

  Future<Either<Failure, Appointment>> call(
    Map<String, dynamic> data,
  ) =>
      _repository.create(data);
}
