import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/providers/attendance_requests_provider.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/widgets/section_header.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/widgets/app_bar.dart';
import '../widgets/correction_stats.dart';
import '../widgets/status_filter_pills.dart';
import '../widgets/correction_section.dart';

class AttendanceCorrectionScreen extends ConsumerWidget {
  const AttendanceCorrectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stateAsync = ref.watch(attendanceRequestsProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppAppBar(title: "Correct Attendance"),
      drawer: AppDrawer(),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (state) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(attendanceRequestsProvider.notifier)
                  .fetchRequests();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CorrectionStats(requests: state.requests),

                  const SizedBox(height: 20),

                  const SectionHeader(
                    title: "Filter by status",
                    icon: Icons.filter_alt_rounded,
                  ),
                  const SizedBox(height: 12),

                  StatusFilterPills(
                    selected: state.statusFilter,
                    onChanged: (s) => ref
                        .read(attendanceRequestsProvider.notifier)
                        .changeStatus(s),
                  ),

                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: "Attendance corrections",
                    icon: Icons.access_time_rounded,
                  ),
                  const SizedBox(height: 12),

                  CorrectionSection(
                    title: "Attendance Corrections",
                    subtitle: "Missed punches & edits",
                    type: "CORRECTION",
                    requests: state.requests,
                  ),

                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: "Remote work requests",
                    icon: Icons.home_work_rounded,
                  ),
                  const SizedBox(height: 12),

                  CorrectionSection(
                    title: "Remote Work Requests",
                    subtitle: "WFH & remote approvals",
                    type: "REMOTE",
                    requests: state.requests,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
