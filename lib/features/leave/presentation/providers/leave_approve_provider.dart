import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/leave_approve_api_service.dart';

final leaveApproveApiProvider = Provider<LeaveApproveApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return LeaveApproveApiService(api);
});

final leaveApproveProvider =
    AsyncNotifierProvider<LeaveApproveNotifier, List<ManagerLeaveRequest>>(
      LeaveApproveNotifier.new,
    );

class LeaveApproveNotifier extends AsyncNotifier<List<ManagerLeaveRequest>> {
  @override
  Future<List<ManagerLeaveRequest>> build() async {
    final api = ref.read(leaveApproveApiProvider);

    final list = await api.fetchManagerRequests();

    return list
        .map<ManagerLeaveRequest>((e) => ManagerLeaveRequest.fromJson(e))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> approve(String id, String? comment, List<String> dates) async {
    final api = ref.read(leaveApproveApiProvider);

    await api.approveLeave(id, comment, dates);

    await refresh();
  }

  Future<void> reject(String id, String? comment) async {
    final api = ref.read(leaveApproveApiProvider);

    await api.rejectLeave(id, comment);

    await refresh();
  }
}
