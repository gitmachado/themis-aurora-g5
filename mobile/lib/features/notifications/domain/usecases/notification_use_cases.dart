import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

final class GetMyNotificationsUseCase {
  final NotificationRepository _repository;

  const GetMyNotificationsUseCase(this._repository);

  Future<Either<Failure, List<AppNotification>>> call() {
    return _repository.getMyNotifications();
  }
}

final class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.markAsRead(id);
  }
}

final class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsReadUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.markAllAsRead();
  }
}

final class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  const DeleteNotificationUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.delete(id);
  }
}

final class DeleteManyNotificationsUseCase {
  final NotificationRepository _repository;

  const DeleteManyNotificationsUseCase(this._repository);

  Future<Either<Failure, Unit>> call(List<String> ids) {
    return _repository.deleteMany(ids);
  }
}
