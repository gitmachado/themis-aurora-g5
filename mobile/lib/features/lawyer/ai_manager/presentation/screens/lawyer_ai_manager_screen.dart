import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_assets.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Themis IA', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildTestChatButton(context),
              const SizedBox(height: 24),
              _buildConfigurationSection(),
              const SizedBox(height: 24),
              _buildKnowledgeBaseSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestChatButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.lawyerAIChatRoute);
        },
        icon: const Icon(Icons.forum_rounded, color: AppColors.white),
        label: const Text(
          'Conversar com Assistente IA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.logo,
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(
              AppColors.yellow,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Themis ativa',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _botEnabled ? 'Ativo e respondendo' : 'Pausado pelo advogado',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _botEnabled,
            onChanged: (val) => setState(() => _botEnabled = val),
            activeTrackColor: AppColors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comportamento', style: AppTextStyles.cap),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
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
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _creativity,
                onChanged: (val) => setState(() => _creativity = val),
                activeColor: AppColors.yellow,
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
            Text('Base de conhecimento', style: AppTextStyles.cap),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
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
