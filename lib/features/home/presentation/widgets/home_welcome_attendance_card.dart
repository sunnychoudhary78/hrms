import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';

class HomeWelcomeAttendanceCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final TodayAttendanceStatus status;

  const HomeWelcomeAttendanceCard({
    super.key,
    required this.name,
    required this.role,
    required this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    final bool isCheckedIn = status.isCheckedIn;

    final Color statusColor = isCheckedIn ? Colors.green : Colors.orange;

    final String statusText = isCheckedIn ? 'Checked in' : 'Not checked in';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ───────── LEFT CONTENT ─────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Greeting
                Text(
                  greeting,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 6),

                /// Name
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                /// Role
                Text(
                  role,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 16),

                /// ───── Status row ─────
                Row(
                  children: [
                    _StatusChip(text: statusText, color: statusColor),

                    const SizedBox(width: 12),

                    if (status.checkInTime != null)
                      Text(
                        isCheckedIn
                            ? 'Checked in at ${_fmt(status.checkInTime!)}'
                            : 'Last check-in ${_fmt(status.checkInTime!)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          /// ───────── RIGHT AVATAR ─────────
          _Avatar(name: name, imageUrl: imageUrl),
        ],
      ),
    );
  }

  /// ✅ Always convert to local time before formatting
  String _fmt(DateTime t) {
    return DateFormat('hh:mm a').format(t.toLocal());
  }
}

/// ─────────────────────────────────────────────
/// STATUS CHIP
/// ─────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// AVATAR WIDGET
/// ─────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _initials(name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
