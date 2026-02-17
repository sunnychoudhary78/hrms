import '../../../core/network/api_service.dart';

class NotificationApiService {
  final ApiService api;

  NotificationApiService(this.api);

  // 📥 Fetch notifications
  Future<List<Map<String, dynamic>>> fetchMyNotifications() async {
    final response = await api.get('/notifications/my');

    final List list = response['data'];

    return list.cast<Map<String, dynamic>>();
  }

  // ✅ Mark as read
  Future<void> markAsRead(String id) async {
    await api.patch('/notifications/$id/read', {});
  }

  // 🗑️ DELETE notifications (single or multiple)
  Future<void> deleteNotifications(List<String> ids) async {
    await api.delete('/notifications', {"ids": ids});
  }
}
