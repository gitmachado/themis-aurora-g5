import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getHistoryByWhatsapp(
    String whatsappNumber,
  );
}
