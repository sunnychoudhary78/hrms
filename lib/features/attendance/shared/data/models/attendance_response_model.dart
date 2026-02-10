import '../../../mark_attendance/data/models/attendance_session_model.dart';
import '../../../view_attendance/data/models/attendance_aggregate_model.dart';

class AttendanceResponse {
  final List<AttendanceSession> sessions;
  final List<AttendanceAggregate> aggregates;

  AttendanceResponse({required this.sessions, required this.aggregates});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => AttendanceSession.fromJson(e))
          .toList(),

      aggregates: (json['aggregates'] as List? ?? [])
          .map((e) => AttendanceAggregate.fromJson(e))
          .toList(),
    );
  }
}
