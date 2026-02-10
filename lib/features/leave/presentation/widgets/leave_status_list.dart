import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_status_model.dart';
import 'leave_status_card.dart';

class LeaveStatusList extends StatelessWidget {
  final List<LeaveStatus> leaves;
  final String search;
  final DateTime? selectedDate;
  final Future<void> Function() onRefresh;
  final Function(String, List<String>) onRevoke;

  const LeaveStatusList({
    super.key,
    required this.leaves,
    required this.search,
    required this.selectedDate,
    required this.onRefresh,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final text = search.toLowerCase();

    final filtered = leaves.where((l) {
      final matchesText =
          text.isEmpty ||
          (l.leaveType?.toLowerCase().contains(text) ?? false) ||
          l.reference.toLowerCase().contains(text);

      final matchesDate =
          selectedDate == null ||
          DateUtils.isSameDay(DateTime.parse(l.startDate), selectedDate);

      return matchesText && matchesDate;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text("No leave requests found", style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final leave = filtered[index];

          final List<String> dates = leave.approvedDates.isNotEmpty
              ? leave.approvedDates
              : leave.requestedDates;

          return LeaveStatusCard(
            leave: leave,
            onRevoke: dates.isEmpty ? null : () => onRevoke(leave.id, dates),
          );
        },
      ),
    );
  }
}
