import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../widgets/lead_card.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerLeadTriageScreen extends ConsumerStatefulWidget {
  const LawyerLeadTriageScreen({super.key});

  @override
  ConsumerState<LawyerLeadTriageScreen> createState() =>
      _LawyerLeadTriageScreenState();
}

class _LawyerLeadTriageScreenState
    extends ConsumerState<LawyerLeadTriageScreen> {
  String _selectedFilter = 'Todos';
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool get _isArchivedTab => _selectedTabIndex == 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(
      _isArchivedTab ? archivedLeadsProvider : pendingLeadsProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Leads',
        actions: [AppAppBarActions()],
        showDivider: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              children: [_buildSearchField(), _buildTabs(), _buildFilters()],
            ),
          ),
          Container(height: 1, color: AppColors.divider.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Expanded(
            child: leads.when(
              data: (items) => _buildLeadsList(items, archived: _isArchivedTab),
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Pesquisar por nome, WhatsApp ou caso',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar pesquisa',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: _searchController.clear,
                ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTabIndex,
      child: TabBar(
        onTap: (index) => setState(() => _selectedTabIndex = index),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textCaption,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Ativos'),
          Tab(text: 'Arquivados'),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Urgentes', 'Novos', 'Trabalhista', 'Cível'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
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

  Widget _buildLeadsList(List<Lead> leads, {required bool archived}) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredLeads = leads.where((lead) {
      final matchesFilter = switch (_selectedFilter) {
        'Todos' => true,
        'Urgentes' => lead.urgencyLabel == 'Alta',
        'Novos' => lead.timeLabel.contains('min'),
        _ => lead.caseTypeLabel == _selectedFilter,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      final searchable = [
        lead.displayName,
        lead.whatsappNumber,
        lead.caseTypeLabel,
        lead.caseDescription ?? '',
        lead.urgencyLabel,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();

    if (filteredLeads.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                archived
                    ? Icons.inventory_2_outlined
                    : Icons.person_search_rounded,
                size: 64,
                color: AppColors.textCaption.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                archived
                    ? 'Nenhum lead arquivado encontrado'
                    : 'Nenhum lead encontrado',
                style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppDimensions.bottomPadding(context),
      ),
      itemCount: filteredLeads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lead = filteredLeads[index];
        return LeadCard(
          name: lead.displayName,
          caseType: lead.caseTypeLabel,
          time: lead.timeLabel,
          urgency: lead.urgencyLabel,
          showArchiveAction: !archived,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.lawyerLeadDetailRoute,
              arguments: {
                'id': lead.id,
                'name': lead.displayName,
                'caseType': lead.caseTypeLabel,
                'urgency': lead.urgencyLabel,
              },
            );
          },
          onAccept: () async {
            await ref.read(leadActionsProvider).convert(lead.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lead ${lead.displayName} convertido em cliente.',
                ),
              ),
            );
          },
          onArchive: () async {
            await ref
                .read(leadActionsProvider)
                .discard(lead.id, reason: 'Arquivado no app mobile');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lead ${lead.displayName} arquivado.')),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppDimensions.bottomPadding(context),
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 132, borderRadius: 16),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
