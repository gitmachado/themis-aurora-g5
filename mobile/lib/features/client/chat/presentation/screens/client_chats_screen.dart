import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/chat/presentation/providers/chat_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../widgets/chat_list_tile.dart';

class ClientChatsScreen extends ConsumerWidget {
  const ClientChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Chat',
        showBackButton: false,
        actions: [AppAppBarActions(showChat: false)],
      ),
      body: account.when(
        data: (account) {
          if (account.whatsappNumber.isEmpty) {
            return _buildEmptyState('WhatsApp nao cadastrado na conta.');
          }

          final history = ref.watch(
            chatHistoryProvider(account.whatsappNumber),
          );
          return history.when(
            data: (messages) {
              if (messages.isEmpty) {
                return _buildEmptyState('Nenhuma mensagem sincronizada ainda.');
              }

              final last = messages.last;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.spacingL,
                  AppDimensions.spacingL,
                  AppDimensions.spacingL,
                  AppDimensions.bottomPadding(context),
                ),
                children: [
                  ChatListTile(
                    title: 'Histórico do WhatsApp',
                    subtitle: last.content,
                    time: formatRelativeDate(last.createdAt),
                    unreadCount: 0,
                    isAi: false,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.chatMirrorRoute),
                  ),
                ],
              );
            },
            loading: _buildLoadingList,
            error: (error, _) => _buildErrorState(error),
          );
        },
        loading: _buildLoadingList,
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 84, borderRadius: 16),
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
