import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import '../providers/leave_approve_provider.dart';
import '../widgets/leave_approve_appbar.dart';
import '../widgets/leave_approve_list.dart';

class LeaveApproveScreen extends ConsumerStatefulWidget {
  const LeaveApproveScreen({super.key});

  @override
  ConsumerState<LeaveApproveScreen> createState() => _LeaveApproveScreenState();
}

class _LeaveApproveScreenState extends ConsumerState<LeaveApproveScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(leaveApproveProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      drawer: const AppDrawer(),
      appBar: const LeaveApproveAppBar(),

      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (requests) => LeaveApproveList(
          requests: requests,
          onRefresh: () => ref.read(leaveApproveProvider.notifier).refresh(),
          onApprove: (id, comment, dates) => ref
              .read(leaveApproveProvider.notifier)
              .approve(id, comment, dates),
          onReject: (id, comment) =>
              ref.read(leaveApproveProvider.notifier).reject(id, comment),
        ),
      ),
    );
  }
}
