import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/providers/notification_api_providers.dart';

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<Map<String, dynamic>>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final api = ref.read(notificationApiServiceProvider);
    return api.fetchMyNotifications();
  }

  Future<void> markAsRead(String id) async {
    final api = ref.read(notificationApiServiceProvider);

    // 1️⃣ Optimistic UI update
    final currentList = state.value ?? [];

    state = AsyncData([
      for (final n in currentList)
        if (n['id'] == id) {...n, 'is_read': true} else n,
    ]);

    // 2️⃣ Backend call
    try {
      await api.markAsRead(id);
    } catch (e) {
      // 3️⃣ Rollback on failure
      state = AsyncData(currentList);
      rethrow;
    }
  }
}
