import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class GetChatHistoryByWhatsappUseCase {
  final ChatRepository _repository;

  const GetChatHistoryByWhatsappUseCase(this._repository);

  Future<Either<Failure, List<ChatMessage>>> call(String whatsappNumber) {
    return _repository.getHistoryByWhatsapp(whatsappNumber);
  }
}
