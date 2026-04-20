import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../widgets/lawyer_metric_card.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDashboardHeader(
                name: 'Dr. Rodrigo Machado',
                greeting: 'Bom dia,',
                notificationCount: 5,
                onProfileTap: () => Navigator.pushNamed(context, '/lawyer-profile'),
                onNotificationTap: () => Navigator.pushNamed(context, '/lawyer-notifications'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricsGrid(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Novos Leads', () {}),
                    const SizedBox(height: 16),
                    _buildLeadsList(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Tarefas Pendentes', () {}),
                    const SizedBox(height: 16),
                    _buildTaskList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          LawyerMetricCard(
            label: 'Processos Ativos',
            value: '42',
            icon: Icons.gavel_rounded,
            iconColor: Colors.blue,
          ),
          SizedBox(width: 16),
          LawyerMetricCard(
            label: 'Leads Hoje',
            value: '08',
            icon: Icons.person_add_rounded,
            iconColor: Colors.green,
          ),
          SizedBox(width: 16),
          LawyerMetricCard(
            label: 'Handoffs',
            value: '03',
            icon: Icons.handshake_rounded,
            iconColor: Colors.orange,
          ),
        ],
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
            style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsList() {
    return Column(
      children: [
        _buildLeadTile('Carla Menezes', 'Trabalhista', 'há 2 min', true),
        const SizedBox(height: 12),
        _buildLeadTile('Roberto Santos', 'Cível', 'há 15 min', false),
        const SizedBox(height: 12),
        _buildLeadTile('Mariana Lima', 'Família', 'há 1 hora', false),
      ],
    );
  }

  Widget _buildLeadTile(String name, String type, String time, bool isUrgente) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('$type • $time', style: AppTextStyles.caption),
              ],
            ),
          ),
          if (isUrgente)
            const AppBadge(label: 'URGENTE', type: BadgeType.error)
          else
            const AppBadge(label: 'NOVO', type: BadgeType.success),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildTaskItem('Protocolar petição - Processo #9821', true),
          const Divider(height: 24),
          _buildTaskItem('Analisar documentos de Lucas Silva', false),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, bool isUrgent) {
    return Row(
      children: [
        Icon(
          isUrgent ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: isUrgent ? AppColors.error : AppColors.success,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textCaption),
      ],
    );
  }
}
