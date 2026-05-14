import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/i_lawyer_chat_repository.dart';
import '../datasources/lawyer_chat_remote_datasource.dart';

final class LawyerChatRepositoryImpl implements ILawyerChatRepository {
  final LawyerChatRemoteDataSource _remoteDataSource;

  const LawyerChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String message) {
    return guardRepository(() => _remoteDataSource.sendMessage(message));
  }
}
