import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerClientDetailScreen extends StatefulWidget {
  final String name;
  final String cpf;

  const LawyerClientDetailScreen({
    super.key,
    required this.name,
    required this.cpf,
  });

  @override
  State<LawyerClientDetailScreen> createState() => _LawyerClientDetailScreenState();
}

class _LawyerClientDetailScreenState extends State<LawyerClientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Ficha do Cliente',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildProcessHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            widget.name[0].toUpperCase(),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.name, style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('CPF: ${widget.cpf}', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleAction(Icons.phone_outlined, AppColors.primary, () {}),
            const SizedBox(width: 20),
            _buildCircleAction(Icons.chat_outlined, AppColors.success, () {}),
            const SizedBox(width: 20),
            _buildCircleAction(Icons.email_outlined, AppColors.warning, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildInfoCard() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informações de Contato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildDetailRow('Telefone', '(11) 98888-7777'),
            const Divider(height: 24),
            _buildDetailRow('E-mail', 'cliente.email@exemplo.com'),
            const Divider(height: 24),
            _buildDetailRow('Endereço', 'Rua das Flores, 123 - São Paulo/SP'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProcessHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Processos Vinculados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildProcessTile('1023456-88.2024.8.26.0100', 'Indenização por Dano Moral', 'Em andamento'),
        _buildProcessTile('0055443-12.2023.8.26.0100', 'Ação Revisional', 'Concluído'),
      ],
    );
  }

  Widget _buildProcessTile(String number, String type, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(number, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Concluído' ? AppColors.success.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Concluído' ? AppColors.success : AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => Navigator.pushNamed(context, '/lawyer-process-detail'),
      ),
    );
  }
}
