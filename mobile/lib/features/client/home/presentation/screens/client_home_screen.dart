import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/app_dashboard_header.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_assets.dart';
import '../providers/client_navigation_provider.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final procedures = ref.watch(myProceduresProvider);
    final notifications =
        ref.watch(myNotificationsProvider).valueOrNull ?? const [];
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final account = auth?.account;
    final allProcedures = procedures.valueOrNull ?? const <LegalProcess>[];
    final procedureList = account == null
        ? const <LegalProcess>[]
        : allProcedures
              .where((process) => process.clientId == account.id)
              .toList();
    final firstProcedure = procedureList.isEmpty ? null : procedureList.first;
    final documents = ref.watch(myDocumentsProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppDashboardHeader(
            name: auth?.account?.name ?? 'Cliente',
            subtitle: 'Cliente',
            avatarUrl: auth?.account?.avatarUrl,
            notificationCount: unreadCount,
            onProfileTap: () => Navigator.pushNamed(context, '/profile'),
            onNotificationTap: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myProceduresProvider);
                ref.invalidate(myNotificationsProvider);
                ref.invalidate(myDocumentsProvider);
                await ref.read(myProceduresProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          Text(
                            'Seu processo\nem andamento',
                            style: AppTextStyles.h1.copyWith(fontSize: 29),
                          ),
                          const SizedBox(height: 18),
                          _buildHeroProcessCard(context, firstProcedure),
                          const SizedBox(height: 14),
                          _buildStatsGrid(procedureList.length, documents.length),
                          const SizedBox(height: 18),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: ThemisSectionLabel('Ações rápidas'),
                          ),
                          const SizedBox(height: 10),
                          _buildQuickActions(context, ref),
                          SizedBox(height: AppDimensions.bottomPadding(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProcessCard(
    BuildContext context,
    LegalProcess? firstProcedure,
  ) {
    final hasProcedure = firstProcedure != null;

    return AppCard(
      color: AppColors.ink,
      hasBorder: false,
      padding: const EdgeInsets.all(24),
      onTap: hasProcedure
          ? () => Navigator.pushNamed(
              context,
              AppRouter.procedureTimelineRoute,
              arguments: {'processId': firstProcedure.id},
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasProcedure ? 'ATUALIZADO HOJE' : 'SEM PROCESSO ATIVO',
            style: AppTextStyles.cap.copyWith(
              color: AppColors.yellow,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasProcedure ? firstProcedure.displayTitle : 'Nenhum tramite ativo',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasProcedure
                ? (firstProcedure.lastNote ??
                      'Atualizado em ${formatFullDateTime(firstProcedure.updatedAt)}')
                : 'Quando houver atualizacoes, elas aparecerao aqui.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.white.withValues(alpha: 0.72),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasProcedure
                      ? (firstProcedure.processNumber ?? firstProcedure.id)
                      : 'Aguardando dados',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mono.copyWith(
                    color: AppColors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
              if (hasProcedure)
                Row(
                  children: [
                    Text(
                      'Ver linha do tempo',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.yellow,
                      size: 18,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int procedureCount, int documentCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Processos ativos', procedureCount.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('Documentos', documentCount.toString())),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h1.copyWith(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ThemisActionRow(
            iconWidget: SvgPicture.asset(
              AppAssets.logo,
              width: 18,
              height: 18,
            ),
            label: 'Falar com a Themis',
            iconBackground: AppColors.yellowSoft,
            onTap: () => ref.read(clientNavigationIndexProvider.notifier).state = 3,
          ),
          const Divider(height: 1, color: AppColors.line2),
          ThemisActionRow(
            icon: Icons.upload_rounded,
            label: 'Enviar documento',
            onTap: () => Navigator.pushNamed(context, '/files'),
          ),
          const Divider(height: 1, color: AppColors.line2),
          ThemisActionRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Continuar no WhatsApp',
            iconBackground: AppColors.successBackground,
            iconColor: AppColors.success,
            onTap: () => launchUrl(
              Uri.parse('https://wa.me/558487922092'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
