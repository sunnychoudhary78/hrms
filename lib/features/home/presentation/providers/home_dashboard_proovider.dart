import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/data/home_dashboard_repository.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';
import 'package:lms/features/attendance/shared/data/attendance_repository_provider.dart';
import 'package:lms/features/auth/presentation/providers/auth_provider.dart';
import 'package:lms/features/auth/presentation/providers/auth_api_providers.dart';

/// ─────────────────────────────────────────────
/// HOME DASHBOARD REPOSITORY PROVIDER
/// ─────────────────────────────────────────────
final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>((
  ref,
) {
  print("🏗️ Creating HomeDashboardRepository");

  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  final authApi = ref.read(authApiServiceProvider);

  print("📦 attendanceRepo type → ${attendanceRepo.runtimeType}");
  print("📦 authApi type → ${authApi.runtimeType}");

  return HomeDashboardRepository(
    attendanceRepo: attendanceRepo,
    authApi: authApi,
  );
});

/// ─────────────────────────────────────────────
/// HOME DASHBOARD STATE PROVIDER
/// ─────────────────────────────────────────────
final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardModel>(
      HomeDashboardNotifier.new,
    );

/// ─────────────────────────────────────────────
/// HOME DASHBOARD NOTIFIER
/// ─────────────────────────────────────────────
class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardModel> {
  @override
  Future<HomeDashboardModel> build() async {
    print("\n");
    print("══════════════════════════════════════");
    print("🚀 HomeDashboardNotifier.build START");
    print("══════════════════════════════════════");

    try {
      /// STEP 1 — AUTH STATE
      final auth = ref.watch(authProvider);

      print("👤 AUTH STATE:");
      print("   type → ${auth.runtimeType}");
      print("   profile type → ${auth.profile.runtimeType}");
      print("   profile value → ${auth.profile}");

      /// Check login
      if (auth.profile == null) {
        print("❌ AUTH PROFILE IS NULL");
        throw Exception("User not logged in");
      }

      print("✅ USER IS LOGGED IN");

      /// STEP 2 — REPOSITORY
      print("📡 Reading HomeDashboardRepository...");

      final repo = ref.read(homeDashboardRepositoryProvider);

      print("📦 repo type → ${repo.runtimeType}");

      /// STEP 3 — LOAD DASHBOARD
      print("📡 Calling repo.loadDashboard()...");

      final dashboard = await repo.loadDashboard();

      print("✅ DASHBOARD LOADED SUCCESSFULLY");

      print("📊 DASHBOARD SUMMARY:");
      print(
        "   userName → ${dashboard.userName} (${dashboard.userName.runtimeType})",
      );
      print(
        "   designation → ${dashboard.designation} (${dashboard.designation.runtimeType})",
      );
      print(
        "   profileImageUrl → ${dashboard.profileImageUrl} (${dashboard.profileImageUrl.runtimeType})",
      );

      print(
        "   attendance.workedMinutes → ${dashboard.attendance.workedMinutes}",
      );
      print(
        "   attendance.expectedMinutes → ${dashboard.attendance.expectedMinutes}",
      );

      print("   stats.payableDays → ${dashboard.stats.payableDays}");
      print("   stats.lateDays → ${dashboard.stats.lateDays}");
      print("   stats.absentDays → ${dashboard.stats.absentDays}");
      print("   stats.totalLeaves → ${dashboard.stats.totalLeaves}");

      print(
        "   todayStatus.isCheckedIn → ${dashboard.todayStatus.isCheckedIn}",
      );
      print(
        "   todayStatus.checkInTime → ${dashboard.todayStatus.checkInTime}",
      );
      print(
        "   todayStatus.checkOutTime → ${dashboard.todayStatus.checkOutTime}",
      );

      print("   lastFiveDays count → ${dashboard.lastFiveDays.length}");

      for (var day in dashboard.lastFiveDays) {
        print(
          "      ${day.date.toIso8601String()} "
          "worked=${day.workedMinutes} "
          "expected=${day.expectedMinutes} "
          "capped=${day.isCapped}",
        );
      }

      print("══════════════════════════════════════");
      print("🏁 HomeDashboardNotifier.build END");
      print("══════════════════════════════════════");
      print("\n");

      return dashboard;
    } catch (e, stack) {
      print("\n");
      print("══════════════════════════════════════");
      print("❌ HOME DASHBOARD CRASH DETECTED");
      print("══════════════════════════════════════");

      print("ERROR TYPE → ${e.runtimeType}");
      print("ERROR VALUE → $e");

      print("\n📍 STACK TRACE:");
      print(stack);

      print("══════════════════════════════════════");
      print("\n");

      rethrow;
    }
  }
}
