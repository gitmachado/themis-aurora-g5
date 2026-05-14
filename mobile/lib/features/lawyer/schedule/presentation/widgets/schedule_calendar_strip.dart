import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../domain/entities/appointment.dart';

class ScheduleCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final ValueChanged<DateTime> onDateSelected;
  final String currentMode;
  final bool showHistory;

  const ScheduleCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onDateSelected,
    required this.currentMode,
    required this.showHistory,
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
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.currentMode != widget.currentMode) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    final baseDate = DateTime.now();
    final startDate = DateTime(baseDate.year, baseDate.month, baseDate.day)
        .subtract(const Duration(days: 60));
    final targetDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    final dayIndex = targetDate.difference(startDate).inDays;
    if (dayIndex >= 0 && dayIndex < 300) {
      final days = List.generate(300, (i) => startDate.add(Duration(days: i)));
      int monthsCount = 0;
      for (int i = 0; i <= dayIndex; i++) {
        if (i == 0 || days[i].day == 1) {
          monthsCount++;
        }
      }
      final screenWidth = MediaQuery.of(context).size.width;
      final itemCenterX = 16.0 + (monthsCount * 62.0) + (dayIndex * 62.0) + 27.0;
      final offset = itemCenterX - (screenWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _hasAppointmentOnDate(DateTime date) {
    return widget.appointments.any((app) {
      final isSameDate = app.scheduledAt.year == date.year &&
          app.scheduledAt.month == date.month &&
          app.scheduledAt.day == date.day;
      if (!isSameDate) return false;

      if (widget.showHistory) {
        return app.status == 'COMPLETED' || app.status == 'CANCELED';
      } else {
        return app.status == 'SCHEDULED';
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseDate = DateTime.now();
    final startDate = DateTime(baseDate.year, baseDate.month, baseDate.day)
        .subtract(const Duration(days: 60));
    final days = List.generate(300, (i) => startDate.add(Duration(days: i)));

    return SizedBox(
      height: 88,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 12),
          child: Row(
            children: [
              for (int i = 0; i < days.length; i++) ...[
                if (i == 0 || days[i].day == 1) ...[
                  Container(
                    width: 54,
                    height: 72,
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: AppColors.ink,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getMonthShortName(days[i].month).toUpperCase(),
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          days[i].year.toString(),
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                _buildDayButton(days[i]),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(DateTime date) {
    final selected = widget.selectedDate;
    bool isSelected = false;

    if (widget.currentMode == 'week') {
      final startOfWeek = DateTime(selected.year, selected.month, selected.day)
          .subtract(Duration(days: selected.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final d = DateTime(date.year, date.month, date.day);
      isSelected = d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(endOfWeek.add(const Duration(days: 1)));
    } else if (widget.currentMode == 'month') {
      isSelected = date.year == selected.year && date.month == selected.month;
    } else {
      isSelected = date.year == selected.year &&
          date.month == selected.month &&
          date.day == selected.day;
    }

    final hasAppointments = _hasAppointmentOnDate(date);

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: 54,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : AppColors.white,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.white : AppColors.ink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasAppointments) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            ],
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

  String _getMonthShortName(int month) => const [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ][month - 1];
}
