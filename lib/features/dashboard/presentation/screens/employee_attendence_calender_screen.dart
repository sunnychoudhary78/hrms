import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/dashboard/presentation/providers/team_attendance_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/models/team_dashboard_model.dart';
import 'package:lms/shared/widgets/app_bar.dart';

class EmployeeAttendanceCalendarScreen extends ConsumerStatefulWidget {
  final TeamEmployee employee;

  const EmployeeAttendanceCalendarScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeAttendanceCalendarScreen> createState() =>
      _EmployeeAttendanceCalendarScreenState();
}

class _EmployeeAttendanceCalendarScreenState
    extends ConsumerState<EmployeeAttendanceCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _statusColor(String? status) {
    switch (status) {
      case "On-Time":
        return Colors.green;
      case "Late":
        return Colors.orange;
      case "Absent":
        return Colors.red;
      case "Holiday":
        return Colors.blue;
      case "On-Leave":
        return Colors.purple;
      default:
        return Colors.transparent;
    }
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final attendanceAsync = ref.watch(
      employeeAttendanceProvider(
        AttendanceParams(userId: widget.employee.userId, month: _focusedDay),
      ),
    );

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppAppBar(title: widget.employee.name),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(child: Text(error.toString())),

        data: (attendanceMap) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// 📅 Calendar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2035),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },

                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },

                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                    ),

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        final key = DateFormat('yyyy-MM-dd').format(day);

                        final status = attendanceMap[key];

                        if (status == null) return null;

                        final color = _statusColor(status);

                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🎨 Legend Section
                Text(
                  "Status Legend",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    _legendItem("On-Time", Colors.green),
                    _legendItem("Late", Colors.orange),
                    _legendItem("Absent", Colors.red),
                    _legendItem("Holiday", Colors.blue),
                    _legendItem("On-Leave", Colors.purple),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
