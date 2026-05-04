import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_procedure_card.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerProcedureListScreen extends ConsumerStatefulWidget {
  const LawyerProcedureListScreen({super.key});

  @override
  ConsumerState<LawyerProcedureListScreen> createState() =>
      _LawyerProcedureListScreenState();
}

class _LawyerProcedureListScreenState
    extends ConsumerState<LawyerProcedureListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final procedures = ref.watch(myProceduresProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Processos',
        actions: [AppAppBarActions()],
        showDivider: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            child: Column(children: [_buildSearchBar(), _buildFilters()]),
          ),
          Expanded(
            child: procedures.when(
              data: _buildProcedureList,
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: AppTextStyles.body.copyWith(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por trâmite ou cliente...',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.ink4,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textCaption,
          ),
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = f),
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
                  color: isSelected ? AppColors.yellow : AppColors.divider,
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

  Widget _buildProcedureList(List<LegalProcess> procedures) {
    final filtered = procedures.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          p.title.toLowerCase().contains(query) ||
          (p.processNumber ?? '').contains(_searchQuery) ||
          p.clientId.toLowerCase().contains(query);
      if (!matchesSearch) return false;
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Andamento') {
        return p.currentStatus == 'OPEN' || p.currentStatus == 'UNDER_ANALYSIS';
      }
      if (_selectedFilter == 'Sentença') return p.currentStatus == 'COMPLETED';
      if (_selectedFilter == 'Audiência') {
        return p.lastNote?.toLowerCase().contains('audiencia') ?? false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Nenhum processo encontrado',
          style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppDimensions.bottomPadding(context),
      ),

      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppProcedureCard(
            title: p.title,
            subtitle: p.processNumber == null
                ? 'Cliente: ${p.clientId}'
                : 'Proc: ${p.processNumber}',
            statusLabel: p.displayStatus,
            statusType: p.badgeType,
            lastUpdate:
                p.lastNote ?? 'Atualizado ${formatRelativeDate(p.updatedAt)}',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/lawyer-procedure-detail',
                arguments: {'processId': p.id},
              );
            },
          ),
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
          const LoadingSkeleton(height: 118, borderRadius: 12),
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
