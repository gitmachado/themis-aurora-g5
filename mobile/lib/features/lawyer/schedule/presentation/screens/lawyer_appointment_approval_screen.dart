import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/routes/app_router.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';

class LawyerAppointmentApprovalScreen extends ConsumerWidget {
  const LawyerAppointmentApprovalScreen({Key? key}) : super(key: key);

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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar: $err', style: AppTextStyles.body),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => ref.refresh(pendingAppointmentsProvider),
                child: Text('Tentar Novamente', style: AppTextStyles.body.copyWith(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Appointment> pendingAppointments) {
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
                    const Icon(Icons.edit_calendar_rounded, size: 64, color: AppColors.ink4),
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
        itemCount: pendingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pendingAppointments[index];
          return _buildAppointmentCard(context, appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment appointment,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.lawyerAppointmentDetailRoute,
            arguments: appointment,
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.yellow.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit_calendar_rounded, color: AppColors.ink),
        ),
        title: Text(appointment.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          _formatDateTime(appointment.scheduledAt),
          style: AppTextStyles.caption.copyWith(color: AppColors.ink3),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.ink3),
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
