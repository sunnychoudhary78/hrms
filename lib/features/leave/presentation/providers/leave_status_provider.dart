import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms/features/leave/data/models/leave_status_model.dart';

import '../../../../core/providers/network_providers.dart';

import '../../data/leave_status_api_service.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

/// API Provider
final leaveStatusApiProvider = Provider<LeaveStatusApiService>((ref) {
  final api = ref.read(apiServiceProvider);

  return LeaveStatusApiService(api);
});

/// Leave Status Provider (USER-SCOPED)
final leaveStatusProvider =
    AsyncNotifierProvider.autoDispose<LeaveStatusNotifier, List<LeaveStatus>>(
      LeaveStatusNotifier.new,
    );

/// Notifier
class LeaveStatusNotifier extends AsyncNotifier<List<LeaveStatus>> {
  @override
  Future<List<LeaveStatus>> build() async {
    /// CRITICAL: rebuild when user changes
    ref.watch(authProvider);

    final api = ref.read(leaveStatusApiProvider);

    final list = await api.fetchLeaveStatus();

    return list.map<LeaveStatus>((e) => LeaveStatus.fromJson(e)).toList();
  }

  /// Manual Refresh
  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final data = await build();

      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Revoke Leave
  Future<void> revokeLeave(String id, List<String> dates) async {
    final api = ref.read(leaveStatusApiProvider);

    try {
      await api.revokeLeave(requestId: id, dates: dates);

      /// Refresh after revoke
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
