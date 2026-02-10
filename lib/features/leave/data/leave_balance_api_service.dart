import '../../../core/network/api_service.dart';

class LeaveBalanceApiService {
  final ApiService api;

  LeaveBalanceApiService(this.api);

  Future<List<dynamic>> fetchLeaveBalance() async {
    final response = await api.get('/employees/leave-balance');

    // API returns direct list
    return response;
  }
}
