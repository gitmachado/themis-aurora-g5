import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerProcedureDetailScreen extends StatefulWidget {
  const LawyerProcedureDetailScreen({super.key});

  @override
  State<LawyerProcedureDetailScreen> createState() => _LawyerProcedureDetailScreenState();
}

class _LawyerProcedureDetailScreenState extends State<LawyerProcedureDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Trâmite 1023456-88',
          showBackButton: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Resumo'),
              Tab(text: 'Arquivos'),
              Tab(text: 'Chat'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildTimelineTab(),
              _buildResumoTab(),
              _buildFilesTab(),
              _buildChatMirrorTab(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'lawyer_procedure_detail_fab',
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineItem(
            title: 'Petição Inicial Protocolada',
            date: '15 Mai 2024 • 14:30',
            description: 'O trâmite foi iniciado com sucesso.',
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Citação Expedida',
            date: '18 Mai 2024 • 09:15',
            description: 'A parte contrária foi notificada.',
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Audiência Designada',
            date: '20 Mai 2024 • 11:00',
            description: 'Audiência de conciliação marcada para 10/06.',
            isLast: true,
            isCurrent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResumoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Informações Gerais', [
            {'label': 'Número', 'value': '1023456-88.2024.8.26.0100'},
            {'label': 'Classe', 'value': 'Procedimento Comum Cível'},
            {'label': 'Assunto', 'value': 'Indenização por Dano Moral'},
            {'label': 'Valor da Causa', 'value': r'R$ 50.000,00'},
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Partes', [
            {'label': 'Requerente', 'value': 'João Silva'},
            {'label': 'Requerido', 'value': 'Banco do Brasil S/A'},
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Vara / Comarca', [
            {'label': 'Vara', 'value': '2ª Vara Cível'},
            {'label': 'Comarca', 'value': 'São Paulo - SP'},
          ]),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildFileTile('Petição_Inicial_Final.pdf', '15/05/2024', Icons.picture_as_pdf_rounded),
        _buildFileTile('Comprovante_Residencia_Joao.jpg', '12/05/2024', Icons.image_rounded),
        _buildFileTile('Contrato_Prestacao_Servicos.pdf', '10/05/2024', Icons.picture_as_pdf_rounded),
        _buildFileTile('Procuracao_Assinada.pdf', '10/05/2024', Icons.picture_as_pdf_rounded),
      ],
    );
  }

  Widget _buildChatMirrorTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: AppColors.primary.withValues(alpha: 0.05),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Espelhamento do WhatsApp (Somente Leitura)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildChatMirrorBubble('Olá, gostaria de saber o status do meu trâmite.', '10:00', true),
              _buildChatMirrorBubble('Olá! Sou o assistente jurídico. Vou verificar para você. Qual o seu CPF?', '10:00', false),
              _buildChatMirrorBubble('123.456.789-00', '10:01', true),
              _buildChatMirrorBubble('Obrigado. Seu trâmite está em fase de citação. Deseja falar com um advogado?', '10:01', false),
              _buildChatMirrorBubble('Sim, por favor. Tenho uma dúvida sobre a última petição.', '10:02', true),
              _buildChatMirrorBubble('Entendido. Vou encaminhar sua solicitação para o Dr. Rodrigo.', '10:03', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMirrorBubble(String message, String time, bool isClient) {
    return Align(
      alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isClient ? AppColors.white : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isClient ? 0 : 16),
            bottomRight: Radius.circular(isClient ? 16 : 0),
          ),
          border: isClient ? Border.all(color: AppColors.divider) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
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

  Widget _buildFileTile(String name, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(date, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        trailing: const Icon(Icons.more_vert_rounded, color: AppColors.textCaption, size: 20),
        onTap: () => Navigator.pushNamed(context, '/lawyer-file-review'),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    bool isLast = false,
    bool isCurrent = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.divider,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: isCurrent ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6)] : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCurrent ? AppColors.primary : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(date, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              const SizedBox(height: 8),
              Text(description, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 13)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

