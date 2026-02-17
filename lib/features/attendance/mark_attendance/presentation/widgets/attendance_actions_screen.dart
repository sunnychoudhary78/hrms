import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/mark_attendance_provider.dart';
import '../widgets/modern_punch_button.dart';

class AttendanceActionsSection extends ConsumerWidget {
  final DateTime? punchInTime;
  final DateTime? punchOutTime;

  final bool isRemoteMode;
  final String? remoteReason;

  final Function(String reason) onEnableRemoteMode;
  final VoidCallback onResetRemoteMode;

  const AttendanceActionsSection({
    super.key,
    required this.punchInTime,
    required this.punchOutTime,
    required this.isRemoteMode,
    required this.remoteReason,
    required this.onEnableRemoteMode,
    required this.onResetRemoteMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final notifier = ref.read(markAttendanceProvider.notifier);

    final canCheckIn = punchInTime == null;
    final canCheckOut = punchInTime != null && punchOutTime == null;

    return Column(
      children: [
        /// BUTTON ROW
        Row(
          children: [
            Expanded(
              child: ModernPunchButton(
                text: "Punch In",
                icon: Icons.fingerprint,
                onPressed: canCheckIn
                    ? () async {
                        if (isRemoteMode && remoteReason != null) {
                          await notifier.punchInRemote(context, remoteReason!);

                          onResetRemoteMode();
                        } else {
                          await notifier.punchIn(context);
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
                onPressed: canCheckOut
                    ? () async {
                        if (isRemoteMode && remoteReason != null) {
                          await notifier.punchOutRemote(context, remoteReason!);

                          onResetRemoteMode();
                        } else {
                          await notifier.punchOut(context);
                        }
                      }
                    : null,
                colors: [scheme.secondary, scheme.secondaryContainer],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// REMOTE OPTION (ALWAYS AVAILABLE)
        if (punchOutTime == null)
          TextButton.icon(
            onPressed: () => _openRemoteDialog(context),
            icon: Icon(Icons.wifi_tethering_rounded, color: scheme.primary),
            label: Text(
              punchInTime == null
                  ? "Work remotely (remote check-in)"
                  : "Work remotely (remote check-out)",
            ),
          ),

        /// REMOTE ACTIVE INDICATOR
        if (isRemoteMode)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              punchInTime == null
                  ? "Remote check-in enabled"
                  : "Remote check-out enabled",
              style: TextStyle(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openRemoteDialog(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    final TextEditingController ctrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// TITLE
                    Text(
                      punchInTime == null
                          ? "Remote Check-In"
                          : "Remote Check-Out",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Please provide a reason",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),

                    const SizedBox(height: 20),

                    /// INPUT
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter reason...",
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BUTTON ROW
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final reason = ctrl.text.trim();

                              if (reason.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a reason"),
                                  ),
                                );
                                return;
                              }

                              onEnableRemoteMode(reason);

                              Navigator.pop(context);
                            },
                            child: const Text("Enable Remote Mode"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
