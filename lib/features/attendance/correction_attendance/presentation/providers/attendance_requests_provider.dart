import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/providers/attendance_request_state.dart';
import 'package:lms/features/attendance/shared/data/attendance_rerpository.dart';
import '../../../shared/data/attendance_repository_provider.dart';

final attendanceRequestsProvider =
    AsyncNotifierProvider<AttendanceRequestsNotifier, AttendanceRequestsState>(
      AttendanceRequestsNotifier.new,
    );

class AttendanceRequestsNotifier
    extends AsyncNotifier<AttendanceRequestsState> {
  late AttendanceRepository _repo;

  @override
  Future<AttendanceRequestsState> build() async {
    debugPrint("🧱 AttendanceRequestsNotifier build()");

    _repo = ref.read(attendanceRepositoryProvider);

    final initial = AttendanceRequestsState.initial();
    state = AsyncData(initial);

    await fetchRequests();

    return state.value!;
  }

  // ───────────────── FETCH REQUESTS ─────────────────

  Future<void> fetchRequests() async {
    final current = state.value!;
    debugPrint("📥 Fetch attendance requests | status=${current.statusFilter}");

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final status = current.statusFilter == 'ALL'
          ? 'PENDING,APPROVED,REJECTED'
          : current.statusFilter;

      final list = await _repo.fetchAttendanceCorrections(status: status);

      debugPrint("✅ Requests fetched: ${list.length}");

      state = AsyncData(current.copyWith(isLoading: false, requests: list));
    } catch (e, st) {
      debugPrint("❌ Failed to load requests → $e");
      debugPrintStack(stackTrace: st);

      state = AsyncData(current.copyWith(isLoading: false));
      // ❌ DO NOT rethrow
    }
  }

  // ───────────────── CHANGE FILTER ─────────────────

  Future<void> changeStatus(String status) async {
    debugPrint("🔁 Change status filter → $status");

    final current = state.value!;
    state = AsyncData(current.copyWith(statusFilter: status));

    await fetchRequests();
  }

  // ───────────────── APPROVE / REJECT ─────────────────

  Future<void> updateStatus({
    required String id,
    required String status,
    String? note,
  }) async {
    debugPrint("📝 Update request → id=$id | status=$status");

    final current = state.value!;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      await _repo.updateCorrectionStatus(id: id, status: status, note: note);

      debugPrint("✅ Status updated");

      await fetchRequests();
    } catch (e, st) {
      debugPrint("❌ Update failed → $e");
      debugPrintStack(stackTrace: st);

      state = AsyncData(current.copyWith(isLoading: false));
      // ❌ DO NOT rethrow
    }
  }
}
