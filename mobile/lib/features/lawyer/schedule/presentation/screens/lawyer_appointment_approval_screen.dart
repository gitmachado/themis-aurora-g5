import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/routes/app_router.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/utils/string_utils.dart';
import '../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../clients/presentation/providers/lawyer_client_providers.dart';
import '../../../leads/presentation/providers/lead_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';

class LawyerAppointmentApprovalScreen extends ConsumerWidget {
  const LawyerAppointmentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Agendamentos da IA',
        showBackButton: true,
        showDivider: false,
      ),
      body: pendingAsync.when(
        data: (pending) => _buildContent(context, ref, pending),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar: $err', style: AppTextStyles.body),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => ref.refresh(pendingAppointmentsProvider),
                child: Text(
                  'Tentar Novamente',
                  style: AppTextStyles.body.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Appointment> pendingAppointments,
  ) {
    if (pendingAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(pendingAppointmentsProvider.future),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_calendar_rounded,
                      size: 64,
                      color: AppColors.ink4,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum agendamento pendente',
                      style: AppTextStyles.body.copyWith(color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingAppointmentsProvider.future),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: pendingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pendingAppointments[index];
          return _buildAppointmentCard(context, ref, appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    final clients = ref.watch(myLawyerClientsProvider).valueOrNull ?? [];
    final leads = ref.watch(allLeadsProvider).valueOrNull ?? [];

    String clientName = '';
    String whatsappNumber = '';

    // NOVO: Prioriza dados vindo direto do agendamento (backend)
    if (appointment.clientName != null && appointment.clientName!.isNotEmpty) {
      clientName = appointment.clientName!;
    }
    if (appointment.clientWhatsappNumber != null && appointment.clientWhatsappNumber!.isNotEmpty) {
      whatsappNumber = appointment.clientWhatsappNumber!;
    }

    // 1. Se ainda vazio, tenta buscar pelo ID direto
    if (clientName.isEmpty && appointment.clientId != null && appointment.clientId!.isNotEmpty) {
      final c = clients.where((item) => item.id == appointment.clientId).firstOrNull;
      if (c != null) {
        clientName = c.name;
        whatsappNumber = c.whatsappNumber;
      } else {
        final l = leads.where((item) => item.id == appointment.clientId).firstOrNull;
        if (l != null) {
          clientName = l.name ?? '';
          whatsappNumber = l.whatsappNumber;
        }
      }
    }

    // 2. Se não achou por ID, tenta buscar pelo nome contido no título ou descrição
    if (clientName.isEmpty) {
      final combined = [
        ...clients.map((c) => (name: c.name, phone: c.whatsappNumber)),
        ...leads.map((l) => (name: l.name ?? '', phone: l.whatsappNumber)),
      ];
      for (final item in combined) {
        if (item.name.isNotEmpty &&
            (appointment.title.toLowerCase().contains(item.name.toLowerCase()) ||
                (appointment.description ?? '').toLowerCase().contains(item.name.toLowerCase()))) {
          clientName = item.name;
          whatsappNumber = item.phone;
          break;
        }
      }
    }

    // 3. Checa aiOriginalData se ainda vazio
    if (clientName.isEmpty && appointment.aiOriginalData != null) {
      final aiData = appointment.aiOriginalData!;
      if (aiData.containsKey('clientName')) {
        clientName = aiData['clientName'].toString();
      } else if (aiData.containsKey('whatsappNumber')) {
        whatsappNumber = aiData['whatsappNumber'].toString();
      }
    }

    // 4. Fallback final extraindo do título com regex ou usando o próprio título
    if (clientName.isEmpty) {
      final reg = RegExp(
        r'(?:com|-)\s+([A-Za-zÀ-ÖØ-öø-ÿ]+(?:\s+[A-Za-zÀ-ÖØ-öø-ÿ]+)*)',
        caseSensitive: false,
      );
      final match = reg.firstMatch(appointment.title);
      if (match != null && match.group(1) != null) {
        clientName = match.group(1)!.trim();
      } else {
        if (appointment.title.length > 3 &&
            !appointment.title.toLowerCase().startsWith('consulta')) {
          clientName = appointment.title;
        } else {
          clientName = 'Cliente IA';
        }
      }
    }

    if (whatsappNumber.isEmpty) {
      whatsappNumber = 'Não informado';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellow, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.lawyerAppointmentDetailRoute,
            arguments: appointment,
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
              child: Text(
                StringUtils.getInitials(clientName),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                StringUtils.formatFirstAndLastName(clientName),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              _formatDateTime(appointment.scheduledAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textCaption,
                fontSize: 11,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_android_rounded,
                    size: 14,
                    color: AppColors.ink3,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    whatsappNumber,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.ink2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.edit_calendar_rounded,
                    size: 14,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.title,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.ink2,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }
}
