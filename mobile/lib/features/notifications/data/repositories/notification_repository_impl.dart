import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<AppNotification>>> getMyNotifications() {
    return guardRepository(_remoteDataSource.getMyNotifications);
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) {
    return guardRepositoryUnit(() => _remoteDataSource.markAsRead(id));
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() {
    return guardRepositoryUnit(_remoteDataSource.markAllAsRead);
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) {
    return guardRepositoryUnit(() => _remoteDataSource.delete(id));
  }

  @override
  Future<Either<Failure, Unit>> deleteMany(List<String> ids) {
    return guardRepositoryUnit(() => _remoteDataSource.deleteMany(ids));
  }
}
