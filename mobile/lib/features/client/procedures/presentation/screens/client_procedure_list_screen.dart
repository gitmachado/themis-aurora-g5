import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/domain/entities/account.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
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
    final account = ref.watch(currentAccountProvider);
    final procedures = ref.watch(myProceduresProvider);
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Processos',
        showBackButton: false,
        actions: [
          AppAppBarActions(showChat: false, notificationCount: unreadCount),
        ],
        showDivider: false,
      ),
      body: Column(
        children: [
          Container(color: AppColors.background, child: _buildFilters()),
          const SizedBox(height: 16),
          Expanded(
            child: account.when(
              data: (account) => procedures.when(
                data: (items) => _buildList(_onlyCurrentClient(items, account)),
                loading: _buildLoadingList,
                error: (error, _) => _buildErrorState(error),
              ),
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
              backgroundColor: AppColors.surface2,
              selectedColor: AppColors.yellow,
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
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

  List<LegalProcess> _onlyCurrentClient(
    List<LegalProcess> procedures,
    Account account,
  ) {
    if (account.role != UserRole.client) return procedures;
    return procedures
        .where((process) => process.clientId == account.id)
        .toList();
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
        'Nenhum processo encontrado',
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
