import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_process_card.dart';

class ClientProcessListScreen extends StatefulWidget {
  const ClientProcessListScreen({super.key});

  @override
  State<ClientProcessListScreen> createState() => _ClientProcessListScreenState();
}

class _ClientProcessListScreenState extends State<ClientProcessListScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Meus Processos',
        showBackButton: false,
        showNotificationButton: true,
        notificationCount: 2,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Ativos', 'Concluídos', 'Pendentes'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = f),
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        AppProcessCard(
          icon: Icons.gavel_outlined,
          title: 'Ação Indenizatória',
          subtitle: 'Proc: 0001234-56.2026',
          statusLabel: 'Em Análise',
          statusType: BadgeType.warning,
          lastUpdate: 'Aguardando documentação',
          progressPercentage: 30,
          onTap: () => Navigator.pushNamed(context, '/process-timeline'),
        ),
        const SizedBox(height: 16),
        AppProcessCard(
          icon: Icons.people_outline,
          title: 'Ação de Divórcio',
          subtitle: 'Proc: 0005678-12.2025',
          statusLabel: 'Concluído',
          statusType: BadgeType.success,
          lastUpdate: 'Processo Arquivado',
          progressPercentage: 100,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        AppProcessCard(
          icon: Icons.work_outline,
          title: 'Reclamatória Trabalhista',
          subtitle: 'Proc: 0009876-90.2024',
          statusLabel: 'Andamento',
          statusType: BadgeType.primary,
          lastUpdate: 'Audiência marcada: 15/05',
          progressPercentage: 65,
          onTap: () {},
        ),
      ],
    );
  }
}

