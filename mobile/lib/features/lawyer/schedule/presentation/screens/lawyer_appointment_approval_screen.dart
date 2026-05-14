import 'package:flutter/material.dart';
import '../../../../../app/routes/app_router.dart';
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
      appBar: AppBar(
        title: const Text('Aprovação de Agendamentos'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshAppointments,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (pendingAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum agendamento pendente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshAppointments,
              child: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: ListView.builder(
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.lawyerAppointmentDetailRoute,
            arguments: appointment,
          );
        },
        leading: const Icon(Icons.auto_awesome, color: Colors.amber),
        title: Text(appointment.title),
        subtitle: Text(
          _formatDateTime(appointment.scheduledAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
