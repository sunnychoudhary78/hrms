import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/leave_balance_model.dart';
import '../utils/leave_color_mapper.dart';

class LeavePieChart extends StatelessWidget {
  final List<LeaveBalance> leaves;

  const LeavePieChart({super.key, required this.leaves});

  @override
  Widget build(BuildContext context) {
    final totalAvailable = leaves.fold<double>(0, (s, l) => s + l.available);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 90,
                  startDegreeOffset: -90,
                  sections: leaves.map((l) {
                    final percent = (l.available / totalAvailable) * 100;

                    return PieChartSectionData(
                      value: l.available,
                      color: LeaveColorMapper.colorFor(l.name),
                      radius: 40,
                      title: '${percent.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),

              /// Center summary (unchanged)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Available",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalAvailable.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Days",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
