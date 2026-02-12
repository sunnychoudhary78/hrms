import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_action.dart';
import '../core/notifications/notification_router.dart';
import '../core/notifications/notification_action_notifier.dart';
import '../core/providers/notification_api_providers.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _pushInitialized = false;
  late final ProviderSubscription<NotificationAction?> _notificationSub;

  @override
  void initState() {
    super.initState();

    // 🔁 Auto-login AFTER widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).tryAutoLogin();
    });

    // 🔔 Notification action listener
    _notificationSub = ref.listenManual<NotificationAction?>(
      notificationActionProvider,
      (previous, next) {
        if (next != null && mounted) {
          _handleNotificationAction(next);
          ref.read(notificationActionProvider.notifier).clear();
        }
      },
    );
  }

  @override
  void dispose() {
    _notificationSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // ⏳ Auth Loading
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ❌ Not logged in
    if (authState.profile == null) {
      return const LoginScreen();
    }

    // ✅ Logged in
    _initPushIfNeeded();
    return const HomeScreen();
  }

  // ─────────────────────────────────────────────
  // 🔔 PUSH INIT
  // ─────────────────────────────────────────────
  void _initPushIfNeeded() {
    if (_pushInitialized) return;
    _pushInitialized = true;

    final pushService = ref.read(pushNotificationServiceProvider);

    pushService.init(
      onNotificationTap: (data) {
        final action = NotificationRouter.resolve(
          type: data['type'] as String?,
          data: data,
        );

        ref.read(notificationActionProvider.notifier).emit(action);
      },
      onTokenAvailable: (token) {
        final authState = ref.read(authProvider);

        if (authState.profile != null) {
          ref.read(authProvider.notifier).registerFcmTokenIfNeeded();
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🧭 NAVIGATION
  // ─────────────────────────────────────────────
  void _handleNotificationAction(NotificationAction action) {
    final nav = Navigator.of(context);

    switch (action) {
      case OpenLeaveStatus():
        nav.pushNamed(
          '/leave-status',
          arguments: {'highlightId': action.leaveRequestId},
        );
        break;

      case OpenLeaveApproval():
        nav.pushNamed(
          '/leave-approve',
          arguments: {'leaveRequestId': action.leaveRequestId},
        );
        break;

      case OpenAttendance():
        nav.pushNamed('/mark-attendance', arguments: {'date': action.date});
        break;

      case OpenAttendanceCorrection():
        nav.pushNamed(
          '/correct-attendance',
          arguments: {'correctionId': action.correctionId},
        );
        break;

      case OpenNotifications():
        nav.pushNamed('/notifications');
        break;

      case NoAction():
        break;
    }
  }
}
