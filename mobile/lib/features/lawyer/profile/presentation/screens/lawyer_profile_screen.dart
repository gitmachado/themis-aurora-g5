import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import 'lawyer_sub_settings_screen.dart';

class LawyerProfileScreen extends StatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Perfil',
        showBackButton: false,
        actions: [AppAppBarActions(chatCount: 3, notificationCount: 2)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Escritório',
              children: [
                _buildActionTile(
                  Icons.business_rounded,
                  'Dados do Escritório',
                  () => _navigateToSubSettings(
                    context,
                    'Dados do Escritório',
                    [
                      {'label': 'Razão Social', 'value': 'Machado & Associados LTDA', 'icon': Icons.info_outline},
                      {'label': 'CNPJ', 'value': '12.345.678/0001-99', 'icon': Icons.fingerprint},
                      {'label': 'Endereço', 'value': 'Av. Paulista, 1000 - SP', 'icon': Icons.location_on_outlined},
                    ],
                  ),
                ),
                _buildActionTile(
                  Icons.group_rounded,
                  'Minha Equipe',
                  () => _navigateToSubSettings(
                    context,
                    'Minha Equipe',
                    [
                      {'label': 'Dr. Rodrigo Machado', 'value': 'Sócio Administrador', 'icon': Icons.person, 'type': 'contact'},
                      {'label': 'Dra. Ana Silva', 'value': 'Advogada Sênior', 'icon': Icons.person_outline, 'type': 'contact'},
                      {'label': 'Lucas Oliveira', 'value': 'Estagiário', 'icon': Icons.school_outlined, 'type': 'contact'},
                    ],
                  ),
                ),
                _buildActionTile(
                  Icons.account_balance_wallet_rounded,
                  'Financeiro',
                  () => _navigateToSubSettings(
                    context,
                    'Financeiro',
                    [
                      {'label': 'Faturamento Mensal', 'value': r'R$ 45.000,00', 'icon': Icons.trending_up},
                      {'label': 'Honorários a Receber', 'value': r'R$ 12.500,00', 'icon': Icons.payments_outlined},
                      {'label': 'Contas Bancárias', 'value': 'Itaú / Santander', 'icon': Icons.account_balance},
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Inteligência Artificial',
              children: [
                _buildActionTile(
                  Icons.chat_bubble_outline_rounded,
                  'Mensagens e Handoffs',
                  () => Navigator.pushNamed(context, '/lawyer-chats'),
                ),
                _buildActionTile(
                  Icons.smart_toy_rounded,
                  'Gestão de IA (RAG)',
                  () => Navigator.pushNamed(context, '/lawyer-ai-manager'),
                ),
                _buildActionTile(Icons.history_edu_rounded, 'Logs do Bot', () {}),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Conta',
              children: [
                _buildActionTile(Icons.notifications_active_rounded, 'Preferências de Notificação', () {}),
                _buildActionTile(Icons.security_rounded, 'Segurança e Senha', () {}),
                _buildActionTile(
                  Icons.logout_rounded,
                  'Sair da Conta',
                  () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.bottomPadding(context)),

          ],
        ),
      ),
    );
  }

  void _navigateToSubSettings(BuildContext context, String title, List<Map<String, dynamic>> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LawyerSubSettingsScreen(title: title, items: items),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256&h=256&auto=format&fit=crop'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          const Text('Dr. Rodrigo Machado', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OAB/SP 123.456',
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

  Widget _buildSection({required String title, required List<Widget> children}) {
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

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textCaption),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textCaption)),
          ),
          TextButton(
            onPressed: () {
              // 1. Pop the dialog first
              Navigator.pop(context);
              
              // 2. Clear stack and navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
