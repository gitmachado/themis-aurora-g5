import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';
import '../../../../../../app/routes/app_router.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_card.dart';
import '../widgets/schedule_calendar_strip.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';

class LawyerScheduleScreen extends ConsumerStatefulWidget {
  const LawyerScheduleScreen({super.key});

  @override
  ConsumerState<LawyerScheduleScreen> createState() =>
      _LawyerScheduleScreenState();
}

class _LawyerScheduleScreenState extends ConsumerState<LawyerScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    // Refresh pending count every 30 seconds
    unawaited(
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          ref.refresh(pendingAppointmentsCountProvider);
        }
      }),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFilterChanged(int index, WidgetRef ref) {
    ref.read(showHistoryProvider.notifier).state = index == 1;
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Sync tab controller with provider
        final showHistory = ref.watch(showHistoryProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_tabController.index != (showHistory ? 1 : 0)) {
            _tabController.index = showHistory ? 1 : 0;
          }
        });

        return _buildContent(context, ref);
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);
    final appointmentsByDate = ref.watch(appointmentsByDateProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final currentMode = ref.watch(scheduleViewModeProvider);
    final showHistory = ref.watch(showHistoryProvider);
    final pendingCount = ref.watch(pendingAppointmentsCountProvider);
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    const shortWeekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    final selectedWeekdayName = shortWeekdays[selectedDate.weekday - 1];
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final isTomorrow =
        selectedDate.year == tomorrow.year &&
        selectedDate.month == tomorrow.month &&
        selectedDate.day == tomorrow.day;
    final daySuffix = isToday
        ? 'Hoje'
        : isTomorrow
        ? 'Amanhã'
        : selectedWeekdayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Agenda do escritório',
        showBackButton: true,
        showDivider: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_calendar_rounded,
                    size: 24,
                    color: AppColors.ink,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.lawyerAppointmentApprovalRoute,
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
              // Badge mostra apenas se há agendamentos pendentes (> 0)
              pendingCount.when(
                data: (count) {
                  if (count > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.yellow,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (err, st) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ThemisSegmentedControl(
                labels: const ['Abertos', 'Fechados'],
                selectedIndex: _tabController.index,
                controller: _tabController,
                onChanged: (index) => _onFilterChanged(index, ref),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'SELECIONE O DIA',
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.ink3,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            ScheduleCalendarStrip(
              selectedDate: selectedDate,
              appointments: appointments.valueOrNull ?? const [],
              currentMode: currentMode,
              showHistory: showHistory,
              onDateSelected: (date) {
                ref.read(selectedDateProvider.notifier).state = date;
                final nowLocal = DateTime.now();
                if (date.year == nowLocal.year &&
                    date.month == nowLocal.month &&
                    date.day == nowLocal.day) {
                  ref.read(scheduleViewModeProvider.notifier).state = 'today';
                } else if (date.year == nowLocal.year &&
                    date.month == nowLocal.month &&
                    date.day == nowLocal.day + 1) {
                  ref.read(scheduleViewModeProvider.notifier).state =
                      'tomorrow';
                } else {
                  ref.read(scheduleViewModeProvider.notifier).state =
                      'custom_day';
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'FILTRAR',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.ink3,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentMode,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.ink3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        dropdownColor: AppColors.white,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (val) {
                          if (val == null) return;
                          ref.read(scheduleViewModeProvider.notifier).state =
                              val;
                          final nowLocal = DateTime.now();
                          if (val == 'today') {
                            ref.read(selectedDateProvider.notifier).state =
                                nowLocal;
                          } else if (val == 'tomorrow') {
                            ref.read(selectedDateProvider.notifier).state =
                                nowLocal.add(const Duration(days: 1));
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'today',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.ink3,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Hoje - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} (${shortWeekdays[now.weekday - 1]})',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'tomorrow',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.ink3,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Amanhã - ${tomorrow.day.toString().padLeft(2, '0')}/${tomorrow.month.toString().padLeft(2, '0')}/${tomorrow.year} (${shortWeekdays[tomorrow.weekday - 1]})',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'week',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.date_range_rounded,
                                  size: 18,
                                  color: AppColors.ink3,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Esta Semana',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'month',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.date_range_rounded,
                                  size: 18,
                                  color: AppColors.ink3,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Este Mês',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentMode == 'custom_day')
                            DropdownMenuItem(
                              value: 'custom_day',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} (${shortWeekdays[selectedDate.weekday - 1]})',
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 24,
                top: 16,
                bottom: 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'EVENTOS (${appointmentsByDate.length})',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.ink3,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(appointmentsProvider.notifier).refresh();
                },
                child: appointments.when(
                  data: (items) {
                    if (appointmentsByDate.isEmpty) {
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Column(
                                children: [
                                  const Spacer(flex: 4),
                                  const Icon(
                                    Icons.event_busy_rounded,
                                    size: 48,
                                    color: AppColors.ink4,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    currentMode == 'week'
                                        ? 'Nenhum compromisso na semana selecionada'
                                        : currentMode == 'month'
                                        ? 'Nenhum compromisso no mês selecionado'
                                        : 'Nenhum compromisso em ${_formatDatePt(selectedDate)}',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.ink3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(flex: 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final appointment in appointmentsByDate) ...[
                            AppointmentCard(
                              appointment: appointment,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.lawyerAppointmentDetailRoute,
                                  arguments: appointment,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            height: AppDimensions.bottomPadding(context),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          LoadingSkeleton(
                            height: 80,
                            borderRadius: 20,
                            color: AppColors.surface2,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  error: (error, stack) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AppCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Text(
                                  'Erro ao carregar agenda',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(appointmentsProvider.notifier)
                                        .refresh();
                                  },
                                  child: Text(
                                    'Tentar novamente',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.ink,
        onPressed: () => _showCreateAppointmentBottomSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo evento',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showCreateAppointmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateAppointmentSheet(),
    );
  }

  String _formatDatePt(DateTime date) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }
}

class CreateAppointmentSheet extends ConsumerStatefulWidget {
  const CreateAppointmentSheet({super.key});

  @override
  ConsumerState<CreateAppointmentSheet> createState() =>
      _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState
    extends ConsumerState<CreateAppointmentSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedType = 'MEETING';
  DateTime? _selectedDateTime;
  String? _selectedProcessId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
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
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
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
            Text('Novo evento', style: AppTextStyles.h2),
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
              initialValue: _selectedType,
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
                setState(() => _selectedType = value ?? 'MEETING');
              },
            ),
            if (procedures.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedProcessId,
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
                          _selectedDateTime != null
                              ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                              : 'Selecionar',
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
                onPressed: _createAppointment,
                child: Text(
                  'Criar evento',
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
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
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

  void _createAppointment() async {
    if (_titleController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    try {
      await ref.read(appointmentActionsProvider).create({
        'title': _titleController.text,
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text,
        if (_selectedProcessId != null) 'processId': _selectedProcessId,
        'type': _selectedType,
        'scheduledAt': _selectedDateTime!.toIso8601String(),
        'durationMinutes': 60,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar: $e')));
      }
    }
  }
}
