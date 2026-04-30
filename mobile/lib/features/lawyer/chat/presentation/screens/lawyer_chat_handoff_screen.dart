import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/lawyer/chat/domain/entities/chat_message.dart';
import '../../../../../../features/lawyer/chat/presentation/providers/chat_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerChatHandoffScreen extends ConsumerWidget {
  final String clientName;
  final String whatsappNumber;

  const LawyerChatHandoffScreen({
    super.key,
    required this.clientName,
    required this.whatsappNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = whatsappNumber.isEmpty
        ? null
        : ref.watch(chatHistoryProvider(whatsappNumber));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: clientName,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: whatsappNumber.isEmpty
                ? null
                : () => ref.invalidate(chatHistoryProvider(whatsappNumber)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReadOnlyBanner(),
          Expanded(
            child: history == null
                ? const Center(child: Text('WhatsApp nao informado.'))
                : history.when(
                    data: _buildChatList,
                    loading: _buildLoadingList,
                    error: (error, _) => Center(child: Text(error.toString())),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: const Row(
        children: [
          Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Histórico do WhatsApp em modo somente leitura.',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text('Nenhuma mensagem encontrada.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) =>
          _buildChatBubble(context, messages[index]),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 64, borderRadius: 16),
    );
  }

  Widget _buildChatBubble(BuildContext context, ChatMessage message) {
    final isClient = message.sender == 'CLIENT';
    final isBot = message.sender == 'BOT';
    final isLawyer = message.sender == 'LAWYER';

    return Align(
      alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isClient
              ? AppColors.surface
              : (isBot ? AppColors.primaryOverlay : AppColors.primary),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isClient ? 0 : 16),
            bottomRight: Radius.circular(isClient ? 16 : 0),
          ),
          border: isClient ? Border.all(color: AppColors.divider) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBot || isLawyer)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  isBot ? 'ASSISTENTE IA' : 'ADVOGADO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isLawyer ? Colors.white : AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isLawyer ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formatRelativeDate(message.createdAt),
                style: TextStyle(
                  color: isLawyer
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textCaption,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
