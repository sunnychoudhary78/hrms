import '../../../../core/network/api_service.dart';

class LeaveApproveApiService {
  final ApiService api;

  LeaveApproveApiService(this.api);

  // 📥 Manager pending requests
  Future<List<dynamic>> fetchManagerRequests() async {
    final res = await api.get('leave-requests/manager/requests/all');

    if (res is Map && res['data'] is List) {
      return res['data'];
    }

    if (res is List) {
      return res;
    }

    throw Exception("Invalid manager request response");
  }

  // ✅ Approve
  Future<void> approveLeave(
    String requestId,
    String? comment,
    List<String> approvedDates,
  ) async {
    await api.patch('leave-requests/$requestId/status', {
      "approvedDatesInput": approvedDates,
      "action": "approve",
      "comment": comment ?? "",
    });
  }

  // ❌ Reject
  Future<void> rejectLeave(String requestId, String? comment) async {
    await api.patch('leave-requests/$requestId/status', {
      "action": "reject",
      "comment": comment ?? "",
    });
  }
}
