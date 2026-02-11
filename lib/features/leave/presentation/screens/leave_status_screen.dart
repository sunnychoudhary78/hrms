import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import '../providers/leave_status_provider.dart';
import '../widgets/leave_status_appbar.dart';
import '../widgets/leave_status_list.dart';

class LeaveStatusScreen extends ConsumerStatefulWidget {
  const LeaveStatusScreen({super.key});

  @override
  ConsumerState<LeaveStatusScreen> createState() => _LeaveStatusScreenState();
}

class _LeaveStatusScreenState extends ConsumerState<LeaveStatusScreen> {
  String query = '';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final leaveAsync = ref.watch(leaveStatusProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,

      appBar: LeaveStatusAppBar(
        onSearch: (v) => setState(() => query = v),
        onPickDate: (d) => setState(() => selectedDate = d),
        onClear: () => setState(() {
          query = '';
          selectedDate = null;
        }),
      ),
      drawer: AppDrawer(),

      body: leaveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (leaves) => LeaveStatusList(
          leaves: leaves,
          search: query,
          selectedDate: selectedDate,
          onRefresh: () => ref.read(leaveStatusProvider.notifier).refresh(),
          onRevoke: (id, dates) =>
              ref.read(leaveStatusProvider.notifier).revokeLeave(id, dates),
        ),
      ),
    );
  }
}
