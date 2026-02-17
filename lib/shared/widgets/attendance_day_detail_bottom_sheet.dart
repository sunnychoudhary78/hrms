import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/dashboard/data/models/attendance_day_data.dart';

class AttendanceDayDetailBottomSheet extends StatelessWidget {
  final DateTime date;
  final AttendanceDayData? data;

  const AttendanceDayDetailBottomSheet({
    super.key,
    required this.date,
    required this.data,
  });

  ////////////////////////////////////////////////////////////
  // SHOW METHOD
  ////////////////////////////////////////////////////////////

  static void show(
    BuildContext context, {
    required DateTime date,
    required AttendanceDayData? data,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AttendanceDayDetailBottomSheet(date: date, data: data),
    );
  }

  ////////////////////////////////////////////////////////////
  // STATUS COLOR
  ////////////////////////////////////////////////////////////

  Color _statusColor(String? status, ColorScheme scheme) {
    switch (status) {
      case "On-Time":
        return Colors.green;

      case "Late":
        return Colors.orange;

      case "Absent":
        return scheme.error;

      case "Holiday":
        return Colors.blue;

      case "On-Leave":
        return Colors.purple;

      default:
        return scheme.outline;
    }
  }

  ////////////////////////////////////////////////////////////
  // TIME FORMAT
  ////////////////////////////////////////////////////////////

  String _formatTime(DateTime? dt) {
    if (dt == null) return "--";
    return DateFormat('hh:mm a').format(dt);
  }

  ////////////////////////////////////////////////////////////
  // MAIN UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(date);

    final status = data?.status ?? "No Data";

    final hours = data?.totalHours ?? 0;

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //////////////////////////////////////////////////////
              // HANDLE
              //////////////////////////////////////////////////////
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              //////////////////////////////////////////////////////
              // DATE
              //////////////////////////////////////////////////////
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              //////////////////////////////////////////////////////
              // STATUS + HOURS
              //////////////////////////////////////////////////////
              Row(
                children: [
                  _statusBadge(context, status),

                  const Spacer(),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${hours.toStringAsFixed(1)} h",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),

                      Text(
                        "Working Hours",
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              //////////////////////////////////////////////////////
              // SESSIONS
              //////////////////////////////////////////////////////
              if (data?.sessions.isNotEmpty == true)
                ...data!.sessions.map(
                  (session) => _sessionTile(context, session),
                ),

              if (data?.sessions.isEmpty ?? true)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "No attendance sessions",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // STATUS BADGE
  ////////////////////////////////////////////////////////////

  Widget _statusBadge(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;

    final color = _statusColor(status, scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // SESSION TILE
  ////////////////////////////////////////////////////////////

  Widget _sessionTile(BuildContext context, AttendanceSessionData session) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: scheme.primary),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_formatTime(session.checkIn)}  →  ${_formatTime(session.checkOut)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${session.hours.toStringAsFixed(1)} hours",
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
