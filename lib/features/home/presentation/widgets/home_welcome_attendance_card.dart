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
    final scheme = Theme.of(context).colorScheme;

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
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: scheme.onPrimary.withOpacity(.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    color: scheme.onPrimary.withOpacity(.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatusChip(text: statusText, color: statusColor),
                    const SizedBox(width: 12),
                    if (status.checkInTime != null)
                      Text(
                        isCheckedIn
                            ? 'Checked in at ${_fmt(status.checkInTime!)}'
                            : 'Last check-in ${_fmt(status.checkInTime!)}',
                        style: TextStyle(color: scheme.onPrimary, fontSize: 13),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _Avatar(name: name, imageUrl: imageUrl),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    return DateFormat('hh:mm a').format(t.toLocal());
  }
}

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

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.surface,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _initials(name),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
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
