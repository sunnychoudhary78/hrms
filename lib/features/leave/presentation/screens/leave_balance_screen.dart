import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/leave/presentation/widgets/leave_balance_list.dart';
import '../providers/leave_balance_provider.dart';
import '../widgets/leave_pie_chart.dart';
import '../../../home/presentation/widgets/app_drawer.dart';

class LeaveBalanceScreen extends ConsumerWidget {
  const LeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveAsync = ref.watch(leaveBalanceProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text(
          "Leave Balance",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(leaveBalanceProvider.notifier).refresh(),
          ),
        ],
      ),
      body: leaveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (leaves) {
          if (leaves.isEmpty) {
            return const Center(child: Text("No leave data found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Section title
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                LeavePieChart(leaves: leaves),

                const SizedBox(height: 28),

                const Text(
                  "Leave Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                LeaveBalanceList(leaves: leaves),
              ],
            ),
          );
        },
      ),
    );
  }
}
