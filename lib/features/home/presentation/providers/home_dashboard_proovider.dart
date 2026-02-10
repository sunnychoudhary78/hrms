import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/data/home_dashboard_repository.dart';
import 'package:lms/features/home/data/models/home_dashboard_model.dart';
import 'package:lms/features/attendance/shared/data/attendance_repository_provider.dart';
import 'package:lms/features/auth/presentation/providers/auth_api_providers.dart';

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>((
  ref,
) {
  return HomeDashboardRepository(
    attendanceRepo: ref.read(attendanceRepositoryProvider),
    authApi: ref.read(authApiServiceProvider),
  );
});

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardModel>(
      HomeDashboardNotifier.new,
    );

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardModel> {
  @override
  Future<HomeDashboardModel> build() async {
    final repo = ref.read(homeDashboardRepositoryProvider);
    return repo.loadDashboard();
  }
}
