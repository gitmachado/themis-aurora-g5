import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../widgets/timeline_summary_card.dart';
import '../widgets/timeline_event_tile.dart';

class ClientProcessTimelineScreen extends StatelessWidget {
  const ClientProcessTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimelineSummaryCard(
                    status: 'Em Análise',
                    lastMovement: '08/04/2026',
                    onAiAnalysisTap: _handleAiAnalysis,
                    onChatMirrorTap: () => Navigator.pushNamed(context, '/chat-mirror'),
                  ),
                  const SizedBox(height: 32),
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
            ),
          ),
          _buildActionFooter(context),
        ],
      ),
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
        // Using a similar green for WhatsApp
        onPressed: () => Navigator.pushNamed(context, '/chat-mirror'),
      ),
    );
  }

  static void _handleAiAnalysis() {
    // Implementação pendente
  }
}
