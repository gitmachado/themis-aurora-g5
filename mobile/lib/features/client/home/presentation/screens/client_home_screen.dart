import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../widgets/hero_update_card.dart';
import '../../../../../../shared/constants/app_dimensions.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final procedures = ref.watch(myProceduresProvider);
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final procedureList = procedures.valueOrNull ?? const [];
    final firstProcedure = procedureList.isEmpty ? null : procedureList.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppDashboardHeader(
            name: auth?.account?.name ?? 'Cliente',
            subtitle: 'Cliente',
            avatarUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=256&h=256&auto=format&fit=crop',
            notificationCount: unreadCount,
            onProfileTap: () => Navigator.pushNamed(context, '/profile'),
            onNotificationTap: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        HeroUpdateCard(
                          title:
                              firstProcedure?.lastNote ??
                              firstProcedure?.displayStatus ??
                              'Nenhum tramite ativo',
                          subtitle: firstProcedure == null
                              ? 'Quando houver atualizacoes, elas aparecerao aqui.'
                              : '${firstProcedure.displayTitle} • ${formatRelativeDate(firstProcedure.updatedAt)}',
                          onDetailsTap: firstProcedure == null
                              ? null
                              : () => Navigator.pushNamed(
                                  context,
                                  AppRouter.procedureTimelineRoute,
                                  arguments: {'processId': firstProcedure.id},
                                ),
                        ),
                        const SizedBox(height: 16),
                        _buildChatMirrorCard(context),
                        SizedBox(height: AppDimensions.bottomPadding(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMirrorCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/chat-mirror'),
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historico do WhatsApp',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Mensagens espelhadas em modo somente leitura',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }
}
