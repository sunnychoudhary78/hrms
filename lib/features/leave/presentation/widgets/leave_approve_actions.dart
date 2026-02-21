import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';

class LeaveApproveActions extends StatelessWidget {
  final ManagerLeaveRequest request;

  /// ✅ FIXED TYPE
  final Function(String, String?, List<Map<String, dynamic>>) onApprove;

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
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Approve"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final confirm = await _confirm(context, "Approve Leave?");
              if (!confirm) return;

              List<Map<String, dynamic>> dates;

              /// ✅ FIX: generate full range manually
              if (request.isHalfDay) {
                dates = [
                  {
                    "date": request.startDate,
                    "halfDayPart": request.halfDayPart,
                  },
                ];
              } else {
                final start = DateTime.parse(request.startDate);
                final end = DateTime.parse(request.endDate);

                dates = [];

                DateTime current = start;

                while (!current.isAfter(end)) {
                  dates.add({
                    "date":
                        "${current.year.toString().padLeft(4, '0')}-"
                        "${current.month.toString().padLeft(2, '0')}-"
                        "${current.day.toString().padLeft(2, '0')}",
                    "halfDayPart": null,
                  });

                  current = current.add(const Duration(days: 1));
                }
              }

              print("✅ APPROVING DATES: $dates");

              await onApprove(request.id, "Approved by Manager", dates);
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text("Reject"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = await _askReason(context);
              if (reason == null) return;

              await onReject(request.id, reason);
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _confirm(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Leave"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter reason"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }
}
