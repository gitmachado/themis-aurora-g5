import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import '../entities/chat_message.dart';

abstract interface class ILawyerChatRepository {
  Future<Either<Failure, ChatMessage>> sendMessage(String message);
}
