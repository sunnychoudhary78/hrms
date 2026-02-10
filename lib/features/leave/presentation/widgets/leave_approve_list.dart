import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';
import 'leave_approve_card.dart';

class LeaveApproveList extends StatelessWidget {
  final List<ManagerLeaveRequest> requests;
  final String search;
  final DateTime? selectedDate;
  final Future<void> Function() onRefresh;
  final Function(String, String?, List<String>) onApprove;
  final Function(String, String?) onReject;

  const LeaveApproveList({
    super.key,
    required this.requests,
    required this.search,
    required this.selectedDate,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final text = search.toLowerCase();

    final filtered = requests.where((r) {
      final matchesText =
          text.isEmpty ||
          r.employeeName.toLowerCase().contains(text) ||
          r.employeeCode.toLowerCase().contains(text) ||
          r.leaveType.toLowerCase().contains(text);

      final matchesDate =
          selectedDate == null ||
          DateUtils.isSameDay(DateTime.parse(r.startDate), selectedDate);

      return matchesText && matchesDate;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No pending requests"));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (_, i) => LeaveApproveCard(
          request: filtered[i],
          onApprove: onApprove,
          onReject: onReject,
        ),
      ),
    );
  }
}
