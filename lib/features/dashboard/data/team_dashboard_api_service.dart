import 'package:lms/features/dashboard/data/models/team_dashboard_model.dart';
import '../../../core/network/api_service.dart';

class TeamDashboardApiService {
  final ApiService api;

  TeamDashboardApiService(this.api);

  Future<TeamDashboard> fetchDashboard() async {
    final response = await api.get('/employees/team-dashboard');

    // 👇 IMPORTANT: go inside "data"
    return TeamDashboard.fromJson(response['data']);
  }
}
