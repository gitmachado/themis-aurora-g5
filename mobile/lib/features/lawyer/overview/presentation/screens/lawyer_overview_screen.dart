import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/cards/app_list_tile.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/niche_chart.dart';
import '../../../../../../shared/widgets/layout/lawyer_main_layout.dart';
import '../../../../../../shared/constants/app_dimensions.dart';

class LawyerOverviewScreen extends ConsumerWidget {
  const LawyerOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = context
        .findAncestorStateOfType<LawyerMainLayoutState>();
    final account = ref.watch(authControllerProvider).valueOrNull?.account;
    final procedures = ref.watch(myProceduresProvider).valueOrNull ?? const [];
    final leads = ref.watch(pendingLeadsProvider).valueOrNull ?? const [];
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];
    final recentDocuments =
        ref.watch(myRecentDocumentsProvider).valueOrNull ?? const [];
    final handoffCount = notifications
        .where((notification) => notification.type == 'HUMAN_SUPPORT')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppDashboardHeader(
            name: account?.name ?? 'Advogado',
            subtitle: account?.email ?? 'Área do advogado',
            avatarUrl: account?.avatarUrl,
            notificationCount: notifications
                .where((notification) => !notification.isRead)
                .length,
            chatCount: handoffCount,
            showChat: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  _buildMetricsGrid(context, procedures.length, leads.length),
                  const SizedBox(height: 24),
                  _buildHandoffsCard(context, handoffCount),
                  const SizedBox(height: 24),
                  NicheChart(procedures: procedures),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Últimos Leads',
                    () => layoutState?.setIndex(1),
                  ),
                  const SizedBox(height: 16),
                  _buildLeadsList(context, leads.take(2).toList()),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Arquivos Recentes',
                    () => Navigator.pushNamed(
                      context,
                      AppRouter.lawyerFilesRoute,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocsList(context, recentDocuments),
                  SizedBox(
                    height: AppDimensions.bottomPadding(context),
                  ), // Dynamic space
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    int procedureCount,
    int leadCount,
  ) {
    final layoutState = context
        .findAncestorStateOfType<LawyerMainLayoutState>();

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Trâmites',
            value: '$procedureCount',
            subtitle: 'Ativos',
            icon: Icons.folder_open_rounded,
            onTap: () => layoutState?.setIndex(2), // Trâmites Tab
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MetricCard(
            title: 'Leads Hoje',
            value: '$leadCount',
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.secondaryLight,
            onTap: () => layoutState?.setIndex(1), // Leads Tab
          ),
        ),
      ],
    );
  }

  Widget _buildHandoffsCard(BuildContext context, int handoffCount) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.lawyerChatsRoute),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0xFFFFF4E5),
        hasBorder: false,
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.secondaryLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    handoffCount == 1
                        ? '1 handoff aguardando'
                        : '$handoffCount handoffs aguardando',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    handoffCount > 0
                        ? 'Clique para revisar o histórico'
                        : 'Nenhum handoff pendente no momento',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'Ver todos',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsList(BuildContext context, List<Lead> leads) {
    if (leads.isEmpty) {
      return AppCard(
        child: Text('Nenhum lead pendente', style: AppTextStyles.caption),
      );
    }

    return Column(
      children: [
        for (final lead in leads) ...[
          AppListTile(
            title: lead.displayName,
            subtitle: '${lead.caseTypeLabel} • ${lead.timeLabel}',
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                lead.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: AppBadge(
              label: lead.urgencyLabel.toUpperCase(),
              type: lead.urgencyLabel == 'Alta'
                  ? BadgeType.error
                  : BadgeType.warning,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.lawyerLeadDetailRoute,
                arguments: {
                  'id': lead.id,
                  'name': lead.displayName,
                  'caseType': lead.caseTypeLabel,
                  'urgency': lead.urgencyLabel,
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildDocsList(BuildContext context, List<ProcessDocument> documents) {
    if (documents.isEmpty) {
      return AppCard(
        child: Text('Nenhum arquivo recente', style: AppTextStyles.caption),
      );
    }

    return Column(
      children: [
        for (final document in documents.take(3)) ...[
          AppListTile(
            title: document.fileName,
            subtitle:
                '${formatFileSize(document.sizeBytes)} • ${formatDateLabel(document.createdAt)}',
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.lawyerFilesRoute);
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
