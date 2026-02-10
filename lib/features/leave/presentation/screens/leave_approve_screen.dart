import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/leave_approve_provider.dart';
import '../widgets/leave_approve_appbar.dart';
import '../widgets/leave_approve_list.dart';
import '../../../home/presentation/widgets/app_drawer.dart';

class LeaveApproveScreen extends ConsumerStatefulWidget {
  const LeaveApproveScreen({super.key});

  @override
  ConsumerState<LeaveApproveScreen> createState() => _LeaveApproveScreenState();
}

class _LeaveApproveScreenState extends ConsumerState<LeaveApproveScreen> {
  String query = '';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(leaveApproveProvider);

    return Scaffold(
      drawer: const AppDrawer(),

      appBar: LeaveApproveAppBar(
        onSearch: (v) => setState(() => query = v),
        onPickDate: (d) => setState(() => selectedDate = d),
        onClear: () => setState(() {
          query = '';
          selectedDate = null;
        }),
      ),

      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (requests) => LeaveApproveList(
          requests: requests,
          search: query,
          selectedDate: selectedDate,
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
