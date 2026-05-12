import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/network/api_client.dart';

import '../../data/datasources/lawyer_chat_remote_datasource.dart';
import '../../data/repositories/lawyer_chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/i_lawyer_chat_repository.dart';
import '../../domain/usecases/send_lawyer_message_usecase.dart';

class LawyerChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const LawyerChatState({
    required this.messages,
    required this.isLoading,
    this.errorMessage,
  });

  factory LawyerChatState.initial() {
    return const LawyerChatState(
      messages: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  LawyerChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LawyerChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
}

class LawyerChatNotifier extends StateNotifier<LawyerChatState> {
  final SendLawyerMessageUseCase _sendLawyerMessageUseCase;

  LawyerChatNotifier(this._sendLawyerMessageUseCase) : super(LawyerChatState.initial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    final result = await _sendLawyerMessageUseCase(text.trim());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (botMessage) {
        state = state.copyWith(
          messages: [...state.messages, botMessage],
          isLoading: false,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message.contains('timeout') || 
        failure.message.contains('demorou') || 
        failure.message.contains('tempo limite')) {
      return 'O assistente de IA demorou para responder. Por favor, tente novamente.';
    }
    return failure.message;
  }
}

final lawyerChatRemoteDataSourceProvider = Provider<LawyerChatRemoteDataSource>((ref) {
  return LawyerChatRemoteDataSource(ref.watch(apiClientProvider));
});

final lawyerChatRepositoryProvider = Provider<ILawyerChatRepository>((ref) {
  return LawyerChatRepositoryImpl(ref.watch(lawyerChatRemoteDataSourceProvider));
});

final sendLawyerMessageUseCaseProvider = Provider<SendLawyerMessageUseCase>((ref) {
  return SendLawyerMessageUseCase(ref.watch(lawyerChatRepositoryProvider));
});

final lawyerChatProvider = StateNotifierProvider<LawyerChatNotifier, LawyerChatState>((ref) {
  return LawyerChatNotifier(ref.watch(sendLawyerMessageUseCaseProvider));
});
