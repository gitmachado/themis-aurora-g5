import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../widgets/timeline_summary_card.dart';
import '../widgets/timeline_event_tile.dart';

class ClientProcessTimelineScreen extends StatefulWidget {
  const ClientProcessTimelineScreen({super.key});

  @override
  State<ClientProcessTimelineScreen> createState() => _ClientProcessTimelineScreenState();
}

class _ClientProcessTimelineScreenState extends State<ClientProcessTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Detalhes do Processo',
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'IA Resumo'),
              Tab(text: 'Docs'),
              Tab(text: 'Chat'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildTimelineTab(),
                  _buildAiResumoTab(),
                  _buildDocsTab(),
                  _buildChatTab(),
                ],
              ),
            ),
            _buildActionFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Linha do Tempo',
            style: AppTextStyles.h2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 24),
          const TimelineEventTile(
            isFirst: true,
            date: '08/04/2026 às 14:30',
            description: 'Processo distribuído e aguardando primeira análise do juiz.',
            icon: Icons.gavel_outlined,
          ),
          const TimelineEventTile(
            date: '07/04/2026 às 10:00',
            description: 'Recebemos todos os documentos enviados. Vamos finalizar a petição hoje.',
            icon: Icons.description_outlined,
            iconBackgroundColor: Color(0xFFE8F5E9),
          ),
          const TimelineEventTile(
            isLast: true,
            date: '05/04/2026 às 09:00',
            description: 'Contrato firmado e honorários iniciais quitados com sucesso.',
            icon: Icons.history_edu_outlined,
            iconBackgroundColor: Color(0xFFFFF3E0),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResumoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TimelineSummaryCard(
            status: 'Em Análise',
            lastMovement: '08/04/2026',
            onAiAnalysisTap: () {},
            onChatMirrorTap: () => DefaultTabController.of(context).animateTo(3),
          ),
          const SizedBox(height: 24),
          _buildInfoSection('Dados do Processo', [
            {'label': 'Número', 'value': '0001234-56.2026.8.26.0100'},
            {'label': 'Vara', 'value': '12ª Vara Cível'},
            {'label': 'Comarca', 'value': 'São Paulo - SP'},
          ]),
        ],
      ),
    );
  }

  Widget _buildDocsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDocItem('Petição Inicial.pdf', '08/04/2026'),
        _buildDocItem('Procuração.pdf', '05/04/2026'),
        _buildDocItem('Documentos Pessoais.zip', '05/04/2026'),
      ],
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

  Widget _buildDocItem(String name, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: AppColors.textCaption),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['label']!, style: AppTextStyles.caption),
                    Text(item['value']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: PrimaryButton(
        label: 'Dúvida? Falar no WhatsApp',
        icon: Icons.chat_bubble_outline_rounded,
        backgroundColor: AppColors.success,
        onPressed: () => Navigator.pushNamed(context, '/chat-mirror'),
      ),
    );
  }
}
