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

class _LawyerClientListScreenState extends State<LawyerClientListScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  late AnimationController _listController;

  final List<Map<String, String>> _allClients = [
    {'name': 'Lucas Silva', 'status': 'Ativo', 'desc': 'Ação Indenizatória #9821'},
    {'name': 'Carla Menezes', 'status': 'Novo', 'desc': 'Dúvida Previdenciária'},
    {'name': 'Roberto Santos', 'status': 'Ativo', 'desc': 'Divórcio Consensual'},
    {'name': 'Mariana Lima', 'status': 'Arquivado', 'desc': 'Liminar Deferida - 2025'},
    {'name': 'João Pedro', 'status': 'Ativo', 'desc': 'Revisão Contratual'},
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredClients {
    return _allClients.where((client) {
      final matchesFilter = _selectedFilter == 'Todos' || client['status'] == _selectedFilter;
      final matchesSearch = client['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client['desc']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

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
        onPressed: () {
          _showAddClientSheet();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou descrição...',
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
              onSelected: (val) {
                setState(() => _selectedFilter = filter);
                _listController.reset();
                _listController.forward();
              },
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
    final clients = _filteredClients;
    
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: AppColors.textCaption.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Nenhum cliente encontrado', style: AppTextStyles.body.copyWith(color: AppColors.textCaption)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: clients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final client = clients[index];
        return FadeTransition(
          opacity: _listController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1 * (index + 1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _listController,
              curve: Curves.easeOutCubic,
            )),
            child: _buildClientCard(client),
          ),
        );
      },
    );
  }

  Widget _buildClientCard(Map<String, String> client) {
    final status = client['status']!;
    final type = status == 'Novo' 
        ? BadgeType.success 
        : (status == 'Arquivado' ? BadgeType.neutral : BadgeType.primary);

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abrindo detalhes de ${client['name']}...')),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
      ),
    );
  }

  void _showAddClientSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 32,
          left: 32,
          right: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Novo Cliente', style: AppTextStyles.h1),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'WhatsApp',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cadastrar Cliente', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
}
