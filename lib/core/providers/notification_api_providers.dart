import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/services/push_notification_service.dart';
import 'network_providers.dart';
import '../../features/notifications/data/notification_api_service.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return NotificationApiService(api);
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return PushNotificationService(tokenStorage);
});
