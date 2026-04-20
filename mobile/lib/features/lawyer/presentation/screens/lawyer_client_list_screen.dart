import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerClientListScreen extends StatefulWidget {
  const LawyerClientListScreen({super.key});

  @override
  State<LawyerClientListScreen> createState() => _LawyerClientListScreenState();
}

class _LawyerClientListScreenState extends State<LawyerClientListScreen> {
  final List<Map<String, String>> _clients = [
    {'name': 'João Silva', 'cpf': '123.456.789-00', 'phone': '(11) 98888-7777'},
    {'name': 'Maria Oliveira', 'cpf': '987.654.321-11', 'phone': '(11) 97777-6666'},
    {'name': 'Roberto Santos', 'cpf': '456.789.123-22', 'phone': '(11) 96666-5555'},
    {'name': 'Ana Costa', 'cpf': '321.654.987-33', 'phone': '(11) 95555-4444'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Meus Clientes',
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou CPF...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textCaption),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return _buildClientCard(client);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildClientCard(Map<String, String> client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            client['name']![0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        title: Text(client['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('CPF: ${client['cpf']}', style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(Icons.phone_rounded, AppColors.primary, () {}),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.chat_bubble_rounded, AppColors.success, () {}),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          '/lawyer-client-detail',
          arguments: {'name': client['name'], 'cpf': client['cpf']},
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
