import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_status_model.dart';
import 'leave_status_card.dart';

class LeaveStatusList extends StatelessWidget {
  final List<LeaveStatus> leaves;
  final Future<void> Function() onRefresh;
  final Function(String, List<String>) onRevoke;

  const LeaveStatusList({
    super.key,
    required this.leaves,
    required this.onRefresh,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) {
      return const Center(
        child: Text("No leave requests found", style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          final leave = leaves[index];

          final List<String> dates = leave.approvedDates.isNotEmpty
              ? leave.approvedDates
              : leave.requestedDates;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: LeaveStatusCard(
              leave: leave,
              onRevoke: dates.isEmpty ? null : () => onRevoke(leave.id, dates),
            ),
          );
        },
      ),
    );
  }
}
