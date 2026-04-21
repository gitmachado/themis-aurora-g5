import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_procedure_card.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/constants/app_dimensions.dart';

class ClientProcedureListScreen extends StatefulWidget {
  const ClientProcedureListScreen({super.key});

  @override
  State<ClientProcedureListScreen> createState() => _ClientProcedureListScreenState();
}

class _ClientProcedureListScreenState extends State<ClientProcedureListScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Trâmites',
        showBackButton: false,
        actions: [AppAppBarActions(showChat: false, notificationCount: 2)],
        showDivider: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            child: _buildFilters(),
          ),
          Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
    final allProcedures = [
      {
        'icon': Icons.gavel_outlined,
        'title': 'Ação Indenizatória',
        'subtitle': 'Trâmite: 0001234-56.2026',
        'statusLabel': 'Em Análise',
        'statusType': BadgeType.warning,
        'lastUpdate': 'Aguardando arquivos',
        'progressPercentage': 30,
      },
      {
        'icon': Icons.people_outline,
        'title': 'Ação de Divórcio',
        'subtitle': 'Trâmite: 0005678-12.2025',
        'statusLabel': 'Concluído',
        'statusType': BadgeType.success,
        'lastUpdate': 'Trâmite Arquivado',
        'progressPercentage': 100,
      },
      {
        'icon': Icons.work_outline,
        'title': 'Reclamatória Trabalhista',
        'subtitle': 'Trâmite: 0009876-90.2024',
        'statusLabel': 'Andamento',
        'statusType': BadgeType.primary,
        'lastUpdate': 'Audiência marcada: 15/05',
        'progressPercentage': 65,
      },
      {
        'icon': Icons.home_work_outlined,
        'title': 'Usucapião Extrajudicial',
        'subtitle': 'Trâmite: 0012456-78.2024',
        'statusLabel': 'Pendente',
        'statusType': BadgeType.warning,
        'lastUpdate': 'Documentação incompleta',
        'progressPercentage': 15,
      },
    ];

    final filteredProcedures = allProcedures.where((proc) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Ativos') {
        return proc['statusLabel'] == 'Andamento' || proc['statusLabel'] == 'Em Análise';
      }
      if (_selectedFilter == 'Concluídos') {
        return proc['statusLabel'] == 'Concluído';
      }
      if (_selectedFilter == 'Pendentes') {
        return proc['statusLabel'] == 'Pendente' || proc['statusLabel'] == 'Em Análise';
      }
      return true;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, AppDimensions.bottomPadding(context)),
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final proc = filteredProcedures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppProcedureCard(
            icon: proc['icon'] as IconData,
            title: proc['title'] as String,
            subtitle: proc['subtitle'] as String,
            statusLabel: proc['statusLabel'] as String,
            statusType: proc['statusType'] as BadgeType,
            lastUpdate: proc['lastUpdate'] as String,
            progressPercentage: proc['progressPercentage'] as int,
            onTap: () => Navigator.pushNamed(context, '/procedure-timeline'),
          ),
        );
      },
    );
  }
}
