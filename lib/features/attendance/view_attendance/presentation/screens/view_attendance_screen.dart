import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/dialogs/request_correction_dialog.dart';
import 'package:lms/features/attendance/view_attendance/presentation/providers/view_attendance_provider.dart';
import 'package:lms/features/attendance/view_attendance/presentation/widgets/attendance_calender.dart';
import 'package:lms/features/attendance/view_attendance/presentation/widgets/view_attendance_header.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/widgets/app_bar.dart';
import '../widgets/attendance_summary_grid.dart';
import '../widgets/attendance_pie_chart.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(viewAttendanceProvider);

    return Scaffold(
      appBar: const AppAppBar(title: "View Attendance"),
      drawer: const AppDrawer(),
      backgroundColor: scheme.surfaceContainerLowest,
      body: async.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: scheme.primary)),

        error: (e, _) => Center(
          child: Text(e.toString(), style: TextStyle(color: scheme.error)),
        ),

        data: (state) {
          final aggregates = state.aggregates;
          final summary = state.summary;

          if (summary == null) {
            return Center(
              child: Text(
                "No summary available",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(viewAttendanceProvider.notifier)
                  .changeMonth(focused);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ViewAttendanceHeader(),
                  const SizedBox(height: 24),

                  /// ───────────── CALENDAR CARD ─────────────
                  _Section(
                    title: "Attendance Calendar",
                    child: AttendanceCalendar(
                      focusedDay: focused,
                      selectedDay: selectedDay,
                      aggregates: aggregates,
                      onMonthChange: (d) {
                        setState(() {
                          focused = d;
                        });

                        ref
                            .read(viewAttendanceProvider.notifier)
                            .changeMonth(d);
                      },
                      onDaySelected: (d) {
                        setState(() => selectedDay = d);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ───────────── CORRECTION BUTTON ─────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_calendar_rounded),
                      label: const Text("Request Attendance Correction"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
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

                  /// ───────────── SUMMARY GRID ─────────────
                  _Section(
                    title: "Monthly Summary",
                    child: AttendanceSummaryGrid(summary: summary),
                  ),

                  const SizedBox(height: 28),

                  /// ───────────── PIE CHART ─────────────
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
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
