import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceStatusTiles extends StatelessWidget {
  final DateTime? punchInTime;
  final DateTime? punchOutTime;

  const AttendanceStatusTiles({
    super.key,
    required this.punchInTime,
    required this.punchOutTime,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF10B981); // emerald
    final warningColor = const Color(0xFFF59E0B); // amber

    return Row(
      children: [
        Expanded(
          child: _StatusTile(
            label: "Check In",
            time: punchInTime,
            color: accentColor,
            icon: Icons.login_rounded,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _StatusTile(
            label: "Check Out",
            time: punchOutTime,
            color: warningColor,
            icon: Icons.logout_rounded,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────

class _StatusTile extends StatelessWidget {
  final String label;
  final DateTime? time;
  final Color color;
  final IconData icon;

  const _StatusTile({
    required this.label,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = time != null
        ? DateFormat('hh:mm a').format(time!)
        : "--:--";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
