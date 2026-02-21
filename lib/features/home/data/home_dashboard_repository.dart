import 'package:lms/core/network/api_constants.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';
import 'package:lms/features/attendance/shared/data/attendance_rerpository.dart';
import 'package:lms/features/auth/data/auth_api_service.dart';
import 'package:lms/features/attendance/view_attendance/data/models/attendance_summary_model.dart';

class HomeDashboardRepository {
  final AttendanceRepository attendanceRepo;
  final AuthApiService authApi;

  HomeDashboardRepository({
    required this.attendanceRepo,
    required this.authApi,
  });

  // ─────────────────────────────────────────────
  // LOAD HOME DASHBOARD DATA
  // ─────────────────────────────────────────────
  Future<HomeDashboardModel> loadDashboard() async {
    // 1️⃣ PROFILE
    final profileJson = await authApi.fetchProfile();

    print("📦 RAW PROFILE JSON:");
    print(profileJson);

    // ✅ SAFE USER NAME
    final String userName =
        profileJson['associates_name']?.toString() ??
        profileJson['name']?.toString() ??
        'User';

    // ✅ SAFE DESIGNATION FIX (CRITICAL)
    String designation = 'Employee';

    final designationRaw = profileJson['designation'];

    if (designationRaw is Map) {
      designation = designationRaw['name']?.toString() ?? designation;
    } else if (designationRaw != null) {
      designation = designationRaw.toString();
    } else if (profileJson['role'] is Map) {
      designation = profileJson['role']['name']?.toString() ?? designation;
    }

    // ✅ SAFE PROFILE IMAGE
    String? profileImageUrl;

    final profilePictureRaw = profileJson['profile_picture'];

    if (profilePictureRaw != null && profilePictureRaw.toString().isNotEmpty) {
      profileImageUrl =
          ApiConstants.imageBaseUrl + profilePictureRaw.toString();
    }

    print("👤 FINAL PROFILE:");
    print("Name: $userName");
    print("DesignationRaw: $designationRaw");
    print("DesignationFinal: $designation");
    print("ProfilePictureRaw: $profilePictureRaw");
    print("ProfileImageUrl: $profileImageUrl");

    // 2️⃣ ATTENDANCE SUMMARY (MONTH)
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final AttendanceSummary summary = await attendanceRepo.fetchSummary(
      monthKey,
    );

    print(
      '📦 Summary → workedMin=${summary.totalMinutes} '
      'expectedHrs=${summary.expectedWorkingHours}',
    );

    // 3️⃣ ATTENDANCE OVERVIEW (MONTHLY)
    final attendanceOverview = AttendanceOverview(
      workedMinutes: summary.totalMinutes,
      expectedMinutes: summary.expectedWorkingHours * 60,
    );

    // 4️⃣ QUICK STATS
    final stats = HomeStats(
      payableDays: summary.payableDays.toDouble(),
      lateDays: summary.lateDays,
      absentDays: summary.absentDays,
      totalLeaves: summary.totalLeaves,
    );

    // 5️⃣ DISTRIBUTION
    final distribution = AttendanceDistribution(
      worked: summary.workingDays.toDouble(),
      leave: summary.totalLeaves.toDouble(),
      absent: summary.absentDays.toDouble(),
      late: summary.lateDays.toDouble(),
    );

    // 6️⃣ TODAY STATUS
    final todayStatus = await _loadTodayAttendance();

    // 7️⃣ LAST 5 WORKING DAYS
    const int expectedMinutesPerDay = 540;

    print('📊 Loading last 5 days bars (expected=$expectedMinutesPerDay min)');

    final lastFiveDays = await _loadLastFiveDaysBars(expectedMinutesPerDay);

    return HomeDashboardModel(
      userName: userName,
      designation: designation,
      profileImageUrl: profileImageUrl,
      attendance: attendanceOverview,
      stats: stats,
      distribution: distribution,
      todayStatus: todayStatus,
      lastFiveDays: lastFiveDays,
    );
  }

  // ─────────────────────────────────────────────
  // TODAY CHECK-IN / CHECK-OUT
  // ─────────────────────────────────────────────
  Future<TodayAttendanceStatus> _loadTodayAttendance() async {
    final sessions = await attendanceRepo.fetchAttendanceToday();

    print('🕘 Today sessions count = ${sessions.length}');

    if (sessions.isEmpty) {
      return const TodayAttendanceStatus(isCheckedIn: false);
    }

    final latest = sessions.last;

    print(
      '🕘 Latest → in=${latest.checkInTime} '
      'out=${latest.checkOutTime}',
    );

    return TodayAttendanceStatus(
      isCheckedIn: latest.checkOutTime == null,
      checkInTime: latest.checkInTime,
      checkOutTime: latest.checkOutTime,
    );
  }

  // ─────────────────────────────────────────────
  // LAST 5 WORKING DAYS (SKIP SUNDAY)
  // ─────────────────────────────────────────────
  List<DateTime> _lastFiveWorkingDays() {
    final today = DateTime.now();
    final days = <DateTime>[];

    var cursor = today;

    while (days.length < 5) {
      if (cursor.weekday != DateTime.sunday) {
        days.add(DateTime(cursor.year, cursor.month, cursor.day));
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }

    print(
      '📅 Last 5 working days → '
      '${days.reversed.map((d) => d.toIso8601String().split("T").first).join(", ")}',
    );

    return days.reversed.toList();
  }

  // ─────────────────────────────────────────────
  // BUILD WEEKLY BARS
  // ─────────────────────────────────────────────
  Future<List<WeeklyAttendanceBar>> _loadLastFiveDaysBars(
    int expectedMinutesPerDay,
  ) async {
    const int maxAllowedMinutesPerDay = 650;

    final now = DateTime.now();

    final attendance = await attendanceRepo.fetchAttendance(
      month: now.month,
      year: now.year,
    );

    print('📦 Sessions fetched = ${attendance.sessions.length}');

    final Map<DateTime, int> workedByDate = {};

    for (final session in attendance.sessions) {
      final day = DateTime.parse(session.date);

      final dayKey = DateTime(day.year, day.month, day.day);

      int minutes = 0;

      if (session.durationMinutes != null) {
        minutes = session.durationMinutes!;
      } else if (session.checkOutTime == null) {
        minutes = DateTime.now().difference(session.checkInTime).inMinutes;
      }

      workedByDate[dayKey] = (workedByDate[dayKey] ?? 0) + minutes;

      print(
        '🧮 ${dayKey.toIso8601String().split("T").first} '
        '+$minutes min',
      );
    }

    final workingDays = _lastFiveWorkingDays();

    final bars = workingDays.map((day) {
      final worked = workedByDate[day] ?? 0;

      final cappedWorked = worked.clamp(0, maxAllowedMinutesPerDay);

      final isCapped = worked > maxAllowedMinutesPerDay;

      print(
        '📊 BAR ${day.toIso8601String().split("T").first} '
        'raw=$worked capped=$cappedWorked '
        'expected=$expectedMinutesPerDay '
        'cappedFlag=$isCapped',
      );

      return WeeklyAttendanceBar(
        date: day,
        workedMinutes: cappedWorked,
        expectedMinutes: expectedMinutesPerDay,
        isCapped: isCapped,
      );
    }).toList();

    print(
      ' Final bars → ' +
          bars
              .map(
                (b) =>
                    '${b.date.toIso8601String().split("T").first}: '
                    '${b.workedMinutes}/${b.expectedMinutes}'
                    '${b.isCapped ? " (capped)" : ""}',
              )
              .join(' | '),
    );

    return bars;
  }
}
