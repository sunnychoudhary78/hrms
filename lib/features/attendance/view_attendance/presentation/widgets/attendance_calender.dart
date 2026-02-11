import 'package:flutter/material.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_aggregate_model.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<AttendanceAggregate> aggregates;
  final Function(DateTime) onMonthChange;
  final ValueChanged<DateTime> onDaySelected;

  const AttendanceCalendar({
    super.key,
    required this.focusedDay,
    required this.aggregates,
    required this.onMonthChange,
    required this.onDaySelected,
    this.selectedDay,
  });

  AttendanceAggregate _forDay(DateTime d) {
    return aggregates.firstWhere(
      (a) =>
          a.date.year == d.year &&
          a.date.month == d.month &&
          a.date.day == d.day,
      orElse: () => AttendanceAggregate.empty(d),
    );
  }

  Color _color(BuildContext context, DateTime d) {
    final scheme = Theme.of(context).colorScheme;
    final status = _forDay(d).status.toLowerCase();

    switch (status) {
      case 'present':
        return scheme.primary;
      case 'late':
      case 'half-day':
        return scheme.tertiary;
      case 'leave':
        return scheme.secondary;
      case 'holiday':
        return scheme.primaryContainer;
      default:
        return scheme.errorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        onPageChanged: onMonthChange,
        selectedDayPredicate: (d) => isSameDay(d, selectedDay),
        onDaySelected: (selected, _) => onDaySelected(selected),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, d, __) => _cell(context, d, _color(context, d)),
          todayBuilder: (_, d, __) =>
              _cell(context, d, _color(context, d), isToday: true),
          selectedBuilder: (_, d, __) =>
              _cell(context, d, _color(context, d), isSelected: true),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime d,
    Color c, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: scheme.primary, width: 1.5)
            : isSelected
            ? Border.all(color: scheme.primary, width: 1.8)
            : null,
      ),
      child: Text(
        "${d.day}",
        style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
    );
  }
}
