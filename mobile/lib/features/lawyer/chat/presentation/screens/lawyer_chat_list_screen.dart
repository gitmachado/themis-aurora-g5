import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/clients/domain/entities/lawyer_client.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerChatListScreen extends ConsumerWidget {
  const LawyerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(myLawyerClientsProvider);
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];
    final handoffCount = notifications
        .where((notification) => notification.type == 'HUMAN_SUPPORT')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Mensagens e Handoffs',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSummary(handoffCount),
          Expanded(
            child: clients.when(
              data: (items) => _buildClientList(context, items),
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
    );
  }

  Widget _buildSummary(int handoffCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: handoffCount > 0 ? AppColors.warningOverlay : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: handoffCount > 0 ? AppColors.warning : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            handoffCount > 0
                ? Icons.support_agent_rounded
                : Icons.chat_bubble_outline_rounded,
            color: handoffCount > 0 ? AppColors.warning : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              handoffCount > 0
                  ? '$handoffCount handoff(s) nas notificações'
                  : 'Histórico por WhatsApp dos clientes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(BuildContext context, List<LawyerClient> clients) {
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
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
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
            title: Text(
              client.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              client.whatsappNumber.isEmpty
                  ? 'WhatsApp nao informado'
                  : client.whatsappNumber,
              style: AppTextStyles.caption,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 82, borderRadius: 16),
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
