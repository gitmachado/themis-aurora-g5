import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../widgets/lead_card.dart';

class LawyerLeadTriageScreen extends StatefulWidget {
  const LawyerLeadTriageScreen({super.key});

  @override
  State<LawyerLeadTriageScreen> createState() => _LawyerLeadTriageScreenState();
}

class _LawyerLeadTriageScreenState extends State<LawyerLeadTriageScreen> {
  String _selectedFilter = 'Todos';

  final List<Map<String, String>> _leads = [
    {
      'name': 'Carla Menezes',
      'caseType': 'Trabalhista',
      'time': 'há 2 min',
      'urgency': 'Alta',
    },
    {
      'name': 'Roberto Santos',
      'caseType': 'Cível',
      'time': 'há 15 min',
      'urgency': 'Média',
    },
    {
      'name': 'Mariana Lima',
      'caseType': 'Família',
      'time': 'há 1 hora',
      'urgency': 'Baixa',
    },
    {
      'name': 'João Pedro',
      'caseType': 'Previdenciário',
      'time': 'há 3 horas',
      'urgency': 'Alta',
    },
    {
      'name': 'Ana Paula',
      'caseType': 'Consumidor',
      'time': 'há 5 horas',
      'urgency': 'Média',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Triagem de Leads',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildLeadsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Urgentes', 'Novos', 'Trabalhista', 'Cível'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                fontSize: 13,
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

  Widget _buildLeadsList() {
    // Basic filtering logic for demo purposes
    final filteredLeads = _leads.where((lead) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Urgentes') return lead['urgency'] == 'Alta';
      if (_selectedFilter == 'Novos') return lead['time']!.contains('min');
      return lead['caseType'] == _selectedFilter;
    }).toList();

    if (filteredLeads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: AppColors.textCaption.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Nenhum lead encontrado',
              style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: filteredLeads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lead = filteredLeads[index];
        return LeadCard(
          name: lead['name']!,
          caseType: lead['caseType']!,
          time: lead['time']!,
          urgency: lead['urgency']!,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.lawyerLeadDetailRoute,
              arguments: {
                'name': lead['name']!,
                'caseType': lead['caseType']!,
                'urgency': lead['urgency']!,
              },
            );
          },
          onAccept: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lead ${lead['name']} aceito!')),
            );
          },
          onArchive: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lead ${lead['name']} arquivado.')),
            );
          },
        );
      },
    );
  }
}
