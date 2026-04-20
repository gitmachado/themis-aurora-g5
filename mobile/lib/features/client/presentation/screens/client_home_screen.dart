import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/cards/document_progress_tile.dart';
import '../widgets/home_header.dart';
import '../widgets/hero_update_card.dart';
import '../widgets/quick_ai_card.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(
                userName: 'Lucas Silva',
                notificationCount: 2,
              ),
              const SizedBox(height: 24),
              HeroUpdateCard(
                title: 'Ação Indenizatória #9821',
                subtitle: 'O juiz despachou uma nova ordem de pagamento.',
                onDetailsTap: () => Navigator.pushNamed(context, '/process-timeline'),
              ),
              const SizedBox(height: 32),
              Text(
                'Acesso Rápido',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              QuickAiCard(
                onTap: () => Navigator.pushNamed(context, '/chat-mirror'),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Seus Documentos',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/documents'),
                    child: Text(
                      'Ver todos',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDocumentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList() {
    return Column(
      children: [
        DocumentProgressTile(
          title: 'Contrato Social',
          status: 'Enviando... • 40%',
          iconColor: AppColors.primary,
          progress: 0.4,
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 12),
        DocumentProgressTile(
          title: 'RG e CNH',
          status: 'Aprovado • Enviado em 10/06',
          statusColor: AppColors.success,
          iconColor: AppColors.success,
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 12),
        DocumentProgressTile(
          title: 'Comprovante de Residência',
          status: 'Em análise • Enviado hoje',
          statusColor: AppColors.warning,
          iconColor: AppColors.warning,
          icon: Icons.access_time_rounded,
        ),
      ],
    );
  }
}
