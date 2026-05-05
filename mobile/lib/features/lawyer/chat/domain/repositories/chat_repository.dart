import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getHistoryByWhatsapp(
    String whatsappNumber,
  );

  Future<Either<Failure, ChatMessage>> sendMessage(
    String whatsappNumber,
    String content,
  );

  Future<Either<Failure, void>> resumeAI(String whatsappNumber);
  Future<Either<Failure, void>> handoffToHuman(String whatsappNumber);
  Future<Either<Failure, Map<String, dynamic>>> getLeadByPhone(String phone);
  Future<Either<Failure, void>> assignLead(String leadId);
  Future<Either<Failure, void>> releaseLead(String leadId);
}
