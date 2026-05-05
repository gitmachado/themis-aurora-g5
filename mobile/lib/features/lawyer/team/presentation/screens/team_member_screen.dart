import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../domain/entities/team_member.dart';
import '../providers/team_providers.dart';

class TeamMemberScreen extends ConsumerStatefulWidget {
  final String memberId;

  const TeamMemberScreen({super.key, required this.memberId});

  @override
  ConsumerState<TeamMemberScreen> createState() => _TeamMemberScreenState();
}

class _TeamMemberScreenState extends ConsumerState<TeamMemberScreen> {
  /// Permission keys currently being persisted, to disable just that toggle.
  final Set<String> _pendingPermissions = <String>{};
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    final memberAsync = ref.watch(teamMemberDetailProvider(widget.memberId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Perfil do Advogado',
        showBackButton: true,
        showDivider: false,
      ),
      body: memberAsync.when(
        data: (member) => _buildBody(member),
        loading: () => const _MemberSkeleton(),
        error: (error, _) => _MemberError(error: error),
      ),
    );
  }

  Widget _buildBody(TeamMember member) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, AppDimensions.bottomPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(member: member),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Estatísticas'),
          const SizedBox(height: 10),
          _StatsGrid(stats: member.stats),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Permissões'),
          const SizedBox(height: 10),
          _PermissionsCard(
            member: member,
            pendingKeys: _pendingPermissions,
            onToggle: (key, value) => _onTogglePermission(member, key, value),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Gerenciamento'),
          const SizedBox(height: 10),
          _DangerZone(
            isLoading: _isRemoving,
            onRemove: () => _confirmAndRemove(member),
          ),
        ],
      ),
    );
  }

  Future<void> _onTogglePermission(
    TeamMember member,
    String key,
    bool value,
  ) async {
    if (_pendingPermissions.contains(key)) return;

    final original = Map<String, bool>.from(member.permissions);
    final optimistic = Map<String, bool>.from(member.permissions)..[key] = value;

    setState(() => _pendingPermissions.add(key));

    // Optimistic update on the cached member.
    final notifier = ref.read(teamListProvider.notifier);
    notifier.replaceMember(member.copyWith(permissions: optimistic));

    try {
      final updated = await ref
          .read(updateTeamMemberPermissionsUseCaseProvider)
          .call(member.id, {key: value});
      updated.match(
        (failure) => throw failure,
        (saved) {
          notifier.replaceMember(saved);
          // Force the detail provider to refresh from server values.
          ref.invalidate(teamMemberDetailProvider(member.id));
        },
      );
    } catch (error) {
      // Revert.
      notifier.replaceMember(member.copyWith(permissions: original));
      ref.invalidate(teamMemberDetailProvider(member.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar permissão: $error')),
      );
    } finally {
      if (mounted) setState(() => _pendingPermissions.remove(key));
    }
  }

  Future<void> _confirmAndRemove(TeamMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover advogado'),
        content: Text(
          'Tem certeza que deseja remover ${member.name} da equipe? '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remover',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRemoving = true);
    try {
      final result = await ref
          .read(removeTeamMemberUseCaseProvider)
          .call(member.id);

      result.match(
        (failure) => throw failure,
        (_) {
          ref.read(teamListProvider.notifier).removeLocally(member.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.name} removido(a) da equipe.')),
          );
          Navigator.of(context).pop();
        },
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
  }
}

class _Header extends StatelessWidget {
  final TeamMember member;

  const _Header({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(member.name);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
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
                          fontSize: 20,
                          color: AppColors.ink,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (member.oabNumber != null && member.oabNumber!.isNotEmpty)
                      Text(
                        'OAB ${member.oabNumber}',
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaPill(
                  icon: Icons.calendar_month_rounded,
                  label: 'Entrou em',
                  value: _formatDate(member.joinedAt),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaPill(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Especialidade',
                  value: _specialtyLabel(member.specialty),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _specialtyLabel(String? value) {
    switch (value) {
      case 'Labor':
        return 'Trabalhista';
      case 'Civil':
        return 'Cível';
      case 'Family':
        return 'Família';
      case 'Criminal':
        return 'Criminal';
      case 'SocialSecurity':
        return 'Previdenciário';
      default:
        return '—';
    }
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaPill({
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
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.h2.copyWith(
          fontSize: 15.5,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final TeamMemberStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.folder_rounded,
                label: 'Processos ativos',
                value: '${stats.activeProcesses}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.task_alt_rounded,
                label: 'Concluídos',
                value: '${stats.completedProcesses}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Leads convertidos',
                value: '${stats.convertedLeads}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.history_rounded,
                label: 'Última atividade',
                value: stats.lastActivityAt == null
                    ? '—'
                    : _relativeFromNow(stats.lastActivityAt!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _relativeFromNow(DateTime date) {
    final delta = DateTime.now().difference(date);
    if (delta.inMinutes < 1) return 'agora';
    if (delta.inMinutes < 60) return '${delta.inMinutes} min';
    if (delta.inHours < 24) return '${delta.inHours} h';
    if (delta.inDays < 30) return '${delta.inDays} dias';
    final months = delta.inDays ~/ 30;
    if (months < 12) return '$months mês${months > 1 ? 'es' : ''}';
    final years = delta.inDays ~/ 365;
    return '$years ano${years > 1 ? 's' : ''}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.ink2),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  final TeamMember member;
  final Set<String> pendingKeys;
  final void Function(String key, bool value) onToggle;

  const _PermissionsCard({
    required this.member,
    required this.pendingKeys,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < TeamPermissionKeys.all.length; i++) ...[
            _PermissionTile(
              key: ValueKey(TeamPermissionKeys.all[i]),
              permissionKey: TeamPermissionKeys.all[i],
              value: member.permissions[TeamPermissionKeys.all[i]] ?? false,
              isLoading: pendingKeys.contains(TeamPermissionKeys.all[i]),
              onChanged: (v) => onToggle(TeamPermissionKeys.all[i], v),
            ),
            if (i < TeamPermissionKeys.all.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String permissionKey;
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _PermissionTile({
    super.key,
    required this.permissionKey,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TeamPermissionKeys.labelFor(permissionKey),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TeamPermissionKeys.descriptionFor(permissionKey),
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.ink,
            ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRemove;

  const _DangerZone({required this.isLoading, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remover advogado da equipe',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Não é possível remover advogados com processos ativos. Reatribua os casos antes.',
            style: AppTextStyles.caption.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onRemove,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                'Remover advogado',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberSkeleton extends StatelessWidget {
  const _MemberSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          LoadingSkeleton(height: 140, borderRadius: 20),
          SizedBox(height: 18),
          LoadingSkeleton(height: 88, borderRadius: 18),
          SizedBox(height: 18),
          LoadingSkeleton(height: 200, borderRadius: 20),
          SizedBox(height: 18),
          LoadingSkeleton(height: 120, borderRadius: 20),
        ],
      ),
    );
  }
}

class _MemberError extends StatelessWidget {
  final Object error;

  const _MemberError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
