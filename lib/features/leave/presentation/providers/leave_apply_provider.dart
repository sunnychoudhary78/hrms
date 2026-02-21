import 'dart:io';
import 'package:flutter/cupertino.dart';
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

    debugPrint("🚀 LeaveApplyNotifier.submitLeave called");
    debugPrint("📦 Data: $data");
    debugPrint("📄 Document: ${document?.path}");

    state = const AsyncLoading();

    try {
      final response = await api.sendLeaveRequestWithDocument(
        data: data,
        document: document,
      );

      debugPrint("✅ Leave apply success");
      debugPrint("📦 Response: $response");

      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint("❌ LeaveApplyNotifier error: $e");

      state = AsyncError(e, st);

      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
