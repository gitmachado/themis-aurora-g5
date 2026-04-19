import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/cards/app_list_tile.dart';
import '../../../../shared/widgets/layout/app_bottom_nav_bar.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildDadosPessoaisCard(),
            const SizedBox(height: 16),
            _buildSegurancaCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 60), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Text(
                    'JS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.white, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'João Silva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDadosPessoaisCard() {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dados Pessoais', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDataRow('Nome Completo', 'João Silva'),
            const SizedBox(height: 12),
            _buildDataRow('CPF', '123.456.789-00'),
            const SizedBox(height: 12),
            _buildDataRow('E-mail', 'joao.silva@email.com'),
            const SizedBox(height: 12),
            _buildDataRow('WhatsApp', '(11) 99999-9999'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSegurancaCard() {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Segurança', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.lock_outline, color: AppColors.textPrimary, size: 20),
                label: Text('Mudar Senha', style: AppTextStyles.body.copyWith(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE), // Light red
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: Text(
          'Sair do Aplicativo',
          style: AppTextStyles.body.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
