import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          title: 'Política de Privacidade',
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
                'Sua privacidade é nossa prioridade',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Última atualização: 04 de Maio de 2026',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              _buildSection(
                '1. Introdução',
                'O Themis valoriza a privacidade de seus usuários e está comprometido com a proteção dos dados pessoais coletados durante o uso de nossa plataforma de monitoramento de processos jurídicos.',
              ),
              _buildSection(
                '2. Coleta de Dados',
                'Coletamos informações necessárias para a prestação de nossos serviços, incluindo:\n\n'
                    '• Dados de identificação (nome, email, telefone);\n'
                    '• Informações processuais vinculadas ao seu CPF/CNPJ;\n'
                    '• Dados de uso do aplicativo para fins de melhoria contínua.',
              ),
              _buildSection(
                '3. Uso das Informações',
                'Utilizamos seus dados para:\n\n'
                    '• Notificar sobre movimentações em seus processos;\n'
                    '• Facilitar a comunicação com seu advogado;\n'
                    '• Personalizar sua experiência no aplicativo.',
              ),
              _buildSection(
                '4. Compartilhamento de Dados',
                'Não vendemos seus dados a terceiros. O compartilhamento ocorre apenas quando necessário para a execução do serviço (ex: sistemas do Poder Judiciário) ou por obrigação legal.',
              ),
              _buildSection(
                '5. Segurança',
                'Implementamos medidas técnicas e organizacionais avançadas para proteger seus dados contra acessos não autorizados, perda ou alteração.',
              ),
              _buildSection(
                '6. Seus Direitos',
                'De acordo com a LGPD, você tem direito a acessar, corrigir, portar ou solicitar a exclusão de seus dados pessoais a qualquer momento através de nossos canais de suporte.',
              ),
              _buildSection(
                '7. Contato',
                'Se tiver dúvidas sobre esta política, entre em contato através do email: suporte@themis.com.br',
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
