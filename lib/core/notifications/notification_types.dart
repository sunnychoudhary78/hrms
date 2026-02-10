// lib/core/notifications/notification_types.dart

/// Backend notification `type` values
abstract class NotificationTypes {
  // Leave
  static const leaveRequestApproved = 'leave_request_approved';
  static const leaveRequestRejected = 'leave_request_rejected';
  static const leaveRevoked = 'leave_revoked';

  // Attendance
  static const attendanceAutoClosed = 'attendance_auto_closed';
  static const correctionRejected = 'correction_rejected';

  // Fallback
  static const unknown = 'unknown';
}
