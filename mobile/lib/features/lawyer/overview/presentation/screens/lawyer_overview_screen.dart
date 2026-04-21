import 'package:flutter/material.dart';
import '../../../../../../app/routes/app_router.dart';
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


class LawyerOverviewScreen extends StatelessWidget {
  const LawyerOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = context.findAncestorStateOfType<LawyerMainLayoutState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
            const AppDashboardHeader(
              name: 'Dr. Rodrigo',
              subtitle: 'Escritório Machado & Associados',
              avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256&h=256&auto=format&fit=crop',
              notificationCount: 2,
              chatCount: 3,
              showChat: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _buildMetricsGrid(context),
                    const SizedBox(height: 24),
                    _buildHandoffsCard(context, layoutState),
                    const SizedBox(height: 24),
                    const NicheChart(),
                    const SizedBox(height: 24),
                      _buildSectionHeader('Últimos Leads', () => layoutState?.setIndex(1)),
                    const SizedBox(height: 16),
                    _buildLeadsList(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Arquivos Recentes', () => Navigator.pushNamed(context, AppRouter.lawyerFilesRoute)),
                    const SizedBox(height: 16),
                    _buildDocsList(context),
                    SizedBox(height: AppDimensions.bottomPadding(context)), // Dynamic space

                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final layoutState = context.findAncestorStateOfType<LawyerMainLayoutState>();

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Trâmites',
            value: '234',
            subtitle: 'Ativos',
            icon: Icons.folder_open_rounded,
            onTap: () => layoutState?.setIndex(2), // Trâmites Tab
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MetricCard(
            title: 'Leads Hoje',
            value: '12',
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.secondaryLight,
            onTap: () => layoutState?.setIndex(1), // Leads Tab
          ),
        ),
      ],
    );
  }


  Widget _buildHandoffsCard(BuildContext context, LawyerMainLayoutState? layoutState) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.lawyerChatsRoute),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0xFFFFF4E5),
        hasBorder: false,
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.secondaryLight, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 novos handoffs aguardando',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Clique para revisar os dados da IA',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryLight, size: 20),
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

  Widget _buildLeadsList(BuildContext context) {
    return Column(
      children: [
        AppListTile(
          title: 'Carla Menezes',
          subtitle: 'Trabalhista • há 2 min',
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Text('CM', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          trailing: const AppBadge(label: 'ALTA', type: BadgeType.error),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.lawyerLeadDetailRoute,
              arguments: {
                'name': 'Carla Menezes',
                'caseType': 'Trabalhista',
                'urgency': 'Alta',
              },
            );
          },
        ),
        const SizedBox(height: 12),
        AppListTile(
          title: 'Roberto Santos',
          subtitle: 'Cível • há 15 min',
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Text('RS', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          trailing: const AppBadge(label: 'MÉDIA', type: BadgeType.warning),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.lawyerLeadDetailRoute,
              arguments: {
                'name': 'Roberto Santos',
                'caseType': 'Cível',
                'urgency': 'Média',
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocsList(BuildContext context) {
    return Column(
      children: [
        AppListTile(
          title: 'Contrato de Honorários',
          subtitle: 'Aguardando assinatura • Mariana L.',
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
          ),
          onTap: () {
            Navigator.pushNamed(context, AppRouter.lawyerFilesRoute);
          },
        ),
      ],
    );
  }
}

