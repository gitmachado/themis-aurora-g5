import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        // Explicit heroTag avoids the "multiple heroes share the same tag"
        // error when other screens in the lawyer flow also expose a FAB
        // (they all default to <default FloatingActionButton tag>).
        heroTag: 'lawyer_overview_ai_fab',
        onPressed: () =>
            Navigator.pushNamed(context, AppRouter.lawyerAIChatRoute),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.yellow,
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text(
          'Themis IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          AppDashboardHeader(
            name: account?.name ?? 'Advogado',
            subtitle: null,
            avatarUrl: account?.avatarUrl,
            notificationCount: notifications
                .where((notification) => !notification.isRead)
                .length,
            chatCount: handoffCount,
            showChat: true,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(pendingLeadsProvider);
                ref.invalidate(myProceduresProvider);
                ref.invalidate(myNotificationsProvider);
                ref.invalidate(myRecentDocumentsProvider);
                await Future.wait([
                  ref.read(pendingLeadsProvider.future),
                  ref.read(myProceduresProvider.future),
                  ref.read(myNotificationsProvider.future),
                  ref.read(myRecentDocumentsProvider.future),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      'Resumo de Hoje',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 28,
                        height: 0.92,
                      ),
                    ),
                    const SizedBox(height: 0),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(
                      context,
                      procedures.length,
                      leads.length,
                      handoffCount,
                      recentDocuments.length,
                    ),
                    const SizedBox(height: 14),
                    NicheChart(procedures: procedures),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Últimos Leads',
                      () => layoutState?.goToClientsHubPending(),
                    ),
                    const SizedBox(height: 16),
                    _buildLeadsList(context, leads.take(2).toList()),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: AppDimensions.bottomPadding(context),
                    ), // Dynamic space
                  ],
                ),
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
    int handoffCount,
    int docsToReview,
  ) {
    final layoutState = context
        .findAncestorStateOfType<LawyerMainLayoutState>();

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.48,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MetricCard(
          title: 'Casos ativos',
          value: '$procedureCount',
          icon: Icons.folder_open_rounded,
          backgroundColor: AppColors.ink,
          titleColor: AppColors.white.withValues(alpha: 0.74),
          valueColor: AppColors.white,
          hasBorder: false,
          onTap: () => layoutState?.setIndex(1),
        ),
        MetricCard(
          title: 'Leads pendentes',
          value: '$leadCount',
          icon: Icons.people_alt_rounded,
          onTap: () => layoutState?.goToClientsHubPending(),
        ),
        MetricCard(
          title: 'Handoff humano',
          value: '$handoffCount',
          icon: Icons.support_agent_rounded,
          iconColor: AppColors.secondaryLight,
          titleColor: AppColors.yellowDeep,
          onTap: () => Navigator.pushNamed(context, AppRouter.lawyerChatsRoute),
        ),
        MetricCard(
          title: 'Docs recentes',
          value: '$docsToReview',
          icon: Icons.description_outlined,
          onTap: () => Navigator.pushNamed(context, AppRouter.lawyerFilesRoute),
        ),
      ],
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
}
