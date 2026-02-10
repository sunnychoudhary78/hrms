import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/shared/data/attendance_rerpository.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_aggregate_model.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_summary_model.dart';
import 'package:lms/features/attendance/shared/data/attendance_repository_provider.dart';

final viewAttendanceProvider =
    AsyncNotifierProvider<ViewAttendanceNotifier, ViewAttendanceState>(
      ViewAttendanceNotifier.new,
    );

/// ───────────────── STATE ─────────────────

class ViewAttendanceState {
  final List<AttendanceAggregate> aggregates;
  final AttendanceSummary? summary;

  const ViewAttendanceState({required this.aggregates, required this.summary});
}

/// ───────────────── NOTIFIER ─────────────────

class ViewAttendanceNotifier extends AsyncNotifier<ViewAttendanceState> {
  late AttendanceRepository _repo;

  /// 🔑 keep track of current month (needed for refresh after correction)
  late DateTime _focusedMonth;

  @override
  Future<ViewAttendanceState> build() async {
    debugPrint("🧱 ViewAttendanceNotifier build()");

    _repo = ref.read(attendanceRepositoryProvider);
    _focusedMonth = DateTime.now();

    return _loadMonth(_focusedMonth);
  }

  // ───────────────── LOAD MONTH ─────────────────

  Future<ViewAttendanceState> _loadMonth(DateTime d) async {
    debugPrint("📅 Load attendance → ${d.month}/${d.year}");

    final res = await _repo.fetchAttendance(month: d.month, year: d.year);

    final summary = await _repo.fetchSummary(
      "${d.year}-${d.month.toString().padLeft(2, '0')}",
    );

    return ViewAttendanceState(aggregates: res.aggregates, summary: summary);
  }

  // ───────────────── CHANGE MONTH ─────────────────

  Future<void> changeMonth(DateTime d) async {
    debugPrint("🗓️ Change month → ${d.month}/${d.year}");

    _focusedMonth = d;
    state = const AsyncLoading();
    state = AsyncData(await _loadMonth(d));
  }

  // ───────────────── REQUEST CORRECTION ─────────────────

  Future<void> requestAttendanceCorrection({
    required DateTime date,
    required TimeOfDay checkIn,
    TimeOfDay? checkOut,
    required String reason,
  }) async {
    debugPrint("📝 Request attendance correction");

    String toIso(DateTime d, TimeOfDay t) {
      return DateTime(
        d.year,
        d.month,
        d.day,
        t.hour,
        t.minute,
      ).toIso8601String();
    }

    final body = {
      "targetDate": date.toIso8601String().split('T').first,
      "proposedCheckIn": toIso(date, checkIn),
      if (checkOut != null) "proposedCheckOut": toIso(date, checkOut),
      "reason": reason,
    };

    debugPrint("📤 Correction payload → $body");

    try {
      await _repo.requestCorrection(body);

      debugPrint("✅ Correction request submitted");

      // 🔄 refresh current month (calendar + summary)
      await changeMonth(_focusedMonth);
    } catch (e, st) {
      debugPrint("❌ Correction request failed → $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
