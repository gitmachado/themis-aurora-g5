import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.watch(apiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});

final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  whatsappNumber,
) {
  return ref.watch(chatRepositoryProvider).getHistoryByWhatsapp(whatsappNumber);
});
