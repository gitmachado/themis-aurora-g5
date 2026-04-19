import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';

class LawyerClientListScreen extends StatefulWidget {
  const LawyerClientListScreen({super.key});

  @override
  State<LawyerClientListScreen> createState() => _LawyerClientListScreenState();
}

class _LawyerClientListScreenState extends State<LawyerClientListScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Seus Clientes',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _buildClientList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou CPF...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textCaption),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Ativos', 'Novos', 'Arquivados'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClientList() {
    final clients = [
      {'name': 'Lucas Silva', 'status': 'Ativo', 'desc': 'Ação Indenizatória #9821'},
      {'name': 'Carla Menezes', 'status': 'Novo', 'desc': 'Dúvida Previdenciária'},
      {'name': 'Roberto Santos', 'status': 'Ativo', 'desc': 'Divórcio Consensual'},
      {'name': 'Mariana Lima', 'status': 'Arquivado', 'desc': 'Liminar Deferida - 2025'},
      {'name': 'João Pedro', 'status': 'Ativo', 'desc': 'Revisão Contratual'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final client = clients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(Map<String, String> client) {
    final status = client['status']!;
    final type = status == 'Novo' 
        ? BadgeType.success 
        : (status == 'Arquivado' ? BadgeType.neutral : BadgeType.primary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              client['name']![0],
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  client['desc']!,
                  style: AppTextStyles.caption.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          AppBadge(label: status.toUpperCase(), type: type),
        ],
      ),
    );
  }
}
