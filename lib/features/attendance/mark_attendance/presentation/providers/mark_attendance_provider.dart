import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/providers/global_loading_provider.dart';
import 'package:lms/core/providers/location_providers.dart';
import 'package:lms/core/services/location_service.dart';
import 'package:lms/features/attendance/shared/data/attendance_rerpository.dart';
import 'package:lms/features/attendance/mark_attendance/data/models/attendance_session_model.dart';
import 'package:lms/features/attendance/shared/data/attendance_repository_provider.dart';

final markAttendanceProvider =
    AsyncNotifierProvider<MarkAttendanceNotifier, List<AttendanceSession>>(
      MarkAttendanceNotifier.new,
    );

class MarkAttendanceNotifier extends AsyncNotifier<List<AttendanceSession>> {
  late AttendanceRepository _repo;
  late LocationService _locationService;

  @override
  Future<List<AttendanceSession>> build() async {
    _repo = ref.read(attendanceRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);

    return _loadToday();
  }

  Future<List<AttendanceSession>> _loadToday() async {
    final now = DateTime.now();
    final res = await _repo.fetchAttendance(month: now.month, year: now.year);
    return res.sessions;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadToday());
  }

  Future<Map<String, double>> _getUserLocation() async {
    final ready = await _locationService.ensureServiceAndPermission();
    if (!ready) {
      throw Exception("Location not available");
    }

    final pos = await _locationService.getCurrentLocation();
    if (pos == null) {
      throw Exception("Unable to fetch location");
    }

    return {"lat": pos.latitude, "lng": pos.longitude};
  }

  Future<void> punchIn() async {
    final loader = ref.read(globalLoadingProvider.notifier);

    try {
      loader.show("Checking location permission…");

      final ready = await _locationService.ensureServiceAndPermission();
      if (!ready) {
        throw Exception("Location not available");
      }

      loader.update("Fetching current location…");
      final pos = await _locationService.getCurrentLocation();
      if (pos == null) {
        throw Exception("Unable to fetch location");
      }

      loader.update("Marking attendance…");
      await _repo.punchIn({
        "source": "mobile",
        "location": {"lat": pos.latitude, "lng": pos.longitude},
      });

      loader.update("Refreshing sessions…");
      await refresh();
    } finally {
      loader.hide();
    }
  }

  Future<void> punchOut() async {
    final loader = ref.read(globalLoadingProvider.notifier);

    try {
      loader.show("Preparing punch out…");

      final sessions = state.value ?? [];

      final active = sessions.firstWhere(
        (s) => s.checkOutTime == null,
        orElse: () => throw Exception("No active session"),
      );

      if (active.source == 'remote') {
        loader.update("Marking remote punch out…");
        await _repo.punchOut({});
      } else {
        loader.update("Fetching location…");
        final location = await _getUserLocation();

        loader.update("Marking attendance…");
        await _repo.punchOut({"location": location});
      }

      loader.update("Refreshing sessions…");
      await refresh();
    } finally {
      loader.hide();
    }
  }

  Future<void> punchInRemote(String reason) async {
    await _repo.punchIn({
      "source": "remote",
      "remoteRequested": true,
      "remoteReason": reason,
    });
    await refresh();
  }
}
