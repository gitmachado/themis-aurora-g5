import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../domain/entities/appointment.dart';

class ScheduleCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final ValueChanged<DateTime> onDateSelected;

  const ScheduleCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onDateSelected,
  });

  @override
  State<ScheduleCalendarStrip> createState() => _ScheduleCalendarStripState();
}

class _ScheduleCalendarStripState extends State<ScheduleCalendarStrip> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(ScheduleCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    final startOfWeek = _getStartOfWeek(widget.selectedDate);
    final dayIndex = widget.selectedDate.difference(startOfWeek).inDays;
    final offset = dayIndex * 70.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _hasAppointmentOnDate(DateTime date) {
    return widget.appointments.any((app) =>
        app.scheduledAt.year == date.year &&
        app.scheduledAt.month == date.month &&
        app.scheduledAt.day == date.day);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _getStartOfWeek(DateTime.now());
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return SizedBox(
      height: 88,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              for (final date in days) ...[
                _buildDayButton(date),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(DateTime date) {
    final isSelected = date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;
    final hasAppointments = _hasAppointmentOnDate(date);

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: 54,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getDayName(date.weekday),
              style: AppTextStyles.tiny.copyWith(
                color: isSelected ? AppColors.white : AppColors.ink3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.white : AppColors.ink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            if (hasAppointments)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow : AppColors.yellow,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 4, height: 4),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) => const [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
    'Dom',
  ][weekday - 1];
}
