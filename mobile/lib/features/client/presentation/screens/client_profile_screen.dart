import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Meu Perfil',
        showBackButton: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildProfileSection(
              title: 'Dados Pessoais',
              items: [
                _ProfileItem(
                  icon: Icons.person_outline,
                  label: 'João Silva',
                  subtitle: 'Nome Completo',
                ),
                _ProfileItem(
                  icon: Icons.fingerprint_rounded,
                  label: '123.456.789-00',
                  subtitle: 'CPF',
                ),
                _ProfileItem(
                  icon: Icons.email_outlined,
                  label: 'joao.silva@email.com',
                  subtitle: 'E-mail',
                ),
                _ProfileItem(
                  icon: Icons.phone_android_rounded,
                  label: '(11) 99999-9999',
                  subtitle: 'WhatsApp',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileSection(
              title: 'Configurações',
              items: [
                _ProfileItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notificações',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Segurança e Senha',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileSection(
              title: 'Conta',
              items: [
                _ProfileItem(
                  icon: Icons.logout_rounded,
                  label: 'Sair do Aplicativo',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text('JS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('João Silva', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text('Cliente Premium', style: AppTextStyles.caption.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileSection({required String title, required List<_ProfileItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.primary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = items.indexOf(item) == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: item.isDestructive ? AppColors.error : AppColors.primary, size: 22),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: item.isDestructive ? AppColors.error : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: item.subtitle != null ? Text(item.subtitle!, style: AppTextStyles.caption.copyWith(fontSize: 11)) : null,
                    trailing: item.onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textCaption) : null,
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  _ProfileItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });
}
