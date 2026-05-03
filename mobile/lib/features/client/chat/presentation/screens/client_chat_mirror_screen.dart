import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/chat/domain/entities/chat_message.dart';
import '../../../../../../features/lawyer/chat/presentation/providers/chat_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../widgets/chat_bubble.dart';

class ClientChatMirrorScreen extends ConsumerWidget {
  final bool showBackButton;

  const ClientChatMirrorScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: CustomAppBar(
        title: '',
        showBackButton: showBackButton,
        centerTitle: false,
        titleWidget: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.yellow,
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.ink,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Themis', style: AppTextStyles.h2.copyWith(fontSize: 15)),
                Text(
                  'via WhatsApp',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: account.when(
          data: (account) {
            if (account.whatsappNumber.isEmpty) {
              return _buildEmptyState('WhatsApp nao cadastrado na conta.');
            }

            final history = ref.watch(
              chatHistoryProvider(account.whatsappNumber),
            );
            return Column(
              children: [
                Expanded(
                  child: history.when(
                    data: _buildMessageList,
                    loading: _buildLoadingList,
                    error: (error, _) => _buildErrorState(error),
                  ),
                ),
              ],
            );
          },
          loading: _buildLoadingList,
          error: (error, _) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState('Nenhuma mensagem sincronizada ainda.');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message.content,
          time: formatRelativeDate(message.createdAt),
          isMe: message.sender == 'CLIENT',
          highlight: message.sender == 'BOT' || message.sender == 'LAWYER',
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 64, borderRadius: 16),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textCaption),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
