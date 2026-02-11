import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/providers/global_loading_provider.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/attendance_selectors.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/mark_attendance_provider.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/company_settings_provider.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/widgets/attendance_status_tile.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/widgets/mark_attendance_header.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/widgets/app_bar.dart';
import '../widgets/live_clock_card.dart';
import '../widgets/session_logs.dart';
import '../widgets/modern_punch_button.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  DateTime now = DateTime.now();

  bool isRemoteMode = false;
  String? remoteReason;

  @override
  void initState() {
    super.initState();

    /// 🔥 Global loader listener
    ref.listen<AsyncValue<List<dynamic>>>(markAttendanceProvider, (
      previous,
      next,
    ) {
      final loader = ref.read(globalLoadingProvider.notifier);

      if (next.isLoading) {
        loader.show();
      } else {
        loader.hide();
      }

      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final attendanceAsync = ref.watch(markAttendanceProvider);
    final settingsAsync = ref.watch(companySettingsProvider);

    final dayName = DateFormat('EEEE').format(now);

    return Scaffold(
      appBar: AppAppBar(title: "Mark Attendance"),
      drawer: AppDrawer(),
      backgroundColor: scheme.surfaceContainerLowest,
      body: attendanceAsync.when(
        loading: () => const SizedBox(), // no local loader
        error: (_, __) => const SizedBox(),
        data: (attendanceState) {
          return settingsAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (settings) {
              final sessions = attendanceState;

              final activeSession = ref.watch(
                activeSessionProvider(attendanceState),
              );

              final punchInTime = activeSession?.checkInTime;
              final punchOutTime = activeSession?.checkOutTime;

              final workingTime = punchInTime == null
                  ? "00:00"
                  : _duration(punchInTime);

              final officeStart = _parseTime(settings.officeStart);
              final officeEnd = _parseTime(settings.officeEnd);

              final progress = _workProgressFromPunchIn(punchInTime, officeEnd);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    MarkAttendanceHeader(dayName: dayName),
                    const SizedBox(height: 24),

                    LiveClockCard(
                      workingTime: workingTime,
                      progress: progress,
                      shiftStart: officeStart,
                      shiftEnd: officeEnd,
                    ),

                    const SizedBox(height: 32),

                    AttendanceStatusTiles(
                      punchInTime: punchInTime,
                      punchOutTime: punchOutTime,
                    ),

                    const SizedBox(height: 32),

                    /// MAIN BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: ModernPunchButton(
                            text: "Punch In",
                            icon: Icons.fingerprint,
                            onPressed: punchInTime == null
                                ? () async {
                                    if (isRemoteMode) {
                                      await ref
                                          .read(markAttendanceProvider.notifier)
                                          .punchInRemote(remoteReason!);

                                      setState(() {
                                        isRemoteMode = false;
                                        remoteReason = null;
                                      });
                                    } else {
                                      await ref
                                          .read(markAttendanceProvider.notifier)
                                          .punchIn();
                                    }
                                  }
                                : null,
                            colors: [scheme.primary, scheme.primaryContainer],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernPunchButton(
                            text: "Punch Out",
                            icon: Icons.power_settings_new_rounded,
                            onPressed: punchInTime != null
                                ? () async {
                                    await ref
                                        .read(markAttendanceProvider.notifier)
                                        .punchOut();
                                  }
                                : null,
                            colors: [
                              scheme.secondary,
                              scheme.secondaryContainer,
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!isRemoteMode && punchInTime == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextButton.icon(
                          onPressed: _openRemoteReasonDialog,
                          icon: Icon(
                            Icons.wifi_tethering_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                          label: Text(
                            "Work remotely (emergency)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),

                    if (isRemoteMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Remote mode enabled",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    SessionLogs(sessions: sessions),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openRemoteReasonDialog() async {
    final scheme = Theme.of(context).colorScheme;
    final TextEditingController reasonCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Remote Work (Emergency)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Please explain your emergency. This will be logged.",
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe the situation…",
                  filled: true,
                  fillColor: scheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (reasonCtrl.text.trim().isEmpty) return;

                    setState(() {
                      isRemoteMode = true;
                      remoteReason = reasonCtrl.text.trim();
                    });

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Enable Remote Punch In",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _duration(DateTime start) {
    final diff = DateTime.now().difference(start);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  double _workProgressFromPunchIn(DateTime? punchInTime, TimeOfDay? officeEnd) {
    if (punchInTime == null || officeEnd == null) return 0.0;

    final now = DateTime.now();

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      officeEnd.hour,
      officeEnd.minute,
    );

    if (now.isBefore(punchInTime)) return 0.0;

    final total = end.difference(punchInTime).inSeconds;
    if (total <= 0) return 1.0;

    final worked = now.difference(punchInTime).inSeconds;
    return (worked / total).clamp(0.0, 1.0);
  }
}
