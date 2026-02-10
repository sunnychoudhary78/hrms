import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/leave_apply_api_service.dart';

final leaveApplyApiProvider = Provider<LeaveApplyApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return LeaveApplyApiService(api);
});

final leaveApplyProvider = AsyncNotifierProvider<LeaveApplyNotifier, void>(
  LeaveApplyNotifier.new,
);

class LeaveApplyNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitLeave({
    required Map<String, dynamic> data,
    File? document,
  }) async {
    final api = ref.read(leaveApplyApiProvider);

    state = const AsyncLoading();

    try {
      await api.sendLeaveRequestWithDocument(data: data, document: document);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
