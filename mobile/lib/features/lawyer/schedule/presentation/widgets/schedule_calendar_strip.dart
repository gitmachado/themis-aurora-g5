import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../domain/entities/appointment.dart';

abstract class StripItem {}

class MonthStripItem extends StripItem {
  final DateTime date;
  MonthStripItem(this.date);
}

class DayStripItem extends StripItem {
  final DateTime date;
  DayStripItem(this.date);
}

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
  late List<StripItem> _stripItems;
  late Map<String, int> _dateToIndex;
  late Set<String> _appointmentsCache;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _buildStripItems();
    _updateAppointmentsCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _buildStripItems() {
    final baseDate = DateTime.now();
    final startDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
    ).subtract(const Duration(days: 60));
    _stripItems = [];
    _dateToIndex = {};

    for (int i = 0; i < 300; i++) {
      final date = startDate.add(Duration(days: i));
      if (i == 0 || date.day == 1) {
        _stripItems.add(MonthStripItem(date));
      }
      final dateKey = '${date.year}-${date.month}-${date.day}';
      _dateToIndex[dateKey] = _stripItems.length;
      _stripItems.add(DayStripItem(date));
    }
  }

  void _updateAppointmentsCache() {
    _appointmentsCache = {};
    for (final app in widget.appointments) {
      final matchesStatus = widget.showHistory
          ? (app.status == 'COMPLETED' || app.status == 'CANCELED')
          : (app.status == 'SCHEDULED');
      if (matchesStatus) {
        final d = app.scheduledAt;
        final key = '${d.year}-${d.month}-${d.day}';
        _appointmentsCache.add(key);
      }
    }
  }

  @override
  void didUpdateWidget(ScheduleCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldScroll = false;

    if (oldWidget.appointments != widget.appointments ||
        oldWidget.showHistory != widget.showHistory) {
      _updateAppointmentsCache();
    }

    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.currentMode != widget.currentMode) {
      shouldScroll = true;
    }

    if (shouldScroll) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    final targetKey =
        '${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}';
    final itemIndex = _dateToIndex[targetKey];
    if (itemIndex != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Largura de cada item é exatamente 62px lógicos (54 + 8 padding).
      // Centro do item é o padding inicial de 16px + offset do item + metade do item (31px).
      final itemCenterX = 16.0 + (itemIndex * 62.0) + 31.0;
      final offset = itemCenterX - (screenWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 8, top: 6, bottom: 12),
        itemCount: _stripItems.length,
        itemExtent: 62.0, // Garantia de layout O(1) e rolagem instantânea
        itemBuilder: (context, index) {
          final item = _stripItems[index];
          if (item is MonthStripItem) {
            return _buildMonthBlock(item.date);
          } else if (item is DayStripItem) {
            return _buildDayBlock(item.date);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMonthBlock(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 54,
        height: 72,
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
              _getMonthShortName(date.month).toUpperCase(),
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              date.year.toString(),
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
    );
  }

  Widget _buildDayBlock(DateTime date) {
    final selected = widget.selectedDate;
    bool isSelected = false;

    if (widget.currentMode == 'week') {
      final startOfWeek = DateTime(
        selected.year,
        selected.month,
        selected.day,
      ).subtract(Duration(days: selected.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final d = DateTime(date.year, date.month, date.day);
      isSelected =
          d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(endOfWeek.add(const Duration(days: 1)));
    } else if (widget.currentMode == 'month') {
      isSelected = date.year == selected.year && date.month == selected.month;
    } else {
      isSelected =
          date.year == selected.year &&
          date.month == selected.month &&
          date.day == selected.day;
    }

    final dateKey = '${date.year}-${date.month}-${date.day}';
    final hasAppointments = _appointmentsCache.contains(dateKey);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
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
      ),
    );
  }

  String _getDayName(int weekday) =>
      const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'][weekday - 1];

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
