import 'package:flutter/material.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/cards/app_list_tile.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/niche_chart.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DashboardHeader(
              userName: 'Dr. Rodrigo',
              officeName: 'Escritório Machado & Associados',
              notificationCount: 2,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricsGrid(),
                    const SizedBox(height: 24),
                    _buildHandoffsCard(context),
                    const SizedBox(height: 24),
                    const NicheChart(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Últimos Leads', () {
                      // Navigate to Leads tab - placeholder
                    }),
                    const SizedBox(height: 16),
                    _buildLeadsList(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Documentos Recentes', () {}),
                    const SizedBox(height: 16),
                    _buildDocsList(context),
                    const SizedBox(height: 120), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return const Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Processos',
            value: '234',
            subtitle: 'Ativos',
            icon: Icons.folder_open_rounded,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: MetricCard(
            title: 'Leads Hoje',
            value: '12',
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildHandoffsCard(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abrindo fila de triagem IA...')),
        );
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0xFFFFF4E5),
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
          trailing: _buildBadge('URGENTE', AppColors.error),
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
          trailing: _buildBadge('NOVO', AppColors.success),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Abrindo visualizador de documentos...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
