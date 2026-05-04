import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/chat/domain/entities/chat_message.dart';
import '../../../../../../features/lawyer/chat/presentation/providers/chat_providers.dart';
import '../../../../../../features/lawyer/leads/presentation/screens/lawyer_lead_detail_screen.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

import '../../../../../../shared/utils/string_utils.dart';

class LawyerChatHandoffScreen extends ConsumerStatefulWidget {
  final String clientName;
  final String whatsappNumber;

  const LawyerChatHandoffScreen({
    super.key,
    required this.clientName,
    required this.whatsappNumber,
  });

  @override
  ConsumerState<LawyerChatHandoffScreen> createState() =>
      _LawyerChatHandoffScreenState();
}

class _LawyerChatHandoffScreenState
    extends ConsumerState<LawyerChatHandoffScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _leadId;
  bool _isAIPaused = false;
  bool _isAITyping = false;
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.whatsappNumber.isEmpty) return;

    final notifier = ref.read(liveChatProvider(widget.whatsappNumber).notifier);
    final info = await notifier.getLeadInfo();

    if (mounted) {
      setState(() {
        _leadId = info['id'];
        _isAIPaused = info['isAIPaused'] ?? false;

        if (info['assignedLawyerId'] != null) {
          ref
              .read(chatLockProvider(widget.whatsappNumber).notifier)
              .state = ChatLockState(
            lawyerId: info['assignedLawyerId'],
            lawyerName: info['assignedLawyerName'] ?? 'Outro Advogado',
            isLocked: true,
          );
        }
      });
    }
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    if (mounted) {
      setState(() {
        _isAITyping = false;
      });
    }

    await ref
        .read(liveChatProvider(widget.whatsappNumber).notifier)
        .sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handleResumeAI() async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retornar para IA?'),
        content: const Text(
          'O bot assumirá o atendimento novamente e enviará uma mensagem de boas-vindas ao cliente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_leadId != null) {
        await ref
            .read(liveChatProvider(widget.whatsappNumber).notifier)
            .releaseLead(_leadId!);
      }
      if (mounted) {
        setState(() {
          _isAIPaused = false;
          _isAITyping = true;
          _lastMessageCount =
              ref.read(liveChatProvider(widget.whatsappNumber)).value?.length ??
              0;
        });
        _scrollToBottom();
      }
      await ref
          .read(liveChatProvider(widget.whatsappNumber).notifier)
          .resumeAI();
    }
  }

  Future<void> _handleStartHandoff() async {
    FocusScope.of(context).unfocus();

    if (_leadId != null) {
      await ref
          .read(liveChatProvider(widget.whatsappNumber).notifier)
          .assignToMe(_leadId!);
    }

    if (mounted) {
      setState(() {
        _isAIPaused = true;
        _isAITyping = true;
        _lastMessageCount =
            ref.read(liveChatProvider(widget.whatsappNumber)).value?.length ??
            0;
      });
      _scrollToBottom();
    }
    await ref
        .read(liveChatProvider(widget.whatsappNumber).notifier)
        .handoffToHuman();
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.whatsappNumber.isEmpty
        ? null
        : ref.watch(liveChatProvider(widget.whatsappNumber));

    final lockState = ref.watch(chatLockProvider(widget.whatsappNumber));
    final myId = ref.watch(authControllerProvider).valueOrNull?.account?.id;
    final isLockedByOther = lockState.isLocked && lockState.lawyerId != myId;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: StringUtils.formatFirstAndLastName(widget.clientName),
          showBackButton: true,
          backgroundColor: Colors.white,
          showDivider: false,
          actions: [
            if (_leadId != null)
              IconButton(
                icon: const Icon(
                  Icons.person_search_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Ficha do Lead',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (context, scrollController) => Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: LawyerLeadDetailScreen(
                          leadId: _leadId,
                          name: widget.clientName,
                          caseType: '',
                          urgency: '',
                          isModal: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (isLockedByOther)
                _buildOtherLawyerBanner(
                  lockState.lawyerName ?? 'Outro advogado',
                ),
              _buildLiveHeader(isLockedByOther),
              if (!_isAIPaused)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: AppColors.surface2,
                  child: const Text(
                    'Histórico do WhatsApp em modo somente leitura.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textCaption,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: history == null
                    ? const Center(child: Text('WhatsApp não informado.'))
                    : history.when(
                        data: (messages) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                          return _buildChatList(messages);
                        },
                        loading: _buildLoadingList,
                        error: (error, _) =>
                            Center(child: Text(error.toString())),
                      ),
              ),
              if (_isAIPaused && !isLockedByOther) _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherLawyerBanner(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          const Icon(Icons.lock_person_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Text(
            'Este chat está sendo atendido por: $name',
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeader(bool isLockedByOther) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isAIPaused ? AppColors.primary : AppColors.secondary)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isAIPaused ? Icons.bolt : Icons.smart_toy_outlined,
              color: _isAIPaused ? AppColors.primary : AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAIPaused
                      ? 'Atendimento Humano Ativo'
                      : 'Atendimento por IA Ativo',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isAIPaused
                      ? 'A IA está silenciada.'
                      : 'A IA está respondendo o cliente.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
          if (!isLockedByOther) ...[
            if (_isAIPaused)
              TextButton.icon(
                onPressed: _handleResumeAI,
                icon: const Icon(Icons.smart_toy_outlined, size: 18),
                label: const Text('Devolver p/ IA'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _handleStartHandoff,
                icon: const Icon(Icons.handshake_outlined, size: 18),
                label: const Text('Assumir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    if (_isAITyping && messages.length > _lastMessageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isAITyping = false);
      });
    }

    if (messages.isEmpty && !_isAITyping) {
      return const Center(child: Text('Nenhuma mensagem encontrada.'));
    }

    final itemCount = messages.length + (_isAITyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildTypingIndicator(context);
        }
        return _buildChatBubble(context, messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.secondaryOverlay,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondaryDark,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'THEMIS AI está digitando...',
              style: TextStyle(
                color: AppColors.secondaryDark,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildMessageInput() {
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
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
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
                onTap: _handleSendMessage,
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
              : (isBot ? AppColors.secondaryOverlay : AppColors.primary),
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
            if (isBot || isLawyer || isClient)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  isBot ? 'THEMIS AI' : (isLawyer ? 'ADVOGADO' : 'CLIENTE'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isLawyer
                        ? Colors.white
                        : (isBot
                              ? AppColors.secondaryDark
                              : AppColors.textCaption),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isLawyer ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    formatTime(message.createdAt),
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
          ],
        ),
      ),
    );
  }
}
