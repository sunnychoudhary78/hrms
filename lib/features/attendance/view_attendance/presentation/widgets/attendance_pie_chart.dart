import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendancePieChart extends StatelessWidget {
  final int present;
  final int absent;
  final int late;
  final int leave;

  const AttendancePieChart({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
  });

  int get total => present + absent + late + leave;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 4,
                  sections: [
                    _section("Present", present, Colors.green),
                    _section("Late", late, Colors.orange),
                    _section("Leave", leave, Colors.blue),
                    _section("Absent", absent, Colors.red),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legend("Present", present, Colors.green),
                _legend("Late", late, Colors.orange),
                _legend("Leave", leave, Colors.blue),
                _legend("Absent", absent, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(String t, int v, Color c) {
    if (v == 0) {
      return PieChartSectionData(value: 0);
    }

    return PieChartSectionData(
      value: v.toDouble(),
      color: c,
      radius: 30,
      title: "${((v / total) * 100).toStringAsFixed(0)}%",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget _legend(String t, int v, Color c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text("$t ($v)"),
      ],
    );
  }
}
