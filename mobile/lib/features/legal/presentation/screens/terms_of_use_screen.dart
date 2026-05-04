import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Termos de Uso',
          centerTitle: true,
          showBackButton: true,
          backgroundColor: Colors.white,
          showDivider: true, // Adicionado a borda inferior (divider)
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Termos e Condições de Uso',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Última atualização: 04 de Maio de 2026',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              _buildSection(
                '1. Aceitação dos Termos',
                'Ao acessar e utilizar o Themis, você concorda expressamente com estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deverá utilizar o aplicativo.',
              ),
              _buildSection(
                '2. Descrição do Serviço',
                'O Themis é uma plataforma que facilita o acompanhamento de processos jurídicos e a comunicação entre advogados e clientes. O aplicativo não substitui o aconselhamento jurídico profissional.',
              ),
              _buildSection(
                '3. Responsabilidades do Usuário',
                'O usuário é responsável por:\n\n'
                    '• Fornecer informações verídicas e atualizadas;\n'
                    '• Manter a confidencialidade de sua senha de acesso;\n'
                    '• Utilizar o serviço de forma ética e legal.',
              ),
              _buildSection(
                '4. Limitação de Responsabilidade',
                'Embora nos esforcemos para fornecer informações precisas em tempo real, o Themis não se responsabiliza por eventuais atrasos ou inconsistências originadas nos sistemas oficiais dos tribunais.',
              ),
              _buildSection(
                '5. Propriedade Intelectual',
                'Todo o conteúdo, design e software do Themis são de propriedade exclusiva da nossa empresa e protegidos pelas leis de propriedade intelectual.',
              ),
              _buildSection(
                '6. Alterações nos Termos',
                'Reservamo-nos o direito de modificar estes termos a qualquer momento. Alterações significativas serão notificadas através do aplicativo ou por email.',
              ),
              _buildSection(
                '7. Foro',
                'Para dirimir quaisquer controvérsias oriundas deste termo, as partes elegem o foro da comarca de Sede da Empresa.',
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height:
              MediaQuery.of(context).padding.bottom +
              8, // Pequeno padding extra para a borda
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.line2,
                width: 1,
              ), // Borda superior
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
