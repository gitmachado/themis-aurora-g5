import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routes/app_router.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../domain/entities/team_member.dart';
import '../providers/team_providers.dart';

class TeamListScreen extends ConsumerWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Equipe',
        actions: [AppAppBarActions()],
        showDivider: false,
      ),
      body: teamAsync.when(
        data: (members) => _TeamListContent(members: members),
        loading: () => const _TeamListSkeleton(),
        error: (error, _) => _TeamListError(
          error: error,
          onRetry: () => ref.read(teamListProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.surface,
        onPressed: () =>
            Navigator.pushNamed(context, AppRouter.lawyerTeamAddRoute),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Adicionar advogado',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _TeamListContent extends ConsumerWidget {
  final List<TeamMember> members;

  const _TeamListContent({required this.members});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (members.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(teamListProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            const _TeamEmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(teamListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          AppDimensions.bottomPadding(context) + 80,
        ),
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _TeamMemberCard(member: members[index]);
        },
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(member.name);

    return AppCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.lawyerTeamMemberRoute,
        arguments: {'id': member.id},
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surface2,
                backgroundImage:
                    member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email ?? member.whatsappNumber,
                      style: AppTextStyles.caption.copyWith(fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _StatusBadge(isActive: member.isActive),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.folder_rounded,
                  label: 'Processos ativos',
                  value: '${member.stats.activeProcesses}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  icon: Icons.assignment_ind_rounded,
                  label: 'Leads atribuídos',
                  value: '${member.stats.assignedLeads}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.ink2),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.tiny.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textCaption,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.ink4;
    final bg = isActive ? AppColors.successBackground : AppColors.surface2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TeamEmptyState extends StatelessWidget {
  const _TeamEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.groups_2_rounded,
            size: 64,
            color: AppColors.textCaption.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum advogado na equipe ainda',
            style: AppTextStyles.h2.copyWith(
              fontSize: 18,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Convide advogados para colaborar no escritório. Você gerencia o que cada um pode fazer.',
            style: AppTextStyles.caption.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TeamListSkeleton extends StatelessWidget {
  const _TeamListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        AppDimensions.bottomPadding(context),
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 132, borderRadius: 20),
    );
  }
}

class _TeamListError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _TeamListError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            'Não foi possível carregar a equipe',
            style: AppTextStyles.h2.copyWith(
              fontSize: 17,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
