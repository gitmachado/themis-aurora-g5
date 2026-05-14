import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';

class LawyerAppointmentDetailScreen extends ConsumerStatefulWidget {
  final Appointment? appointment;

  const LawyerAppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<LawyerAppointmentDetailScreen> createState() =>
      _LawyerAppointmentDetailScreenState();
}

class _LawyerAppointmentDetailScreenState
    extends ConsumerState<LawyerAppointmentDetailScreen> {
  bool _isLoading = false;
  List<dynamic> _rescheduleSuggestions = [];
  bool _waitingForSuggestions = false;
  Timer? _suggestionPoller;

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentActionsProvider).complete(widget.appointment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento marcado como concluído!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao concluir: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar evento?'),
        content: const Text(
          'Esta ação não pode ser desfeita. Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentActionsProvider).cancel(widget.appointment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento cancelado'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleApprove() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentActionsProvider).approve(widget.appointment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compromisso aprovado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRejectApproval() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar agendamento?'),
        content: const Text(
          'O cliente será notificado que sua solicitação não foi confirmada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sim, rejeitar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentActionsProvider).reject(widget.appointment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento rejeitado'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao rejeitar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResetToAIVersion() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentActionsProvider).resetToAIVersion(widget.appointment!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revertido para proposta original'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reverter: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildApprovalButtons(Appointment target) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (target.createdByAI) ...[
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleResetToAIVersion,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reverter à Proposta Original'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () {
                // TODO: Implement reschedule request
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildRescheduleSheet(target),
                );
              },
              icon: const Icon(Icons.schedule, size: 18),
              label: const Text('Pedir IA Reagendar'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleRejectApproval,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.error,
                            ),
                          ),
                        )
                      : Text(
                          'Rejeitar',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Aprovar',
                onPressed: _isLoading ? null : _handleApprove,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardButtons() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.error,
                            ),
                          ),
                        )
                      : Text(
                          'Cancelar',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Concluir',
                onPressed: _isLoading ? null : _handleComplete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRescheduleSheet(Appointment appointment) {
    final instructionController = TextEditingController();
    bool isSubmitting = false;

    return StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_waitingForSuggestions) ...[
                Text(
                  'Reagendar com a IA',
                  style: AppTextStyles.h2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Text(
                  'Descreva suas preferências para reagendamento:',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructionController,
                  minLines: 3,
                  maxLines: 3,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Ex: Não quero segunda, veja a partir de terça',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: isSubmitting ? 'Enviando...' : 'Enviar',
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (instructionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Por favor, descreva sua preferência'),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSubmitting = true);

                                try {
                                  await ref.read(appointmentActionsProvider).requestReschedule(
                                    appointment.id,
                                    instructionController.text,
                                  );

                                  setSheetState(() {
                                    _waitingForSuggestions = true;
                                    isSubmitting = false;
                                  });

                                  // Start polling for suggestions
                                  _startSuggestionPolling(appointment.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Solicitação enviada! Aguardando sugestões da IA...'),
                                    ),
                                  );
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro: $e')),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Aguardando sugestões da IA...'),
                      SizedBox(height: 16),
                      Text(
                        'Isso geralmente leva alguns segundos',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_rescheduleSuggestions.isNotEmpty)
                  ..._rescheduleSuggestions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final suggestion = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['suggestedTitle'] ?? 'Sugestão',
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDateTime(suggestion['suggestedDatetime'] as DateTime),
                              style: AppTextStyles.caption,
                            ),
                            if (suggestion['suggestedDescription'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                suggestion['suggestedDescription'] as String,
                                style: AppTextStyles.caption,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await ref.read(appointmentActionsProvider)
                                            .rejectRescheduleSuggestion(suggestion['id'] as String);
                                        if (mounted) {
                                          setState(() {
                                            _rescheduleSuggestions.removeAt(idx);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Sugestão rejeitada')),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro: $e')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Rejeitar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PrimaryButton(
                                    label: 'Aceitar',
                                    onPressed: () async {
                                      try {
                                        await ref.read(appointmentActionsProvider)
                                            .acceptRescheduleSuggestion(
                                              suggestion['id'] as String,
                                              appointment.id,
                                            );
                                        if (mounted) {
                                          Navigator.pop(context);
                                          _stopSuggestionPolling();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Sugestão aceita! Pronto para aprovação.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startSuggestionPolling(String appointmentId) {
    _suggestionPoller = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final suggestions = await ref.read(appointmentActionsProvider)
            .getRescheduleSuggestions(appointmentId);

        if (mounted) {
          setState(() {
            _rescheduleSuggestions = suggestions;
            if (suggestions.isNotEmpty) {
              _waitingForSuggestions = false;
              timer.cancel();
            }
          });
        }
      } catch (e) {
        print('Error polling suggestions: $e');
      }
    });
  }

  void _stopSuggestionPolling() {
    _suggestionPoller?.cancel();
    setState(() {
      _waitingForSuggestions = false;
      _rescheduleSuggestions = [];
    });
  }

  @override
  void dispose() {
    _suggestionPoller?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.appointment;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Detalhes do Evento',
          showBackButton: true,
          actions: target != null && (target.status == 'SCHEDULED' || target.isPendingApproval)
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.ink),
                    onPressed: () => _showEditSheet(target),
                  ),
                ]
              : null,
        ),
        body: target == null
            ? const Center(child: Text('Evento não encontrado'))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(target),
                      const SizedBox(height: 24),
                      if (target.clientName != null || target.clientWhatsappNumber != null)
                        _buildInfoCard(
                          title: 'Informações do Cliente',
                          icon: Icons.person_rounded,
                          children: [
                            if (target.clientName != null)
                              _buildDetailRow('Nome', target.clientName!),
                            if (target.clientWhatsappNumber != null) ...[
                              if (target.clientName != null) const SizedBox(height: 8),
                              _buildDetailRow('WhatsApp', _formatWhatsApp(target.clientWhatsappNumber!)),
                            ],
                          ],
                        ),
                      if (target.clientName != null || target.clientWhatsappNumber != null)
                        const SizedBox(height: 24),
                      _buildInfoCard(
                        title: 'Data e Hora',
                        icon: Icons.calendar_today_rounded,
                        children: [
                          _buildDetailRow(
                            'Data programada',
                            _formatDate(target.scheduledAt),
                          ),
                          _buildDetailRow(
                            'Horário',
                            _formatInterval(target),
                          ),
                          _buildDetailRow(
                            'Duração',
                            '${target.durationMinutes} minutos',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        title: 'Pauta / Descrição',
                        icon: Icons.notes_rounded,
                        children: [
                          Text(
                            target.description?.isNotEmpty == true
                                ? target.description!
                                : 'Nenhuma descrição ou pauta cadastrada para este evento.',
                            style: AppTextStyles.body.copyWith(
                              color: target.description?.isNotEmpty == true
                                  ? AppColors.ink
                                  : AppColors.textCaption,
                              fontStyle: target.description?.isNotEmpty == true
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (target.clientId != null || target.processId != null) ...[
                        Text(
                          'Vínculos do Evento',
                          style: AppTextStyles.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        if (target.clientId != null)
                          _buildLinkShortcut(
                            context: context,
                            title: 'Acessar Ficha do Cliente',
                            icon: Icons.person_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/lawyer-client-detail',
                                arguments: {
                                  'id': target.clientId,
                                  'name': 'Cliente do Evento',
                                },
                              );
                            },
                          ),
                        if (target.processId != null)
                          _buildLinkShortcut(
                            context: context,
                            title: 'Ver Linha do Tempo do Processo',
                            icon: Icons.gavel_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.lawyerProcedureDetailRoute,
                                arguments: {'processId': target.processId},
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: target == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: target.isPendingApproval
                      ? _buildApprovalButtons(target)
                      : _buildStandardButtons(),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection(Appointment target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (target.createdByAI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Proposta da IA',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (target.createdByAI) const SizedBox(height: 12),
        Row(
          children: [
            AppBadge(
              label: target.typeLabel.toUpperCase(),
              type: _badgeTypeFor(target.type),
            ),
            const SizedBox(width: 8),
            AppBadge(
              label: target.statusLabel.toUpperCase(),
              type: target.isPendingApproval
                  ? BadgeType.warning
                  : target.status == 'COMPLETED'
                      ? BadgeType.success
                      : target.status == 'CANCELED'
                          ? BadgeType.error
                          : BadgeType.neutral,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          target.title,
          style: AppTextStyles.h1.copyWith(
            fontSize: 22,
            color: AppColors.ink,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textCaption),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkShortcut({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textCaption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BadgeType _badgeTypeFor(String type) => switch (type) {
    'DEADLINE' => BadgeType.error,
    'HEARING' => BadgeType.warning,
    'MEETING' => BadgeType.primary,
    _ => BadgeType.neutral,
  };

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatInterval(Appointment target) {
    final start = target.scheduledAt;
    final end = target.endTime;
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  String _formatWhatsApp(String number) {
    final clean = number.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 11) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}';
    }
    return number;
  }

  void _showEditSheet(Appointment target) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAppointmentSheet(appointment: target),
    );
  }
}

class EditAppointmentSheet extends ConsumerStatefulWidget {
  final Appointment appointment;

  const EditAppointmentSheet({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<EditAppointmentSheet> createState() =>
      _EditAppointmentSheetState();
}

class _EditAppointmentSheetState extends ConsumerState<EditAppointmentSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late DateTime _selectedDateTime;
  String? _selectedProcessId;

  @override
  void initState() {
    super.initState();
    final target = widget.appointment;
    _titleController = TextEditingController(text: target.title);
    _descriptionController = TextEditingController(text: target.description ?? '');
    _selectedType = target.type;
    _selectedDateTime = target.scheduledAt;
    _selectedProcessId = target.processId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final procedures = ref.watch(myProceduresProvider).valueOrNull ?? const [];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Editar Evento',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título do evento',
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.yellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descrição (opcional)',
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.yellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo',
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'MEETING', child: Text('Reunião')),
                DropdownMenuItem(value: 'DEADLINE', child: Text('Prazo')),
                DropdownMenuItem(value: 'HEARING', child: Text('Audiência')),
                DropdownMenuItem(value: 'OTHER', child: Text('Outro')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            if (procedures.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedProcessId,
                decoration: InputDecoration(
                  labelText: 'Vincular a Processo (opcional)',
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nenhum')),
                  ...procedures.map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedProcessId = value);
                },
                isExpanded: true,
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickDateTime(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data e Hora',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.ink3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_calendar_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: _updateAppointment,
                child: Text(
                  'Salvar Alterações',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (mounted && time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _updateAppointment() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título é obrigatório')),
      );
      return;
    }

    try {
      await ref.read(appointmentActionsProvider).update(
        widget.appointment.id,
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
          if (_selectedProcessId != null) 'processId': _selectedProcessId,
          'type': _selectedType,
          'scheduledAt': _selectedDateTime.toIso8601String(),
          'durationMinutes': widget.appointment.durationMinutes,
        },
      );

      if (mounted) {
        Navigator.pop(context); // Fecha sheet
        Navigator.pop(context); // Retorna da tela de detalhes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }
}
