import 'package:flutter/material.dart';
import '../../../../../app/routes/app_router.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_text_styles.dart';
import '../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../domain/entities/appointment.dart';

class LawyerAppointmentApprovalScreen extends StatefulWidget {
  const LawyerAppointmentApprovalScreen({Key? key}) : super(key: key);

  @override
  State<LawyerAppointmentApprovalScreen> createState() =>
      _LawyerAppointmentApprovalScreenState();
}

class _LawyerAppointmentApprovalScreenState
    extends State<LawyerAppointmentApprovalScreen> {
  late List<Appointment> pendingAppointments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingAppointments();
  }

  Future<void> _loadPendingAppointments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // TODO: Fetch pending appointments from API
    // For now, showing empty state
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshAppointments() async {
    await _loadPendingAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Agendamentos da IA',
        showBackButton: true,
        showDivider: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro: $errorMessage', style: AppTextStyles.body),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _refreshAppointments,
              child: Text('Tentar Novamente', style: AppTextStyles.body.copyWith(color: AppColors.white)),
            ),
          ],
        ),
      );
    }

    if (pendingAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshAppointments,
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
      onRefresh: _refreshAppointments,
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
