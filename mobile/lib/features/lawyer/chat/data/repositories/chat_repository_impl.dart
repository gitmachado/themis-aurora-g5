import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

final class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatMessage>> getHistoryByWhatsapp(String whatsappNumber) {
    return _remoteDataSource.getHistoryByWhatsapp(whatsappNumber);
  }
}
