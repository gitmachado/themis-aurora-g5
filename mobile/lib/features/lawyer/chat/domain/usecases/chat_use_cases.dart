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

final class SendMessageUseCase {
  final ChatRepository _repository;

  const SendMessageUseCase(this._repository);

  Future<Either<Failure, ChatMessage>> call(
    String whatsappNumber,
    String content,
  ) {
    return _repository.sendMessage(whatsappNumber, content);
  }
}

final class ResumeAIUseCase {
  final ChatRepository _repository;

  const ResumeAIUseCase(this._repository);

  Future<Either<Failure, void>> call(String whatsappNumber) {
    return _repository.resumeAI(whatsappNumber);
  }
}

final class HandoffToHumanUseCase {
  final ChatRepository _repository;

  const HandoffToHumanUseCase(this._repository);

  Future<Either<Failure, void>> call(String whatsappNumber) {
    return _repository.handoffToHuman(whatsappNumber);
  }
}

final class GetLeadByPhoneUseCase {
  final ChatRepository _repository;

  const GetLeadByPhoneUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String phone) {
    return _repository.getLeadByPhone(phone);
  }
}

final class AssignLeadUseCase {
  final ChatRepository _repository;

  const AssignLeadUseCase(this._repository);

  Future<Either<Failure, void>> call(String leadId) {
    return _repository.assignLead(leadId);
  }
}

final class ReleaseLeadUseCase {
  final ChatRepository _repository;

  const ReleaseLeadUseCase(this._repository);

  Future<Either<Failure, void>> call(String leadId) {
    return _repository.releaseLead(leadId);
  }
}
