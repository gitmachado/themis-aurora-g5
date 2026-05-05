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

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(
    String whatsappNumber,
    String content,
  ) {
    return guardRepository(
      () => _remoteDataSource.sendMessage(whatsappNumber, content),
    );
  }

  @override
  Future<Either<Failure, void>> resumeAI(String whatsappNumber) {
    return guardRepository(() => _remoteDataSource.resumeAI(whatsappNumber));
  }

  @override
  Future<Either<Failure, void>> handoffToHuman(String whatsappNumber) {
    return guardRepository(
      () => _remoteDataSource.handoffToHuman(whatsappNumber),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeadByPhone(String phone) {
    return guardRepository(() => _remoteDataSource.getLeadByPhone(phone));
  }

  @override
  Future<Either<Failure, void>> assignLead(String leadId) {
    return guardRepository(() => _remoteDataSource.assignLead(leadId));
  }

  @override
  Future<Either<Failure, void>> releaseLead(String leadId) {
    return guardRepository(() => _remoteDataSource.releaseLead(leadId));
  }
}
