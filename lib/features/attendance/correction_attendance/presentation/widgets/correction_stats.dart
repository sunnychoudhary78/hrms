import 'package:flutter/material.dart';
import '../../data/models/attendance_request_model.dart';

class CorrectionStats extends StatelessWidget {
  final List<AttendanceRequest> requests;

  const CorrectionStats({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final pendingCorrections = requests
        .where((e) => e.isCorrection && e.isPending)
        .length;

    final pendingRemote = requests
        .where((e) => e.isRemote && e.isPending)
        .length;

    return Row(
      children: [
        _StatCard(
          label: "Pending Corrections",
          value: pendingCorrections.toString(),
          color: scheme.tertiary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: "Pending Remote",
          value: pendingRemote.toString(),
          color: scheme.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
