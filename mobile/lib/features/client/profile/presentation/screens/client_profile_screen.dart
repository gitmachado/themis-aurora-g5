import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../../features/auth/domain/entities/account.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final cachedAccount = account.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Perfil',
        showBackButton: true,
        actions: [AppAppBarActions(showChat: false)],
      ),
      body: cachedAccount != null
          ? _buildContent(context, ref, cachedAccount)
          : account.when(
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
      key: const PageStorageKey<String>('client-profile-scroll'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildProfileHeader(context, ref, account),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Dados Pessoais',
            children: [
              _buildInfoTile(
                Icons.person_outline_rounded,
                account.name,
                'Nome Completo',
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
          _buildPreferenceSection(context, ref, account),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Conta',
            children: [
              _buildActionTile(
                Icons.logout_rounded,
                'Sair do Aplicativo',
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

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    final initial = account.name.isEmpty ? '?' : account.name[0].toUpperCase();
    final avatarUrl = account.avatarUrl;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 132,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.ink, AppColors.yellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  child: Tooltip(
                    message: 'Alterar foto',
                    child: GestureDetector(
                      onTap: () => _pickAndUploadAvatar(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.yellow,
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                  initial,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 96,
                  child: Transform.translate(
                    offset: const Offset(30, 0),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        padding: EdgeInsets.zero,
                        tooltip: 'Alterar foto',
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        onPressed: () => _pickAndUploadAvatar(context, ref),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.yellow,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(account.name, style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.yellowSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Conta de cliente',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.yellowDeep,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'heic', 'heif'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;

    try {
      await ref
          .read(accountActionsProvider)
          .uploadAvatar(filePath: file.path!, fileName: file.name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
          title: 'Atualizações de trâmite',
          value: preferences['processUpdates'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'processUpdates', value),
        ),
        _buildPreferenceTile(
          title: 'Arquivos e documentos',
          value: preferences['documents'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'documents', value),
        ),
        _buildPreferenceTile(
          title: 'Mensagens espelhadas',
          value: preferences['messages'] ?? true,
          onChanged: (value) =>
              _updatePreference(context, ref, account, 'messages', value),
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
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.ink, size: 20),
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
      activeThumbColor: AppColors.ink,
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
          color: isDestructive ? AppColors.errorBackground : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.ink,
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
    final optimisticAccount = Account(
      id: account.id,
      name: account.name,
      whatsappNumber: account.whatsappNumber,
      role: account.role,
      cpf: account.cpf,
      email: account.email,
      avatarUrl: account.avatarUrl,
      notificationPreferences: updated,
    );

    ref
        .read(authControllerProvider.notifier)
        .updateSessionAccount(optimisticAccount);

    try {
      await ref
          .read(accountActionsProvider)
          .updateNotificationPreferences(updated);
    } catch (error) {
      ref.read(authControllerProvider.notifier).updateSessionAccount(account);
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
