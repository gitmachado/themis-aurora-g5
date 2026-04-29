import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

final class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ChatMessage>>> getHistoryByWhatsapp(
    String whatsappNumber,
  ) {
    return guardRepository(
      () => _remoteDataSource.getHistoryByWhatsapp(whatsappNumber),
    );
  }
}
