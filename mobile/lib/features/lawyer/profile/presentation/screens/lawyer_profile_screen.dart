import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/auth/domain/entities/account.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerProfileScreen extends ConsumerWidget {
  const LawyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Perfil',
        showBackButton: true,
        actions: [AppAppBarActions()],
      ),
      body: account.when(
        data: (account) => _buildContent(context, ref, account),
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: LoadingSkeleton(height: 260, borderRadius: 16),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Account account) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildProfileHeader(account),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Dados da Conta',
            children: [
              _buildInfoTile(
                Icons.person_outline_rounded,
                account.name,
                'Nome',
              ),
              _buildInfoTile(
                Icons.fingerprint_rounded,
                account.cpf?.isNotEmpty == true
                    ? account.cpf!
                    : 'Nao informado',
                'CPF',
              ),
              _buildInfoTile(
                Icons.email_outlined,
                account.email?.isNotEmpty == true
                    ? account.email!
                    : 'Nao informado',
                'E-mail',
              ),
              _buildInfoTile(
                Icons.phone_android_rounded,
                account.whatsappNumber.isNotEmpty
                    ? account.whatsappNumber
                    : 'Nao informado',
                'WhatsApp',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Atendimento',
            children: [
              _buildActionTile(
                Icons.chat_bubble_outline_rounded,
                'Mensagens e Handoffs',
                () => Navigator.pushNamed(context, '/lawyer-chats'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPreferenceSection(context, ref, account),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Conta',
            children: [
              _buildActionTile(
                Icons.logout_rounded,
                'Sair da Conta',
                () => _showLogoutDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.bottomPadding(context)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Account account) {
    final initial = account.name.isEmpty ? '?' : account.name[0].toUpperCase();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Positioned(
                top: 40,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          Text(account.name, style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              account.email?.isNotEmpty == true
                  ? account.email!
                  : 'Conta de advogado',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    final preferences = account.notificationPreferences;

    return _buildSection(
      title: 'Notificações',
      children: [
        _buildPreferenceTile(
          title: 'Leads',
          value: preferences['leads'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'leads', value),
        ),
        _buildPreferenceTile(
          title: 'Trâmites',
          value: preferences['processUpdates'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'processUpdates', value),
        ),
        _buildPreferenceTile(
          title: 'Arquivos',
          value: preferences['documents'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'documents', value),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(fontSize: 11),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      activeThumbColor: AppColors.primary,
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error : AppColors.primary)
              .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textCaption,
      ),
      onTap: onTap,
    );
  }

  Future<void> _updatePreference(
    BuildContext context,
    WidgetRef ref,
    Account account,
    String key,
    bool value,
  ) async {
    final updated = Map<String, bool>.from(account.notificationPreferences)
      ..[key] = value;

    try {
      await ref
          .read(accountActionsProvider)
          .updateNotificationPreferences(updated);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Sair',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
