import 'package:fpdart/fpdart.dart';
import '../../../../../../shared/errors/failures.dart';
import '../../../../../../shared/errors/repository_guard.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';

final class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource _remoteDataSource;

  const AppointmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Appointment>>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return guardRepository(
      () => _remoteDataSource.getAppointments(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Future<Either<Failure, Appointment>> create(
    Map<String, dynamic> data,
  ) {
    return guardRepository(() => _remoteDataSource.createAppointment(data));
  }
}
