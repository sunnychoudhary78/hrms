import 'package:flutter/material.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_summary_model.dart';

class AttendanceSummaryGrid extends StatelessWidget {
  final AttendanceSummary summary;

  const AttendanceSummaryGrid({super.key, required this.summary});

  Widget _tile(String t, String v, Color c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t),
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _tile("Working Days", "${summary.workingDays}", Colors.green),
        _tile("Late Days", "${summary.lateDays}", Colors.orange),
        _tile("Leaves", "${summary.totalLeaves}", Colors.blue),
        _tile("Absent", "${summary.absentDays}", Colors.red),
        _tile("Payable", "${summary.payableDays}", Colors.teal),
      ],
    );
  }
}
