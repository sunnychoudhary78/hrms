import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/leave/data/models/leave_approve_model.dart';
import 'leave_approve_actions.dart';

class LeaveApproveCard extends StatefulWidget {
  final ManagerLeaveRequest request;

  final bool isPending;

  final Function(String, String?, List<Map<String, dynamic>>)? onApprove;

  final Function(String, String?)? onReject;

  const LeaveApproveCard({
    super.key,
    required this.request,
    required this.isPending,
    this.onApprove,
    this.onReject,
  });
  @override
  State<LeaveApproveCard> createState() => _LeaveApproveCardState();
}

class _LeaveApproveCardState extends State<LeaveApproveCard> {
  bool expanded = false;

  bool get canTakeAction =>
      widget.isPending && widget.request.status.toLowerCase() == "pending";

  String formatDays(double days) {
    if (days == days.toInt()) {
      return days.toInt().toString();
    }
    return days.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final r = widget.request;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  r.employeeName.isNotEmpty ? r.employeeName[0] : "?",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      r.leaveType,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _statusChip(r.status),
            ],
          ),

          const SizedBox(height: 12),

          /// DATE ROW (ALWAYS VISIBLE)
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),

              const SizedBox(width: 6),

              Text(
                "${_format(r.startDate)} → ${_format(r.endDate)}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${formatDays(r.days)} day${r.days > 1 ? 's' : ''}",
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),

          /// HALF DAY INDICATOR
          if (r.isHalfDay) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timelapse, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  "Half Day (${r.halfDayPart ?? ''})",
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],

          /// DESIGNATION / DEPARTMENT
          if (r.designation.isNotEmpty || r.department.isNotEmpty) ...[
            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    "${r.designation} • ${r.department}",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          /// EXPAND BUTTON
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),

            child: Row(
              children: [
                Text(
                  expanded ? "Hide details" : "View details",
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),

          if (expanded) ...[
            const SizedBox(height: 12),

            /// REASON
            if (r.reason.isNotEmpty)
              Text(
                "Reason: ${r.reason}",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),

            const SizedBox(height: 12),

            if (canTakeAction)
              LeaveApproveActions(
                request: r,
                onApprove: widget.onApprove!,
                onReject: widget.onReject!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;

    if (status.toLowerCase() == "approved") color = Colors.green;

    if (status.toLowerCase() == "rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  String _format(String date) {
    return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
  }
}
