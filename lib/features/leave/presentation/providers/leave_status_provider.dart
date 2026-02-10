import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/leave/data/models/leave_status_model.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/leave_status_api_service.dart';

final leaveStatusApiProvider = Provider<LeaveStatusApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return LeaveStatusApiService(api);
});

final leaveStatusProvider =
    AsyncNotifierProvider<LeaveStatusNotifier, List<LeaveStatus>>(
      LeaveStatusNotifier.new,
    );

class LeaveStatusNotifier extends AsyncNotifier<List<LeaveStatus>> {
  @override
  Future<List<LeaveStatus>> build() async {
    final api = ref.read(leaveStatusApiProvider);

    final list = await api.fetchLeaveStatus();

    return list.map<LeaveStatus>((e) => LeaveStatus.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> revokeLeave(String id, List<String> dates) async {
    final api = ref.read(leaveStatusApiProvider);

    await api.revokeLeave(requestId: id, dates: dates);

    await refresh();
  }
}
