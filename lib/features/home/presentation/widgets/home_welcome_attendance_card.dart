import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/attendance_selectors.dart';
import 'package:lms/features/attendance/mark_attendance/presentation/providers/mark_attendance_provider.dart';

class HomeWelcomeAttendanceCard extends ConsumerWidget {
  final String name;
  final String role;
  final String? imageUrl;

  const HomeWelcomeAttendanceCard({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final attendanceAsync = ref.watch(markAttendanceProvider);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: attendanceAsync.when(
        loading: () => const SizedBox(height: 120),
        error: (_, __) => const SizedBox(height: 120),
        data: (sessions) {
          final activeSession = ref.watch(activeSessionProvider(sessions));

          final bool isCheckedIn =
              activeSession != null && activeSession.checkOutTime == null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: scheme.onPrimary.withOpacity(.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role,
                          style: TextStyle(
                            color: scheme.onPrimary.withOpacity(.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Avatar(name: name, imageUrl: imageUrl),
                ],
              ),

              const SizedBox(height: 20),

              /// STATUS + ACTION
              Row(
                children: [
                  _StatusChip(
                    text: isCheckedIn ? "Checked in" : "Not checked in",
                    color: isCheckedIn ? Colors.green : Colors.orange,
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedIn
                          ? scheme.error
                          : scheme.onPrimary,
                      foregroundColor: isCheckedIn
                          ? scheme.onError
                          : scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(
                      isCheckedIn ? Icons.logout_rounded : Icons.fingerprint,
                      size: 18,
                    ),
                    label: Text(isCheckedIn ? "Punch Out" : "Punch In"),
                    onPressed: () async {
                      try {
                        if (isCheckedIn) {
                          await ref
                              .read(markAttendanceProvider.notifier)
                              .punchOut(context);
                        } else {
                          await ref
                              .read(markAttendanceProvider.notifier)
                              .punchIn(context);
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ],
              ),

              if (isCheckedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Checked in at ${_fmt(activeSession.checkInTime)}",
                    style: TextStyle(color: scheme.onPrimary, fontSize: 13),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _fmt(DateTime t) {
    return DateFormat('hh:mm a').format(t.toLocal());
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.surface,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _initials(name),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
