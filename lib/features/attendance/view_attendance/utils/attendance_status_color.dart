import 'package:flutter/material.dart';

class AttendanceStatusColor {
  static Color fromStatus(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'present':
      case 'on-time':
        return scheme.primary;

      case 'late':
      case 'half-day':
        return Colors.orange;

      case 'leave':
      case 'on-leave':
        return Colors.purple;

      case 'holiday':
        return scheme.primaryContainer;

      case 'absent':
        return Colors.red;

      default:
        return scheme.outlineVariant;
    }
  }
}
