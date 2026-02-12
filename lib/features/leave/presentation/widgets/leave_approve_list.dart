import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';
import 'leave_approve_card.dart';

class LeaveApproveList extends StatelessWidget {
  final List<ManagerLeaveRequest> requests;
  final Future<void> Function() onRefresh;
  final Function(String, String?, List<String>) onApprove;
  final Function(String, String?) onReject;

  const LeaveApproveList({
    super.key,
    required this.requests,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Text("No pending requests", style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: LeaveApproveCard(
            request: requests[i],
            onApprove: onApprove,
            onReject: onReject,
          ),
        ),
      ),
    );
  }
}
