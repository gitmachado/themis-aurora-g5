import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/lawyer_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_procedure_card.dart';

class LawyerProcedureListScreen extends StatefulWidget {
  const LawyerProcedureListScreen({super.key});

  @override
  State<LawyerProcedureListScreen> createState() => _LawyerProcedureListScreenState();
}

class _LawyerProcedureListScreenState extends State<LawyerProcedureListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  final List<Map<String, dynamic>> _procedures = [
    {
      'number': '1023456-88.2023.8.26.0100',
      'client': 'João Silva',
      'type': 'Trabalhista',
      'status': 'Em Andamento',
      'lastUpdate': 'Petição protocolada há 2 dias',
    },
    {
      'number': '0054321-12.2024.8.26.0000',
      'client': 'Maria Oliveira',
      'type': 'Cível',
      'status': 'Aguardando Documentos',
      'lastUpdate': 'Solicitado comprovante de residência',
    },
    {
      'number': '5067890-44.2022.4.03.6100',
      'client': 'Carlos Souza',
      'type': 'Previdenciário',
      'status': 'Concluso para Sentença',
      'lastUpdate': 'Aguardando decisão do juiz',
    },
    {
      'number': '1088776-55.2023.8.26.0100',
      'client': 'Ana Paula',
      'type': 'Consumidor',
      'status': 'Audiência Designada',
      'lastUpdate': 'Audiência em 15/05 às 14:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Gestão de Trâmites',
        actions: [LawyerAppBarActions()],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildProcedureList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'lawyer_procedure_fab',
        onPressed: () => _showNewProcedureModal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Buscar por trâmite ou cliente...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textCaption),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Andamento', 'Sentença', 'Audiência'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  Widget _buildProcedureList() {
    final filtered = _procedures.where((p) {
      final matchesSearch = p['client'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['number'].contains(_searchQuery);
      if (!matchesSearch) return false;
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Andamento') return p['status'].contains('Andamento');
      if (_selectedFilter == 'Sentença') return p['status'].contains('Sentença');
      if (_selectedFilter == 'Audiência') return p['status'].contains('Audiência');
      return true;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 20, 20, AppDimensions.bottomPadding(context)),



      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppProcedureCard(
            title: p['client'],
            subtitle: 'Proc: ${p['number']}',
            statusLabel: p['status'],
            statusType: _getStatusType(p['status']),
            lastUpdate: p['lastUpdate'],
            onTap: () {
              Navigator.pushNamed(context, '/lawyer-procedure-detail');
            },
          ),
        );
      },
    );
  }

  BadgeType _getStatusType(String status) {
    if (status.contains('Aguardando')) return BadgeType.warning;
    if (status.contains('Sentença')) return BadgeType.success;
    if (status.contains('Audiência')) return BadgeType.primary;
    return BadgeType.primary;
  }


  void _showNewProcedureModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Novo Trâmite', style: AppTextStyles.h1),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Cliente')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Número do Trâmite')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Tipo/Nicho')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Cadastrar Trâmite', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

