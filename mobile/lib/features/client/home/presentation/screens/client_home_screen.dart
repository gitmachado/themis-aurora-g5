import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../widgets/law_news_card.dart';
import '../widgets/hero_update_card.dart';
import '../widgets/quick_ai_card.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDashboardHeader(
                name: 'Lucas Silva',
                greeting: 'Bom dia,',
                notificationCount: 2,
                onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroUpdateCard(
                      title: 'Petição Inicial Protocolada',
                      subtitle: 'Seu processo #9821 teve uma nova movimentação importante.',
                      onDetailsTap: () => Navigator.pushNamed(context, '/process-timeline'),
                    ),
                    const SizedBox(height: 16),
                    QuickAiCard(
                      onTap: () => Navigator.pushNamed(context, '/chat-mirror'),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Destaques Jurídicos',
                          style: AppTextStyles.h2.copyWith(fontSize: 18),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Ver tudo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const LawNewsCard(
                      title: 'Nova lei de proteção de dados entra em vigor amanhã',
                      category: 'Direito Digital',
                      timeLeft: '2h atrás',
                    ),
                    const SizedBox(height: 16),
                    const LawNewsCard(
                      title: 'STF decide sobre revisão da vida toda no INSS',
                      category: 'Previdenciário',
                      timeLeft: '5h atrás',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
