import 'package:flutter/material.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_summary_model.dart';

class AttendanceSummaryGrid extends StatelessWidget {
  final AttendanceSummary summary;

  const AttendanceSummaryGrid({super.key, required this.summary});

  Widget _tile(BuildContext context, String t, String v, Color c) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(
            v,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _tile(
          context,
          "Working Days",
          "${summary.workingDays}",
          scheme.primary,
        ),
        _tile(context, "Late Days", "${summary.lateDays}", scheme.tertiary),
        _tile(context, "Leaves", "${summary.totalLeaves}", scheme.secondary),
        _tile(context, "Absent", "${summary.absentDays}", scheme.error),
        _tile(
          context,
          "Payable",
          "${summary.payableDays}",
          scheme.primaryContainer,
        ),
      ],
    );
  }
}
