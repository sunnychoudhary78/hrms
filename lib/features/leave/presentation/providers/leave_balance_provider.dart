import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/leave_balance_api_service.dart';
import '../../data/models/leave_balance_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final leaveBalanceApiProvider = Provider<LeaveBalanceApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return LeaveBalanceApiService(api);
});

final leaveBalanceProvider =
    AsyncNotifierProvider<LeaveBalanceNotifier, List<LeaveBalance>>(
      () => LeaveBalanceNotifier(),
    );

class LeaveBalanceNotifier extends AsyncNotifier<List<LeaveBalance>> {
  @override
  Future<List<LeaveBalance>> build() async {
    // 🔄 Rebuild whenever auth changes
    ref.watch(authProvider);

    final api = ref.read(leaveBalanceApiProvider);

    final res = await api.fetchLeaveBalance();

    return res.map<LeaveBalance>((e) => LeaveBalance.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}
