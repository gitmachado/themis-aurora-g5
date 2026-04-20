import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../shared/widgets/cards/labeled_field.dart';
import '../../../../shared/widgets/cards/document_file_card.dart';
import '../widgets/timeline_summary_card.dart';
import '../widgets/timeline_event_tile.dart';

class ClientProcessTimelineScreen extends StatelessWidget {
  const ClientProcessTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '0012345-67.2023.8.26',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Ação Trabalhista',
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• Atualizado há 15 min',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          title: '',
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textCaption),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'Resumo'),
              Tab(text: 'Documentos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTimelineTab(context),
            _buildResumoTab(context),
            _buildDocumentosTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  TimelineEventTile(
                    isFirst: true,
                    title: 'Petição Inicial Protocolada',
                    date: '05 Abr 2026 • 14:30',
                    description: 'Processo distribuído e aguardando primeira análise do juiz.',
                    responsible: 'Dr. Marcelo Costa',
                  ),
                  TimelineEventTile(
                    title: 'Audiência Marcada',
                    date: '12 May 2026 • 10:00',
                    description: 'Aguardando a realização da audiência de conciliação.',
                  ),
                  TimelineEventTile(
                    title: 'Aguardando Sentença',
                    date: '--',
                    description: '',
                  ),
                  TimelineEventTile(
                    isLast: true,
                    title: 'Sentença Proferida',
                    date: 'Previsão: Junho 2026',
                    description: '',
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildActionFooter(context),
      ],
    );
  }

  Widget _buildResumoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabeledField(
              label: 'DESCRIÇÃO DO CASO',
              value:
                  'O cliente foi demitido sem justa causa e não recebeu as verbas rescisórias. Alega também horas extras não pagas durante os últimos 2 anos em que desempenhou suas funções.',
              isDescription: true,
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LabeledField(
                  label: 'PARTES DO PROCESSO',
                  value: 'João Ricardo Mendes (Autor/Cliente)',
                  icon: Icons.person_outline,
                  iconColor: AppColors.primary,
                ),
                SizedBox(height: 12),
                LabeledField(
                  label: '',
                  value: 'Tecnologia Global S.A. (Réu)',
                  icon: Icons.shield_outlined,
                  iconColor: Color(0xFFEF4444),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: 'STATUS ATUAL',
              value: 'Em andamento',
              valueWidget: Row(
                children: const [
                  AppBadge(label: 'Em andamento', type: BadgeType.success),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const LabeledField(
              label: 'TRIBUNAL / VARA',
              value: '2ª Vara do Trabalho',
            ),
            const SizedBox(height: 16),
            const LabeledField(
              label: 'VALOR DA CAUSA',
              value: 'R\$ 50.000,00',
            ),
            const SizedBox(height: 16),
            const LabeledField(
              label: 'DATA DE DISTRIBUIÇÃO',
              value: '12/01/2024',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentosTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _buildFilterChip('Todos', isSelected: true),
              const SizedBox(width: 8),
              _buildFilterChip('Petições'),
              const SizedBox(width: 8),
              _buildFilterChip('Provas'),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: const [
              DocumentFileCard(
                category: 'PETIÇÃO',
                fileName: 'Petição Inicial.pdf',
                fileSize: '345 KB',
                dateAdded: '05 Apr',
              ),
              DocumentFileCard(
                category: 'PROCURAÇÃO',
                fileName: 'Procuração_Assinada.pdf',
                fileSize: '1.2 MB',
                dateAdded: '01 Apr',
              ),
              DocumentFileCard(
                category: 'PROVA',
                fileName: 'Foto_Local_Acidente.jpg',
                fileSize: '2.5 MB',
                dateAdded: 'ontem',
                icon: Icons.image_outlined,
                iconColor: Color(0xFFEA580C),
                iconBackgroundColor: Color(0xFFFFF7ED),
                actionIcon: Icons.visibility_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF666666),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: PrimaryButton(
        label: 'Dúvida? Falar no WhatsApp',
        icon: Icons.chat_bubble_outline_rounded,
        backgroundColor: AppColors.success,
        onPressed: () => Navigator.pushNamed(context, '/chat-mirror'),
      ),
    );
  }

  static void _handleAiAnalysis() {
    // TODO: implement AI analysis flow
  }
}
