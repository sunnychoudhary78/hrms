import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_session_model.dart';

final activeSessionProvider =
    Provider.family<AttendanceSession?, List<AttendanceSession>>((
      ref,
      sessions,
    ) {
      try {
        return sessions.firstWhere((s) => s.checkOutTime == null);
      } catch (_) {
        return null;
      }
    });
