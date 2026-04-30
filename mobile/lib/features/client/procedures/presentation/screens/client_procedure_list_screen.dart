import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_procedure_card.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class ClientProcedureListScreen extends ConsumerStatefulWidget {
  const ClientProcedureListScreen({super.key});

  @override
  ConsumerState<ClientProcedureListScreen> createState() =>
      _ClientProcedureListScreenState();
}

class _ClientProcedureListScreenState
    extends ConsumerState<ClientProcedureListScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final procedures = ref.watch(myProceduresProvider);

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
          Container(color: AppColors.white, child: _buildFilters()),
          Container(height: 1, color: AppColors.divider.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Expanded(
            child: procedures.when(
              data: _buildList,
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
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

  Widget _buildList(List<LegalProcess> allProcedures) {
    final filteredProcedures = allProcedures.where((proc) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Ativos') {
        return proc.currentStatus == 'OPEN' ||
            proc.currentStatus == 'UNDER_ANALYSIS';
      }
      if (_selectedFilter == 'Concluídos') {
        return proc.currentStatus == 'COMPLETED' ||
            proc.currentStatus == 'ARCHIVED';
      }
      if (_selectedFilter == 'Pendentes') {
        return proc.currentStatus == 'AWAITING_DOCUMENT' ||
            proc.currentStatus == 'UNDER_ANALYSIS';
      }
      return true;
    }).toList();

    if (filteredProcedures.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppDimensions.bottomPadding(context),
      ),
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final proc = filteredProcedures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppProcedureCard(
            icon: proc.icon,
            title: proc.displayTitle,
            subtitle: proc.displaySubtitle,
            statusLabel: proc.displayStatus,
            statusType: proc.badgeType,
            lastUpdate:
                proc.lastNote ??
                'Atualizado ${formatRelativeDate(proc.updatedAt)}',
            progressPercentage: proc.progressPercentage,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.procedureTimelineRoute,
              arguments: {'processId': proc.id},
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 128, borderRadius: 12),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Nenhum tramite encontrado',
        style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
      ),
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
