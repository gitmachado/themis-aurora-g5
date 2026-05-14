import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../features/lawyer/clients/domain/entities/lawyer_client.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../providers/chat_providers.dart';

class LawyerChatListScreen extends ConsumerWidget {
  const LawyerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(myLawyerClientsProvider);
    final allLeadsAsync = ref.watch(allLeadsProvider);
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];

    // Extract unread notification info for badges
    final unreadHandoffNumbers = notifications
        .where((n) => n.type == 'HUMAN_SUPPORT' && !n.isRead)
        .map((n) => n.extraData?['whatsappNumber']?.toString())
        .whereType<String>()
        .toSet();

    final unreadNotificationIds = notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toSet();

    // Extract all handoffs (read or unread) to ensure they are in the list
    final handoffs = notifications
        .where((n) => n.type == 'HUMAN_SUPPORT')
        .map(
          (n) => LawyerClient(
            id: n.extraData?['leadId']?.toString() ?? n.id,
            name: n.extraData?['clientName']?.toString() ?? n.title,
            whatsappNumber: n.extraData?['whatsappNumber']?.toString() ?? '',
            lastMessage: n.body,
            lastMessageAt: n.createdAt,
          ),
        )
        .toList();

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
          title: 'Mensagens',
          showBackButton: true,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.smart_toy_rounded, color: AppColors.ink),
              tooltip: 'Assistente Themis AI',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.lawyerAIChatRoute),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSummary(unreadHandoffNumbers.length),
            Expanded(
              child: clientsAsync.when(
                data: (clients) => allLeadsAsync.when(
                  data: (leads) {
                    // Merge and unique by whatsappNumber
                    final Map<String, LawyerClient> unified = {};

                    // 1. All Leads
                    for (var l in leads) {
                      if (l.whatsappNumber.isNotEmpty) {
                        unified[l.whatsappNumber] = LawyerClient(
                          id: l.id,
                          name: l.name ?? 'Lead sem nome',
                          whatsappNumber: l.whatsappNumber,
                        );
                      }
                    }

                    // 2. Clients
                    for (var c in clients) {
                      if (c.whatsappNumber.isNotEmpty) {
                        // Preserve existing lastMessage/At if it's from a lead or handoff
                        final existing = unified[c.whatsappNumber];
                        unified[c.whatsappNumber] = LawyerClient(
                          id: c.id,
                          name: c.name,
                          whatsappNumber: c.whatsappNumber,
                          cpf: c.cpf,
                          email: c.email,
                          lastMessage: existing?.lastMessage,
                          lastMessageAt: existing?.lastMessageAt,
                        );
                      }
                    }

                    // 3. Handoffs
                    for (var h in handoffs) {
                      // Se tem número, usa como chave única para mergear com leads/clients
                      if (h.whatsappNumber.isNotEmpty) {
                        unified[h.whatsappNumber] = h;
                      } else {
                        // Se não tem número (caso de teste ou erro), adiciona como entrada separada
                        // usando o ID da notificação como chave para não sumir da lista
                        unified['handoff-${h.id}'] = h;
                      }
                    }

                    final unifiedList = unified.values.toList();
                    // Sort by name for now
                    unifiedList.sort((a, b) => a.name.compareTo(b.name));

                    return _buildClientList(
                      context,
                      unifiedList,
                      unreadHandoffNumbers,
                      unreadNotificationIds,
                    );
                  },
                  loading: _buildLoadingList,
                  error: (error, _) => _buildErrorState(error),
                ),
                loading: _buildLoadingList,
                error: (error, _) => _buildErrorState(error),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).padding.bottom,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSummary(int handoffCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(36, 16, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            handoffCount > 0
                ? Icons.support_agent_rounded
                : Icons.chat_bubble_rounded,
            color: handoffCount > 0
                ? AppColors.warning
                : const Color(0xFF25D366), // WhatsApp Green
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            handoffCount > 0
                ? '$handoffCount handoff(s) nas notificações'
                : 'Conversas do WhatsApp',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(
    BuildContext context,
    List<LawyerClient> clients,
    Set<String> unreadNumbers,
    Set<String> unreadNotificationIds,
  ) {
    if (clients.isEmpty) {
      return Center(
        child: Text(
          'Nenhum cliente disponível para histórico.',
          style: AppTextStyles.body,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        final hasUnread =
            unreadNumbers.contains(client.whatsappNumber) ||
            unreadNotificationIds.contains(client.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnread ? AppColors.secondary : AppColors.divider,
              width: hasUnread ? 1.5 : 1.0,
            ),
            boxShadow: hasUnread
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryOverlay,
                  child: Text(
                    client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    StringUtils.formatFirstAndLastName(client.name),
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.w900 : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _ChatPreviewTime(whatsappNumber: client.whatsappNumber),
              ],
            ),
            subtitle: _ChatPreviewMessage(
              whatsappNumber: client.whatsappNumber,
              fallbackLastMessage: client.lastMessage,
              fallbackLastMessageAt: client.lastMessageAt,
              isBold: hasUnread,
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: hasUnread ? AppColors.secondaryDark : AppColors.ink2,
            ),
            onTap: client.whatsappNumber.isEmpty
                ? null
                : () => Navigator.pushNamed(
                    context,
                    AppRouter.lawyerChatHandoffRoute,
                    arguments: {
                      'clientName': client.name,
                      'whatsappNumber': client.whatsappNumber,
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LoadingSkeleton(height: 80, borderRadius: 12),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar mensagens', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPreviewTime extends ConsumerWidget {
  final String whatsappNumber;

  const _ChatPreviewTime({required this.whatsappNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (whatsappNumber.isEmpty) return const SizedBox.shrink();

    final history = ref.watch(chatHistoryProvider(whatsappNumber));

    return history.maybeWhen(
      data: (messages) {
        if (messages.isEmpty) return const SizedBox.shrink();
        final lastMessage = messages.last;
        return Text(
          formatTime(lastMessage.createdAt),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textCaption,
            fontSize: 11,
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ChatPreviewMessage extends ConsumerWidget {
  final String whatsappNumber;
  final String? fallbackLastMessage;
  final DateTime? fallbackLastMessageAt;
  final bool isBold;

  const _ChatPreviewMessage({
    required this.whatsappNumber,
    this.fallbackLastMessage,
    this.fallbackLastMessageAt,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          whatsappNumber.isEmpty ? 'WhatsApp nao informado' : whatsappNumber,
          style: AppTextStyles.caption.copyWith(
            color: isBold ? AppColors.secondaryDark : AppColors.textCaption,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        if (whatsappNumber.isNotEmpty)
          Consumer(
            builder: (context, ref, child) {
              final history = ref.watch(chatHistoryProvider(whatsappNumber));
              return history.maybeWhen(
                data: (messages) {
                  if (messages.isEmpty) {
                    // If no real messages, show fallback if it exists (handoff event)
                    if (fallbackLastMessage != null) {
                      return _buildMessageLine(fallbackLastMessage!);
                    }
                    return const SizedBox.shrink();
                  }
                  final lastMsg = messages.last;
                  return _buildMessageLine(lastMsg.content);
                },
                orElse: () => fallbackLastMessage != null
                    ? _buildMessageLine(fallbackLastMessage!)
                    : const SizedBox.shrink(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMessageLine(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: isBold ? AppColors.ink : AppColors.ink.withValues(alpha: 0.6),
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w700 : null,
        ),
      ),
    );
  }
}
