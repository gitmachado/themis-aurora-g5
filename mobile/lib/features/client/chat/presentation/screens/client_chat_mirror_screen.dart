import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/chat/domain/entities/chat_message.dart';
import '../../../../../../features/lawyer/chat/presentation/providers/chat_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_assets.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/buttons/whatsapp_button.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../widgets/chat_bubble.dart';

class ClientChatMirrorScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const ClientChatMirrorScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<ClientChatMirrorScreen> createState() =>
      _ClientChatMirrorScreenState();
}

class _ClientChatMirrorScreenState
    extends ConsumerState<ClientChatMirrorScreen> {
  final ScrollController _scrollController = ScrollController();
  int _unreadCount = 0;
  bool _showScrollDownButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final isFarFromBottom = offset > 100;

    debugPrint('[ClientChat] Scroll Offset: $offset, IsFar: $isFarFromBottom');

    if (isFarFromBottom != _showScrollDownButton) {
      setState(() {
        _showScrollDownButton = isFarFromBottom;
      });
    }

    // Se o usuário chegar no rodapé manualmente, zeramos o contador
    if (offset < 50 && _unreadCount > 0) {
      setState(() {
        _unreadCount = 0;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Zeramos o contador imediatamente
      setState(() {
        _unreadCount = 0;
      });

      // Executamos a animação. Se estiver sendo chamado de um evento de UI (onTap),
      // o animateTo funciona direto. Se for de um rebuild, o addPostFrameCallback garante segurança.
      Future.microtask(() {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(currentAccountProvider);
    final whatsappNumber = accountAsync.valueOrNull?.whatsappNumber ?? '';

    // Escuta novas mensagens no topo do build para garantir reatividade constante
    if (whatsappNumber.isNotEmpty) {
      ref.listen<
        AsyncValue<List<ChatMessage>>
      >(liveChatProvider(whatsappNumber), (previous, next) {
        if (next is AsyncData<List<ChatMessage>>) {
          final currentMsgs = next.value;
          final prevMsgs = previous?.valueOrNull ?? [];

          debugPrint(
            '[ClientChat] New update! Prev: ${prevMsgs.length}, Current: ${currentMsgs.length}',
          );

          if (currentMsgs.length > prevMsgs.length) {
            final isFar =
                _scrollController.hasClients && _scrollController.offset > 100;

            debugPrint('[ClientChat] Message added! IsFar: $isFar');

            if (isFar) {
              setState(() {
                _unreadCount += (currentMsgs.length - prevMsgs.length);
              });
            } else {
              _scrollToBottom();
            }
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '',
        showBackButton: widget.showBackButton,
        showDivider: true,
        centerTitle: false,
        backgroundColor: AppColors.white,
        actions: null,
        titleWidget: Row(
          children: [
            // Avatar circular com logo Themis
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.yellowSoft,
                border: Border.all(color: AppColors.yellow, width: 1.5),
              ),
              child: Center(
                child: SvgPicture.asset(AppAssets.logo, width: 22, height: 22),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Themis',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'via WhatsApp',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
      body: accountAsync.when(
        data: (account) {
          if (account.whatsappNumber.isEmpty) {
            return _buildNoWhatsAppState();
          }

          final history = ref.watch(liveChatProvider(account.whatsappNumber));

          return Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    // Banner "Apenas leitura" sutil
                    _buildReadOnlyBanner(),
                    Expanded(
                      child: history.when(
                        data: (messages) {
                          return _buildMessageList(messages);
                        },
                        loading: _buildLoadingList,
                        error: (error, _) => _buildErrorState(error),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão Scroll to Bottom
              if (_showScrollDownButton)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _buildScrollToBottomButton(),
                ),
            ],
          );
        },
        loading: _buildLoadingList,
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        border: const Border(
          bottom: BorderSide(color: AppColors.yellow, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 13, color: AppColors.ink3),
          const SizedBox(width: 6),
          Text(
            'Histórico sincronizado · Apenas leitura',
            style: AppTextStyles.caption.copyWith(
              fontSize: 11.5,
              color: AppColors.ink3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    final reversedMessages = messages.reversed.toList();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final message = reversedMessages[index];
        final isClient = message.sender == 'CLIENT';

        return ChatBubble(
          message: message.content,
          time: formatTime(message.createdAt),
          sender: message.sender,
          isMe: isClient,
          isInverted: true,
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final isRight = index % 2 == 0;
        return Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: LoadingSkeleton(
            height: 52,
            borderRadius: 16,
            width: MediaQuery.of(context).size.width * (isRight ? 0.60 : 0.72),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sem mensagens ainda',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Quando você interagir com a Themis pelo WhatsApp, o histórico da conversa aparecerá aqui automaticamente.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textCaption,
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Card explicativo compacto
                  _buildHowItWorksCompact(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHowItWorksCompact() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.chat_bubble_outline_rounded,
            'Converse pelo WhatsApp',
            'Fale com a assistente Themis para dúvidas e status.',
            isFirst: true,
          ),
          Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.line),
          _buildInfoRow(
            Icons.sync_rounded,
            'Sincronização automática',
            'O histórico aparece aqui para sua referência.',
          ),
          Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.line),
          _buildInfoRow(
            Icons.lock_outline_rounded,
            'Somente consulta',
            'Para responder, use o WhatsApp diretamente.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String desc, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFirst ? AppColors.yellowSoft : AppColors.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isFirst ? AppColors.ink : AppColors.textCaption,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textCaption,
                    height: 1.4,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWhatsAppState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 34,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'WhatsApp não cadastrado',
              style: AppTextStyles.h2.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Para acessar o histórico, seu número de WhatsApp precisa estar vinculado à conta.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textCaption,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return GestureDetector(
      onTap: _scrollToBottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.ink,
              size: 28,
            ),
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -4,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Não foi possível carregar o histórico',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.line.withValues(alpha: 0.8)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: WhatsAppButton(
            label: 'Continuar no WhatsApp',
            onPressed: () => launchUrl(
              Uri.parse('https://wa.me/5584887922092'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ),
    );
  }
}
