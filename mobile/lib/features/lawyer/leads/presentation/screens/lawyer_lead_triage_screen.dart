import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../widgets/lead_card.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';

class LawyerLeadTriageView extends ConsumerStatefulWidget {
  const LawyerLeadTriageView({super.key});

  @override
  ConsumerState<LawyerLeadTriageView> createState() =>
      _LawyerLeadTriageViewState();
}

class _LawyerLeadTriageViewState extends ConsumerState<LawyerLeadTriageView>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'Todos';
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool get _isArchivedTab => _selectedTabIndex == 1;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final leads = ref.watch(
      _isArchivedTab ? archivedLeadsProvider : pendingLeadsProvider,
    );

    return Column(
      children: [
        _buildSearchField(),
        _buildTabs(),
        _buildFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_isArchivedTab) {
                ref.invalidate(allLeadsProvider);
                await ref.read(allLeadsProvider.future);
              } else {
                await ref.read(pendingLeadsProvider.notifier).refresh();
              }
            },
            child: leads.when(
              data: (items) =>
                  _buildLeadsList(items, archived: _isArchivedTab),
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body.copyWith(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: 'Pesquisar por nome, WhatsApp ou caso',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.ink4,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textCaption),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar pesquisa',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: AppColors.surface2,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: DefaultTabController(
        length: 2,
        child: ThemisSegmentedControl(
          labels: const ['Novos', 'Arquivados'],
          selectedIndex: _selectedTabIndex,
          onChanged: (index) => setState(() => _selectedTabIndex = index),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Urgentes', 'Novos', 'Trabalhista', 'Cível'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              backgroundColor: AppColors.surface2,
              selectedColor: AppColors.yellow,
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.yellow : AppColors.border,
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
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.center,
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
                    : 'Nenhum lead pendente',
                style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pendingLeadsProvider);
        ref.invalidate(allLeadsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.yellow,
      child: ListView.separated(
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
            name: lead.shortName,
            caseType: lead.caseTypeLabel,
            time: lead.timeLabel,
            urgency: lead.urgencyLabel,
            status: lead.status,
            showArchiveAction: !archived && lead.status == 'PENDING',
            showChatAction: !archived,
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
            onAccept: () {
              Navigator.pushNamed(
                context,
                AppRouter.lawyerChatHandoffRoute,
                arguments: {
                  'clientName': lead.displayName,
                  'whatsappNumber': lead.whatsappNumber,
                },
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
      ),
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.center,
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
