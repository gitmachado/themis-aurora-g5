import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/chat_message.dart';
import '../repositories/i_lawyer_chat_repository.dart';

final class SendLawyerMessageUseCase {
  final ILawyerChatRepository _repository;

  const SendLawyerMessageUseCase(this._repository);

  Future<Either<Failure, ChatMessage>> call(String message) {
    return _repository.sendMessage(message);
  }
}
