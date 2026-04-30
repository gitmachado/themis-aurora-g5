import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/chat_use_cases.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.watch(apiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});

final getChatHistoryByWhatsappUseCaseProvider =
    Provider<GetChatHistoryByWhatsappUseCase>((ref) {
      return GetChatHistoryByWhatsappUseCase(ref.watch(chatRepositoryProvider));
    });

final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  whatsappNumber,
) async {
  return (await ref.watch(getChatHistoryByWhatsappUseCaseProvider)(
    whatsappNumber,
  )).getOrThrow();
});
