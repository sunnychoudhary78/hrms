import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:lms/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationList extends ConsumerWidget {
  final List<dynamic> notifications;

  const NotificationList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final n = notifications[index];

        final String id = n["id"];

        final bool isUnread = n["is_read"] == false;

        final DateTime createdAt =
            DateTime.tryParse(n["createdAt"] ?? "") ?? DateTime.now();

        return Dismissible(
          key: ValueKey(id),

          direction: DismissDirection.endToStart,

          // red delete background
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 26),
          ),

          // confirmation dialog
          confirmDismiss: (_) async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Delete notification"),
                  content: const Text(
                    "Are you sure you want to delete this notification?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );

            return confirm ?? false;
          },

          // delete action
          onDismissed: (_) {
            ref.read(notificationProvider.notifier).deleteNotification(id);
          },

          child: NotificationTile(
            icon: _iconForType(n["type"]),
            title: n["title"] ?? "Notification",
            subtitle: n["message"] ?? "",
            time: _formatTime(createdAt),
            isUnread: isUnread,
            onTap: () {
              if (isUnread) {
                ref.read(notificationProvider.notifier).markAsRead(id);
              }
            },
          ),
        );
      },
    );
  }

  // 🧠 backend type → icon
  IconData _iconForType(String? type) {
    switch (type) {
      case 'attendance_auto_closed':
        return Icons.timer_off;
      case 'correction_rejected':
        return Icons.cancel;
      case 'leave_request_approved':
        return Icons.check_circle;
      case 'leave_revoked':
        return Icons.undo;
      default:
        return Icons.notifications;
    }
  }

  // ⏱ time formatter (this part was already correct)
  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }
}
