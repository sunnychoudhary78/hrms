// lib/core/notifications/notification_router.dart
import 'notification_action.dart';
import 'notification_types.dart';

class NotificationRouter {
  /// Convert backend push / API notification into app action
  static NotificationAction resolve({
    required String? type,
    required Map<String, dynamic>? data,
  }) {
    switch (type) {
      // ───────── LEAVE ─────────

      case NotificationTypes.leaveRequestApproved:
      case NotificationTypes.leaveRequestRejected:
      case NotificationTypes.leaveRevoked:
        final leaveRequestId = data?['leaveRequestId'] as String?;
        if (leaveRequestId != null) {
          return OpenLeaveStatus(leaveRequestId: leaveRequestId);
        }
        return const OpenNotifications();

      // ───────── ATTENDANCE ─────────

      case NotificationTypes.attendanceAutoClosed:
        return OpenAttendance(date: data?['date'] as String?);

      case NotificationTypes.correctionRejected:
        final correctionId = data?['correctionId'] as String?;
        if (correctionId != null) {
          return OpenAttendanceCorrection(correctionId: correctionId);
        }
        return const OpenNotifications();

      // ───────── DEFAULT ─────────

      default:
        return const OpenNotifications();
    }
  }
}
