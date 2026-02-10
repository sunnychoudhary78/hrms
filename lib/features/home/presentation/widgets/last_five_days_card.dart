import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:lms/features/home/data/models/home_dashboard_model.dart';

class LastFiveDaysAttendanceCard extends StatelessWidget {
  final List<WeeklyAttendanceBar> days;

  const LastFiveDaysAttendanceCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    /// Max from BOTH worked & expected (worked already capped safely)
    final maxHours =
        days
            .map(
              (d) => d.workedMinutes > d.expectedMinutes
                  ? d.workedMinutes
                  : d.expectedMinutes,
            )
            .reduce((a, b) => a > b ? a : b) /
        60;

    final maxY = (maxHours * 1.25).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 5 Working Days',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 190, child: BarChart(_barChartData(maxY))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: Color(0xFF1565C0), label: 'Worked'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.green, label: 'Overtime'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.orange, label: 'Capped'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.grey, label: 'Expected'),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BAR CHART CONFIG
  // ─────────────────────────────────────────────

  BarChartData _barChartData(double maxY) {
    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceBetween,

      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, _, rod, __) {
            final d = days[group.x.toInt()];
            final worked = d.workedMinutes / 60;
            final expected = d.expectedMinutes / 60;
            final overtime = (worked - expected).clamp(0, double.infinity);

            return BarTooltipItem(
              'Worked: ${worked.toStringAsFixed(1)}h\n'
              'Expected: ${expected.toStringAsFixed(1)}h'
              '${overtime > 0 ? '\n+${overtime.toStringAsFixed(1)}h overtime' : ''}'
              '${d.isCapped ? '\n⚠ Checkout missing, hours capped' : ''}',
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                backgroundColor: Colors.black87,
              ),
            );
          },
        ),
      ),

      /// Expected reference line
      extraLinesData: ExtraLinesData(
        horizontalLines: days.map((d) {
          return HorizontalLine(
            y: d.expectedMinutes / 60,
            dashArray: [6, 4],
            color: Colors.grey.shade400,
            strokeWidth: 1,
          );
        }).toList(),
      ),

      gridData: FlGridData(
        show: true,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),

      borderData: FlBorderData(show: false),

      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            reservedSize: 34,
            getTitlesWidget: (value, _) =>
                Text('${value.toInt()}h', style: const TextStyle(fontSize: 11)),
          ),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _bottomTitle,
          ),
        ),
      ),

      barGroups: _barGroups(),
    );
  }

  // ─────────────────────────────────────────────
  // TWO BARS PER DAY
  // ─────────────────────────────────────────────

  List<BarChartGroupData> _barGroups() {
    return List.generate(days.length, (index) {
      final d = days[index];

      final worked = d.workedMinutes / 60;
      final expected = d.expectedMinutes / 60;

      final overtime = (worked - expected).clamp(0, double.infinity);
      final normalWorked = worked - overtime;

      final overtimeColor = d.isCapped
          ? Colors.orange.shade600
          : Colors.green.shade600;

      return BarChartGroupData(
        x: index,
        barsSpace: 6,
        barRods: [
          /// EXPECTED
          BarChartRodData(
            toY: expected,
            width: 12,
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),

          /// WORKED (with overtime / capped indication)
          BarChartRodData(
            toY: worked,
            width: 12,
            borderRadius: BorderRadius.circular(6),
            rodStackItems: [
              if (normalWorked > 0)
                BarChartRodStackItem(0, normalWorked, const Color(0xFF1565C0)),
              if (overtime > 0)
                BarChartRodStackItem(normalWorked, worked, overtimeColor),
            ],
          ),
        ],
      );
    });
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= days.length) {
      return const SizedBox.shrink();
    }

    final day = days[index].date;
    final label = DateFormat('E').format(day);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LEGEND DOT
// ─────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
