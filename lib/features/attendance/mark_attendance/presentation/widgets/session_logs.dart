import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_session_model.dart';

class SessionLogs extends StatelessWidget {
  final List<AttendanceSession> sessions;

  const SessionLogs({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text("No sessions yet", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: sessions.map((s) {
        final bool isOngoing = s.checkOutTime == null;

        final DateTime inTime = s.checkInTime.toLocal();
        final DateTime? outTime = s.checkOutTime?.toLocal();

        final String dateLabel = DateFormat('EEE, MMM dd yyyy').format(inTime);

        final String punchInLabel = DateFormat('hh:mm a').format(inTime);

        final String punchOutLabel = isOngoing
            ? 'Now'
            : DateFormat('hh:mm a').format(outTime!);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───── STATUS ICON ─────
              CircleAvatar(
                backgroundColor: isOngoing
                    ? const Color(0xFF6366F1).withOpacity(.1)
                    : Colors.grey[100],
                child: Icon(
                  isOngoing ? Icons.timer_outlined : Icons.check_circle_outline,
                  color: isOngoing ? const Color(0xFF6366F1) : Colors.grey,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // ───── DETAILS ─────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📅 DATE
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 🟢 STATUS TEXT
                    Text(
                      isOngoing ? "Ongoing Session" : "Completed Session",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ⏱ IN / OUT TIME
                    Text(
                      "In: $punchInLabel  •  Out: $punchOutLabel",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ───── DURATION ─────
              if (!isOngoing)
                Text(
                  _calculateDiff(inTime, outTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981), // emerald
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _calculateDiff(DateTime start, DateTime? end) {
    if (end == null) return "";

    final diff = end.difference(start);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return "${hours}h ${minutes}m";
  }
}
