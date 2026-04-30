import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../shared/widgets/inputs/app_search_input.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/cards/app_list_tile.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/layout/app_bottom_nav_bar.dart';

class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Design System / UI Kit',
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Cores'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorBox('Primary', AppColors.primary),
                  _colorBox('Secondary L', AppColors.secondaryLight),
                  _colorBox('Secondary D', AppColors.secondaryDark),
                  _colorBox('Error', AppColors.error),
                  _colorBox('Success', AppColors.success),
                ],
              ),
              const SizedBox(height: 32),
              _sectionTitle('Tipografia'),
              const Text('H1 - Título Principal', style: AppTextStyles.h1),
              const Text('H2 - Subtítulo', style: AppTextStyles.h2),
              const Text('Corpo de texto regular', style: AppTextStyles.body),
              const Text(
                'Legenda / Caption light',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              _sectionTitle('Status Badges'),
              const Wrap(
                spacing: 8,
                children: [
                  AppBadge(label: 'Em Andamento', type: BadgeType.primary),
                  AppBadge(label: 'Concluído', type: BadgeType.success),
                  AppBadge(label: 'Urgente', type: BadgeType.error),
                  AppBadge(label: 'Pendente', type: BadgeType.warning),
                ],
              ),
              const SizedBox(height: 32),
              _sectionTitle('Inputs'),
              const AppSearchInput(hintText: 'Buscar processos...'),
              const SizedBox(height: 32),
              _sectionTitle('Botões'),
              PrimaryButton(label: 'Botão Primário', onPressed: () {}),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Botão com Ícone',
                icon: Icons.add,
                onPressed: () {},
              ),
              const SizedBox(height: 32),
              _sectionTitle('List Tiles'),
              AppListTile(
                title: 'Notificação de Prazo',
                subtitle: 'Seu prazo para contestação vence em 2 dias.',
                leading: const Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textCaption,
                ),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              AppListTile(
                title: 'Contrato Social.pdf',
                subtitle: '2.4 MB • PDF',
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.error,
                ),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _sectionTitle('Cards'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Título do Card', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    const Text(
                      'Utilizado para agrupar informações em blocos visuais limpos.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Espaço para a BottomBar
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _colorBox(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
