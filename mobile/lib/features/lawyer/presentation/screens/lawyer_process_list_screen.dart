import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerProcessListScreen extends StatefulWidget {
  const LawyerProcessListScreen({super.key});

  @override
  State<LawyerProcessListScreen> createState() => _LawyerProcessListScreenState();
}

class _LawyerProcessListScreenState extends State<LawyerProcessListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  final List<Map<String, dynamic>> _processes = [
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
        title: 'Gestão de Processos',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildProcessList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewProcessModal(context),
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
          hintText: 'Buscar por processo ou cliente...',
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

  Widget _buildProcessList() {
    final filtered = _processes.where((p) {
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
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        return _buildProcessCard(p);
      },
    );
  }

  Widget _buildProcessCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/lawyer-process-detail');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p['client'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusPill(p['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Proc: ${p['number']}',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.update_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p['lastUpdate'],
                      style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = AppColors.primary;
    if (status.contains('Aguardando')) color = AppColors.warning;
    if (status.contains('Sentença')) color = AppColors.success;
    if (status.contains('Audiência')) color = const Color(0xFF673AB7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showNewProcessModal(BuildContext context) {
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
            const Text('Novo Processo', style: AppTextStyles.h1),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Cliente')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Número do Processo')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Tipo/Nicho')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Cadastrar Processo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
