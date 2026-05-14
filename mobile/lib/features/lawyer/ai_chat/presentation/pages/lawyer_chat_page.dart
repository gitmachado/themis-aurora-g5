import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/app_text_styles.dart';
import 'package:mobile/shared/utils/api_formatters.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/lawyer_chat_provider.dart';

class LawyerChatPage extends ConsumerStatefulWidget {
  const LawyerChatPage({super.key});

  @override
  ConsumerState<LawyerChatPage> createState() => _LawyerChatPageState();
}

class _LawyerChatPageState extends ConsumerState<LawyerChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    // Prevent concurrent sends if the user spams Enter while waiting:
    // the visual send button already disables, but `onSubmitted` from the
    // keyboard slipped through and could race the in-flight request.
    if (ref.read(lawyerChatProvider).isLoading) return;

    _textController.clear();
    _focusNode.requestFocus();
    ref.read(lawyerChatProvider.notifier).sendMessage(text);
  }

  void _sendSuggestion(String text) {
    ref.read(lawyerChatProvider.notifier).sendMessage(text);
  }

  Future<void> _confirmClearConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Limpar conversa'),
        content: const Text(
          'Tem certeza que deseja apagar todas as mensagens desta conversa? '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(lawyerChatProvider.notifier).clearConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(lawyerChatProvider);

    // Listens for updates (errors & list scrolling)
    ref.listen<LawyerChatState>(lawyerChatProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(lawyerChatProvider.notifier).clearError();
      }

      if (previous?.messages.length != next.messages.length ||
          previous?.isLoading != next.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistente Themis AI',
                    style: AppTextStyles.h2.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Online • Advogados',
                    style: AppTextStyles.tiny.copyWith(color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Limpar conversa',
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.ink),
            onPressed: chatState.messages.isEmpty
                ? null
                : () => _confirmClearConversation(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState.messages[index];
                        return _buildChatBubble(message);
                      },
                    ),
            ),
            if (chatState.isLoading) _buildLoadingBubble(),
            _buildInputArea(chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final suggestions = [
      'Olá, quais são meus processos?',
      'Quem é você e como pode me ajudar?',
      'Quais são os prazos urgentes de hoje?',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assistant_rounded,
                size: 48,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Como posso te ajudar, Dra?',
              style: AppTextStyles.h1.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Estou pronto para buscar processos, resumir andamentos, ou responder dúvidas do escritório em tempo real.',
              style: AppTextStyles.body.copyWith(color: AppColors.ink3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...suggestions.map(
              (text) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _sendSuggestion(text),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.surface,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isMe = message.isFromUser;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? AppColors.ink : AppColors.surface2;
    final textColor = isMe ? Colors.white : AppColors.textPrimary;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    final isDark = isMe;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.ink3;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                isMe ? 'ADVOGADO' : 'THEMIS AI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            isMe
                ? Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      strong: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                      em: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      listBullet: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      h1: AppTextStyles.h2.copyWith(color: textColor, fontSize: 18),
                      h2: AppTextStyles.h2.copyWith(color: textColor, fontSize: 17),
                      h3: AppTextStyles.h2.copyWith(color: textColor, fontSize: 16),
                      code: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        backgroundColor: AppColors.surface,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquote: AppTextStyles.body.copyWith(
                        color: AppColors.ink3,
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                      ),
                      blockSpacing: 6,
                    ),
                    onTapLink: (_, href, _) async {},
                  ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                Text(
                  formatTime(message.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9.5,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Themis está pensando...',
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.ink3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: !isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading ? null : (_) => _onSend(),
              decoration: InputDecoration(
                hintText: 'Pergunte ao assistente...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textCaption,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isLoading ? null : _onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
