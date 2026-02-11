import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';

class AttendanceColors {
  static const worked = Color(0xFF16A34A);
  static const overtime = Color(0xFF22C55E);
  static const leave = Color(0xFFF59E0B);
  static const absent = Color(0xFFDC2626);
  static const late = Color(0xFF7C3AED);
  static const expected = Color(0xFF94A3B8);
}

class LastFiveDaysAttendanceCard extends StatelessWidget {
  final List<WeeklyAttendanceBar> days;

  const LastFiveDaysAttendanceCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
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
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 5 Working Days',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 190, child: BarChart(_barChartData(context, maxY))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: AttendanceColors.worked, label: 'Worked'),
              SizedBox(width: 12),
              _LegendDot(color: AttendanceColors.overtime, label: 'Overtime'),
              SizedBox(width: 12),
              _LegendDot(color: AttendanceColors.leave, label: 'Capped'),
              SizedBox(width: 12),
              _LegendDot(color: AttendanceColors.expected, label: 'Expected'),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _barChartData(BuildContext context, double maxY) {
    final scheme = Theme.of(context).colorScheme;

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
              TextStyle(
                color: scheme.onInverseSurface,
                fontSize: 12,
                backgroundColor: scheme.inverseSurface,
              ),
            );
          },
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: days.map((d) {
          return HorizontalLine(
            y: d.expectedMinutes / 60,
            dashArray: [6, 4],
            color: scheme.outlineVariant,
            strokeWidth: 1,
          );
        }).toList(),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: scheme.outlineVariant, strokeWidth: 1),
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
      barGroups: _barGroups(context),
    );
  }

  List<BarChartGroupData> _barGroups(BuildContext context) {
    return List.generate(days.length, (index) {
      final d = days[index];
      final worked = d.workedMinutes / 60;
      final expected = d.expectedMinutes / 60;
      final overtime = (worked - expected).clamp(0, double.infinity);
      final normalWorked = worked - overtime;

      final overtimeColor = d.isCapped
          ? AttendanceColors.leave
          : AttendanceColors.overtime;

      return BarChartGroupData(
        x: index,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: expected,
            width: 12,
            color: AttendanceColors.expected,
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            toY: worked,
            width: 12,
            borderRadius: BorderRadius.circular(6),
            rodStackItems: [
              if (normalWorked > 0)
                BarChartRodStackItem(0, normalWorked, AttendanceColors.worked),
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

  BoxDecoration _cardDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

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
