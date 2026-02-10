import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';

class LeaveApproveActions extends StatelessWidget {
  final ManagerLeaveRequest request;
  final Function(String, String?, List<String>) onApprove;
  final Function(String, String?) onReject;

  const LeaveApproveActions({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Approve"),
          onPressed: () {
            final dates = request.isHalfDay
                ? [request.startDate]
                : [request.startDate, request.endDate];

            onApprove(request.id, "Approved by Manager", dates);
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text("Reject"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final reason = await _askReason(context);
            if (reason != null) {
              onReject(request.id, reason);
            }
          },
        ),
      ],
    );
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Leave"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Reason..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
