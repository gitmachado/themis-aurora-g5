import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerProfileScreen extends StatelessWidget {
  const LawyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Seu Perfil Profissional',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfessionalHeader(),
            const SizedBox(height: 32),
            _buildProfileSection(context, 'Gestão do Escritório', [
              _ProfileMenuItem(Icons.business_rounded, 'Dados do Escritório', 'Configurações e Endereço'),
              _ProfileMenuItem(Icons.group_rounded, 'Minha Equipe', 'Gerenciar advogados e estagiários'),
              _ProfileMenuItem(Icons.account_balance_wallet_outlined, 'Financeiro', 'Honorários e Faturas'),
            ]),
            const SizedBox(height: 24),
            _buildProfileSection(context, 'Geral', [
              _ProfileMenuItem(Icons.notifications_none_rounded, 'Notificações', 'Configurar alertas'),
              _ProfileMenuItem(Icons.lock_outline_rounded, 'Segurança', 'Alterar senha e acesso'),
              _ProfileMenuItem(Icons.help_outline_rounded, 'Suporte Técnico', 'Falar com OmniConnect'),
            ]),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.secondaryLight,
              child: Icon(Icons.person, size: 50, color: AppColors.secondaryDark),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Dr. Rodrigo Machado',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'OAB/SP 123.456 • Machado Associados',
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, String title, List<_ProfileMenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.primary),
          ),
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
                    leading: Icon(item.icon, color: AppColors.textPrimary),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.divider),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Acessando ${item.title}...')),
                      );
                    },
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

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showLogoutDialog(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Sair da Conta Profissional',
        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta profissional?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _ProfileMenuItem(this.icon, this.title, this.subtitle);
}
