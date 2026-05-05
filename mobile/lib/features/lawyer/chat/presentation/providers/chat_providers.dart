import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/network/websocket_client.dart';
import '../../data/models/chat_message_model.dart';

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

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final resumeAIUseCaseProvider = Provider<ResumeAIUseCase>((ref) {
  return ResumeAIUseCase(ref.watch(chatRepositoryProvider));
});

final handoffToHumanUseCaseProvider = Provider((ref) {
  return HandoffToHumanUseCase(ref.watch(chatRepositoryProvider));
});

final getLeadByPhoneUseCaseProvider = Provider((ref) {
  return GetLeadByPhoneUseCase(ref.watch(chatRepositoryProvider));
});

final assignLeadUseCaseProvider = Provider(
  (ref) => AssignLeadUseCase(ref.watch(chatRepositoryProvider)),
);
final releaseLeadUseCaseProvider = Provider(
  (ref) => ReleaseLeadUseCase(ref.watch(chatRepositoryProvider)),
);

final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  whatsappNumber,
) async {
  final result = await ref.watch(getChatHistoryByWhatsappUseCaseProvider)(
    whatsappNumber,
  );

  return result.fold((failure) => throw failure, (messages) => messages);
});

class ChatLockState {
  final String? lawyerId;
  final String? lawyerName;
  final bool isLocked;

  const ChatLockState({this.lawyerId, this.lawyerName, this.isLocked = false});

  factory ChatLockState.initial() => const ChatLockState();
}

final chatLockProvider = StateProvider.family<ChatLockState, String>((
  ref,
  whatsappNumber,
) {
  return ChatLockState.initial();
});

class LiveChatNotifier extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  StreamSubscription? _subscription;

  @override
  Future<List<ChatMessage>> build(String arg) async {
    final wsClient = ref.watch(webSocketClientProvider);

    // Tenta entrar na sala. Se não estiver conectado ainda, 
    // o listener abaixo cuidará disso quando conectar.
    if (wsClient.isConnected) {
      wsClient.joinChat(arg);
    }

    _listenToEvents();

    ref.onDispose(() {
      wsClient.leaveChat(arg);
      _subscription?.cancel();
    });

    return ref.watch(chatHistoryProvider(arg).future);
  }

  void _listenToEvents() {
    _subscription?.cancel();
    // Usamos read aqui para evitar reconstruir a subscription se o provider do cliente mudar
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      final currentChat = arg.split('@')[0].replaceFirst('+', '');
      
      if (event.type == 'message:new') {
        final incomingNumber = (event.data['whatsappNumber'] as String).split('@')[0].replaceFirst('+', '');
        
        if (kDebugMode) {
          print('[LiveChat] Message arrived for $incomingNumber. Current chat: $currentChat');
        }

        if (incomingNumber == currentChat) {
          final message = ChatMessageModel.fromJson(event.data);
          state = AsyncData([...state.value ?? [], message]);
        }
      } else if (event.type == 'lead:locked') {
        final incomingNumber = (event.data['whatsappNumber'] as String).split('@')[0].replaceFirst('+', '');
        if (incomingNumber == currentChat) {
          final data = event.data;
          ref.read(chatLockProvider(arg).notifier).state = ChatLockState(
            lawyerId: data['lawyerId'],
            lawyerName: data['lawyerName'],
            isLocked: true,
          );
        }
      } else if (event.type == 'lead:unlocked') {
        final incomingNumber = (event.data['whatsappNumber'] as String).split('@')[0].replaceFirst('+', '');
        if (incomingNumber == currentChat) {
          ref.read(chatLockProvider(arg).notifier).state =
              ChatLockState.initial();
        }
      } else if (event.type == 'connected') {
        if (kDebugMode) print('[LiveChat] Socket connected, joining room...');
        ref.read(webSocketClientProvider).joinChat(arg);
        ref.invalidate(chatHistoryProvider(arg));
      }
    });
  }

  Future<void> sendMessage(String content) async {
    final whatsappNumber = arg;
    final result = await ref.read(sendMessageUseCaseProvider)(
      whatsappNumber,
      content,
    );

    result.fold(
      (failure) => null, // Handle error
      (message) {
        // Message will also come via WebSocket, but we can optimistically update here
        // or just wait for the WS event. Let's rely on WS to avoid duplicates.
      },
    );
  }

  Future<void> resumeAI() async {
    final whatsappNumber = arg;
    await ref.read(resumeAIUseCaseProvider)(whatsappNumber);
  }

  Future<void> handoffToHuman() async {
    final whatsappNumber = arg;
    await ref.read(handoffToHumanUseCaseProvider)(whatsappNumber);
  }

  Future<void> assignToMe(String leadId) async {
    await ref.read(assignLeadUseCaseProvider)(leadId);
  }

  Future<void> releaseLead(String leadId) async {
    await ref.read(releaseLeadUseCaseProvider)(leadId);
  }

  Future<Map<String, dynamic>> getLeadInfo() async {
    final whatsappNumber = arg;
    final result = await ref
        .read(getLeadByPhoneUseCaseProvider)
        .call(whatsappNumber);
    return result.fold((_) => {}, (data) => data);
  }
}

final liveChatProvider =
    AsyncNotifierProvider.family<LiveChatNotifier, List<ChatMessage>, String>(
      LiveChatNotifier.new,
    );
