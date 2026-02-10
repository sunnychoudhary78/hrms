import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';
import 'leave_approve_actions.dart';

class LeaveApproveCard extends StatefulWidget {
  final ManagerLeaveRequest request;
  final Function(String, String?, List<String>) onApprove;
  final Function(String, String?) onReject;

  const LeaveApproveCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<LeaveApproveCard> createState() => _LeaveApproveCardState();
}

class _LeaveApproveCardState extends State<LeaveApproveCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: r.profilePicture.isNotEmpty
                        ? NetworkImage(r.profilePicture)
                        : null,
                    radius: 28,
                    child: r.profilePicture.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.employeeCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(r.employeeName),
                        Text(r.designation),
                        Text("Dept: ${r.department}"),
                      ],
                    ),
                  ),
                  _statusChip(r.status),
                ],
              ),

              if (expanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text("Leave: ${r.leaveType}"),
                Text(
                  "From: ${DateFormat('dd MMM yyyy').format(DateTime.parse(r.startDate))}",
                ),
                Text(
                  "To: ${DateFormat('dd MMM yyyy').format(DateTime.parse(r.endDate))}",
                ),
                Text("Days: ${r.days}"),
                Text("Reason: ${r.reason}"),

                LeaveApproveActions(
                  request: r,
                  onApprove: widget.onApprove,
                  onReject: widget.onReject,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();

    Color bg = Colors.orange.shade100;
    Color fg = Colors.orange.shade800;

    if (s == "approved") {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    } else if (s == "rejected") {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: fg)),
    );
  }
}
