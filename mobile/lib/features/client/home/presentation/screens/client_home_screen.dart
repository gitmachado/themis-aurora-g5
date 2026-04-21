import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../widgets/law_news_card.dart';
import '../widgets/hero_update_card.dart';
import '../widgets/quick_ai_card.dart';
import '../../../../../../shared/constants/app_dimensions.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppDashboardHeader(
              name: 'Lucas Silva',
              greeting: 'Bom dia,',
              avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=256&h=256&auto=format&fit=crop',
              notificationCount: 2,
              onProfileTap: () => Navigator.pushNamed(context, '/profile'),
              onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            Container(
              height: 1,
                color: AppColors.divider.withValues(alpha: 0.7),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          HeroUpdateCard(
                            title: 'Petição Inicial Protocolada',
                            subtitle: 'Seu processo #9821 teve uma nova movimentação importante.',
                            onDetailsTap: () => Navigator.pushNamed(context, '/procedure-timeline'),
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
                          SizedBox(height: AppDimensions.bottomPadding(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
