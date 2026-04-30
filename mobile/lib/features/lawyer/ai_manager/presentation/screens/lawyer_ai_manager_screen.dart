import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerAIManagerScreen extends StatefulWidget {
  const LawyerAIManagerScreen({super.key});

  @override
  State<LawyerAIManagerScreen> createState() => _LawyerAIManagerScreenState();
}

class _LawyerAIManagerScreenState extends State<LawyerAIManagerScreen> {
  bool _botEnabled = true;
  double _creativity = 0.3;
  final TextEditingController _toneController = TextEditingController(
    text: 'Profissional, acolhedor e direto.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Gestão de IA (RAG)',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildConfigurationSection(),
            const SizedBox(height: 24),
            _buildKnowledgeBaseSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.smart_toy_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status do Bot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _botEnabled ? 'Ativo e respondendo' : 'Pausado pelo advogado',
                  style: AppTextStyles.caption.copyWith(
                    color: _botEnabled ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _botEnabled,
            onChanged: (val) => setState(() => _botEnabled = val),
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configurações de Comportamento', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tom de Voz',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _toneController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Criatividade (Temperatura)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _creativity.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _creativity,
                onChanged: (val) => setState(() => _creativity = val),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.divider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeBaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Base de Conhecimento', style: AppTextStyles.h2),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('PDF'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFileTile('Jurisprudência_Trabalhista_V1.pdf', 'Ativo'),
        _buildFileTile('Regras_Escritorio_Honorarios.pdf', 'Ativo'),
        _buildFileTile('Modelo_Contrato_Civel.pdf', 'Analisando...'),
      ],
    );
  }

  Widget _buildFileTile(String name, String status) {
    bool isAnalyzing = status == 'Analisando...';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf_outlined,
          color: isAnalyzing ? AppColors.textCaption : AppColors.error,
        ),
        title: Text(name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: isAnalyzing ? AppColors.warning : AppColors.success,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.textCaption,
            size: 20,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
