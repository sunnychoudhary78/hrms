import 'package:lms/features/attendance/correction_attendance/data/models/attendance_request_model.dart';
import 'package:lms/features/attendance/mark_attendance/data/models/attendance_session_model.dart';
import 'package:lms/features/attendance/shared/data/attendence_api_service.dart';
import 'package:lms/features/attendance/shared/data/models/attendance_response_model.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_summary_model.dart';

class AttendanceRepository {
  final AttendanceApiService api;

  AttendanceRepository(this.api);

  // ─────────────────────────────────────────────
  // MONTHLY ATTENDANCE
  // ─────────────────────────────────────────────

  Future<AttendanceResponse> fetchAttendance({
    required int month,
    required int year,
  }) async {
    final res = await api.fetchAttendance(month: month, year: year);
    return AttendanceResponse.fromJson(res);
  }

  // ─────────────────────────────────────────────
  // SUMMARY (USED BY HOME DASHBOARD)
  // ─────────────────────────────────────────────

  Future<AttendanceSummary> fetchSummary(String ym) async {
    final res = await api.fetchSummary(ym);
    return AttendanceSummary.fromJson(res);
  }

  // ─────────────────────────────────────────────
  // ✅ NEW: TODAY ATTENDANCE (HOME DASHBOARD)
  // ─────────────────────────────────────────────

  Future<List<AttendanceSession>> fetchAttendanceToday() async {
    final now = DateTime.now();

    final res = await api.fetchAttendance(month: now.month, year: now.year);

    final attendance = AttendanceResponse.fromJson(res);

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    return attendance.sessions
        .where((s) => isSameDay(s.checkInTime, now))
        .toList();
  }

  // ─────────────────────────────────────────────
  // CHECK IN / OUT
  // ─────────────────────────────────────────────

  Future<void> punchIn(Map<String, dynamic> body) => api.punchIn(body);

  Future<void> punchOut(Map<String, dynamic> body) => api.punchOut(body);

  // ─────────────────────────────────────────────
  // CORRECTIONS (EMPLOYEE)
  // ─────────────────────────────────────────────

  Future<void> requestCorrection(Map<String, dynamic> body) =>
      api.requestCorrection(body);

  // ─────────────────────────────────────────────
  // MANAGER: FETCH CORRECTIONS
  // ─────────────────────────────────────────────

  Future<List<AttendanceRequest>> fetchAttendanceCorrections({
    required String status,
  }) async {
    final List list = await api.fetchAttendanceCorrectionsManaged(
      status: status,
    );

    return list
        .map((e) => AttendanceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────
  // MANAGER: APPROVE / REJECT
  // ─────────────────────────────────────────────

  Future<void> updateCorrectionStatus({
    required String id,
    required String status,
    String? note,
  }) async {
    await api.updateCorrectionStatus(
      id: id,
      body: {'status': status, if (note != null) 'note': note},
    );
  }
}
