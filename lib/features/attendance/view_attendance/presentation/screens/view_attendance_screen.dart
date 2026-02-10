import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/dialogs/request_correction_dialog.dart';
import 'package:lms/features/attendance/view_attendance/presentation/providers/view_attendance_provider.dart';
import 'package:lms/features/attendance/view_attendance/presentation/widgets/attendance_calender.dart';
import 'package:lms/features/attendance/view_attendance/presentation/widgets/view_attendance_header.dart';
import '../widgets/attendance_summary_grid.dart';
import '../widgets/attendance_pie_chart.dart';
import '../../../../home/presentation/widgets/app_drawer.dart';

class ViewAttendanceScreen extends ConsumerStatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  ConsumerState<ViewAttendanceScreen> createState() =>
      _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends ConsumerState<ViewAttendanceScreen> {
  DateTime focused = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(viewAttendanceProvider);

    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text("Employee Attendance"),
        centerTitle: true,
      ),

      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (state) {
          final aggregates = state.aggregates;
          final summary = state.summary;

          if (summary == null) {
            return const Center(child: Text("No summary available"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👤 Header
                const ViewAttendanceHeader(),

                const SizedBox(height: 24),

                /// 📅 Calendar Section
                _Section(
                  title: "Attendance Calendar",
                  child: AttendanceCalendar(
                    focusedDay: focused,
                    selectedDay: selectedDay,
                    aggregates: aggregates,
                    onMonthChange: (d) {
                      focused = d;
                      ref.read(viewAttendanceProvider.notifier).changeMonth(d);
                    },
                    onDaySelected: (d) {
                      setState(() => selectedDay = d);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// ✏️ Correction CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_calendar_rounded),
                    label: const Text("Request Attendance Correction"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      showRequestCorrectionDialog(
                        context: context,
                        selectedDate: selectedDay ?? DateTime.now(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                /// 📊 Summary
                _Section(
                  title: "Monthly Summary",
                  child: AttendanceSummaryGrid(summary: summary),
                ),

                const SizedBox(height: 28),

                /// 🍩 Breakdown
                _Section(
                  title: "Attendance Breakdown",
                  child: AttendancePieChart(
                    present: summary.workingDays,
                    absent: summary.absentDays,
                    late: summary.lateDays,
                    leave: summary.totalLeaves,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// 🔹 Section Wrapper (standard HR pattern)
/// ─────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
