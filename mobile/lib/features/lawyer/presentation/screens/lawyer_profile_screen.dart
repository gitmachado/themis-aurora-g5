import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
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
      appBar: const CustomAppBar(
        title: 'Meu Perfil',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildProfileSection(
              context,
              title: 'Escritório',
              items: [
                _ProfileItem(
                  icon: Icons.business_rounded,
                  label: 'Dados do Escritório',
                  onTap: () => _navigateToSubSettings(
                    context,
                    'Dados do Escritório',
                    [
                      {'label': 'Razão Social', 'value': 'Machado & Associados LTDA', 'icon': Icons.info_outline},
                      {'label': 'CNPJ', 'value': '12.345.678/0001-99', 'icon': Icons.fingerprint},
                      {'label': 'Endereço', 'value': 'Av. Paulista, 1000 - SP', 'icon': Icons.location_on_outlined},
                    ],
                  ),
                ),
                _ProfileItem(
                  icon: Icons.group_rounded,
                  label: 'Minha Equipe',
                  onTap: () => _navigateToSubSettings(
                    context,
                    'Minha Equipe',
                    [
                      {'label': 'Dr. Rodrigo Machado', 'value': 'Sócio Administrador', 'icon': Icons.person, 'type': 'contact'},
                      {'label': 'Dra. Ana Silva', 'value': 'Advogada Sênior', 'icon': Icons.person_outline, 'type': 'contact'},
                      {'label': 'Lucas Oliveira', 'value': 'Estagiário', 'icon': Icons.school_outlined, 'type': 'contact'},
                    ],
                  ),
                ),
                _ProfileItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Financeiro',
                  onTap: () => _navigateToSubSettings(
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
            const SizedBox(height: 24),
            _buildProfileSection(
              context,
              title: 'Inteligência Artificial',
              items: [
                _ProfileItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Mensagens e Handoffs',
                  onTap: () => Navigator.pushNamed(context, '/lawyer-chats'),
                ),
                _ProfileItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'Gestão de IA (RAG)',
                  onTap: () => Navigator.pushNamed(context, '/lawyer-ai-manager'),
                ),
                _ProfileItem(
                  icon: Icons.history_edu_rounded,
                  label: 'Logs do Bot',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileSection(
              context,
              title: 'Conta',
              items: [
                _ProfileItem(
                  icon: Icons.notifications_active_rounded,
                  label: 'Preferências de Notificação',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.security_rounded,
                  label: 'Segurança e Senha',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.logout_rounded,
                  label: 'Sair da Conta',
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

  void _navigateToSubSettings(BuildContext context, String title, List<Map<String, dynamic>> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LawyerSubSettingsScreen(title: title, items: items),
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
                child: Text('RM', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Dr. Rodrigo Machado', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text('OAB/SP 123.456', style: AppTextStyles.caption.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, {required String title, required List<_ProfileItem> items}) {
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
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textCaption),
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
  final VoidCallback onTap;
  final bool isDestructive;

  _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
