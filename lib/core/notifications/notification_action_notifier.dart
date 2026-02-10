// lib/core/notifications/notification_action_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_action.dart';

class NotificationActionNotifier extends Notifier<NotificationAction?> {
  @override
  NotificationAction? build() {
    return null; // no action by default
  }

  /// Emit a new notification action
  void emit(NotificationAction action) {
    state = action;
  }

  /// Clear after consuming
  void clear() {
    state = null;
  }
}

final notificationActionProvider =
    NotifierProvider<NotificationActionNotifier, NotificationAction?>(
      NotificationActionNotifier.new,
    );
