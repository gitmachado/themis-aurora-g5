import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/labeled_field.dart';
import '../../../../../../shared/widgets/cards/file_card.dart';
import '../widgets/timeline_summary_card.dart';
import '../widgets/timeline_event_tile.dart';

class ClientProcedureTimelineScreen extends StatefulWidget {
  const ClientProcedureTimelineScreen({super.key});

  @override
  State<ClientProcedureTimelineScreen> createState() => _ClientProcedureTimelineScreenState();
}

class _ClientProcedureTimelineScreenState extends State<ClientProcedureTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          showBackButton: true,
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
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'IA Resumo'),
              Tab(text: 'Arquivos'),
              Tab(text: 'Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTimelineTab(),
            _buildAiResumoTab(),
            _buildFilesTab(),
            _buildChatTab(),
          ],
        ),
        bottomNavigationBar: _buildActionFooter(context),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            TimelineEventTile(
              isFirst: true,
              title: 'Petição Inicial Protocolada',
              date: '05 Abr 2026 • 14:30',
              description: 'Trâmite distribuído e aguardando primeira análise do juiz.',
              responsible: 'Dr. Marcelo Costa',
            ),
            TimelineEventTile(
              title: 'Audiência Marcada',
              date: '12 May 2026 • 10:00',
              description: 'Aguardando a realização da audiência de conciliação.',
              responsible: 'Dr. Rodrigo Machado',
            ),
            TimelineEventTile(
              title: 'Aguardando Sentença',
              date: '--',
              description: 'O trâmite está em fase de conclusão para o juiz.',
            ),
            TimelineEventTile(
              isLast: true,
              title: 'Sentença Proferida',
              date: 'Previsão: Junho 2026',
              description: 'Previsão estimada baseada na média do tribunal.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiResumoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TimelineSummaryCard(
            status: 'Em Análise',
            lastMovement: '08/04/2026',
            onAiAnalysisTap: () {},
            onChatMirrorTap: () => DefaultTabController.of(context).animateTo(3),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledField(
                      label: 'PARTES DO TRÂMITE',
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
                  valueWidget: const Row(
                    children: [
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
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
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
              AppFileCard(
                category: 'PETIÇÃO',
                fileName: 'Petição Inicial.pdf',
                fileSize: '345 KB',
                dateAdded: '05 Abr',
              ),
              AppFileCard(
                category: 'PROCURAÇÃO',
                fileName: 'Procuração_Assinada.pdf',
                fileSize: '1.2 MB',
                dateAdded: '01 Apr',
              ),
              AppFileCard(
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

  Widget _buildChatTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textCaption),
          SizedBox(height: 16),
          Text('Histórico de Conversas', style: AppTextStyles.h2),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Aqui você verá o espelhamento das conversas com nosso assistente e advogados.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: PrimaryButton(
            label: 'Dúvida? Falar no WhatsApp',
            icon: Icons.chat_bubble_outline_rounded,
            backgroundColor: AppColors.success,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

