import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/dashboard/data/models/team_dashboard_model.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/team_dashboard_api_service.dart';

final teamDashboardApiProvider = Provider<TeamDashboardApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return TeamDashboardApiService(api);
});

final teamDashboardProvider =
    AsyncNotifierProvider<TeamDashboardNotifier, TeamDashboard>(
      TeamDashboardNotifier.new,
    );

class TeamDashboardNotifier extends AsyncNotifier<TeamDashboard> {
  @override
  Future<TeamDashboard> build() async {
    final api = ref.read(teamDashboardApiProvider);
    return api.fetchDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}
