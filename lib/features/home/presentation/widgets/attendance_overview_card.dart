import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';

class AttendanceOverviewCard extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const AttendanceOverviewCard({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Monthly Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            /// 🟠 PIE + LEGEND (ROW)
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  /// Pie chart
                  Expanded(
                    flex: 3,
                    child: _AttendancePieChart(
                      distribution: dashboard.distribution,
                    ),
                  ),

                  SizedBox(width: 30),

                  /// Legend (right side)
                  Expanded(
                    flex: 2,
                    child: _PieLegend(distribution: dashboard.distribution),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            const SizedBox(height: 12),

            /// 🔵 HORIZONTAL BAR
            _WorkedVsExpectedBar(attendance: dashboard.attendance),
          ],
        ),
      ),
    );
  }
}

class _AttendancePieChart extends StatelessWidget {
  final AttendanceDistribution distribution;

  const _AttendancePieChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          _section(distribution.worked, Colors.green),
          _section(distribution.leave, Colors.orange),
          _section(distribution.absent, Colors.red),
          _section(distribution.late, Colors.blue),
        ],
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 45,
      showTitle: false,
    );
  }
}

class _PieLegend extends StatelessWidget {
  final AttendanceDistribution distribution;

  const _PieLegend({required this.distribution});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LegendItem(color: Colors.green, label: 'Worked'),
        SizedBox(height: 12),
        _LegendItem(color: Colors.orange, label: 'Leave'),
        SizedBox(height: 12),
        _LegendItem(color: Colors.red, label: 'Absent'),
        SizedBox(height: 12),
        _LegendItem(color: Colors.blue, label: 'Late'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _WorkedVsExpectedBar extends StatelessWidget {
  final AttendanceOverview attendance;

  const _WorkedVsExpectedBar({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final worked = attendance.workedHours;
    final expected = attendance.expectedHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModernProgressBar(
          label: 'Worked',
          value: worked,
          max: expected,
          color: Colors.green,
        ),

        const SizedBox(height: 14),

        _ModernProgressBar(
          label: 'Expected',
          value: expected,
          max: expected,
          color: Colors.blueGrey,
        ),
      ],
    );
  }
}

class _ModernProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;

  const _ModernProgressBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = max == 0 ? 0.0 : (value / max).clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label + value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} hrs',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// Background track
        Container(
          height: 16, // 🔥 thicker bar
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.85), color],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
