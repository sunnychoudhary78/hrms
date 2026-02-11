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

class _LeaveApproveCardState extends State<LeaveApproveCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = widget.request;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: expanded ? 18 : 10,
            spreadRadius: 1,
            offset: const Offset(0, 6),
            color: scheme.shadow.withOpacity(0.06),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.surfaceContainerLow,
                    backgroundImage: r.profilePicture.isNotEmpty
                        ? NetworkImage(r.profilePicture)
                        : null,
                    child: r.profilePicture.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 28,
                            color: scheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.employeeName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
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

              AnimatedCrossFade(
                firstChild: const SizedBox(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Divider(color: scheme.outlineVariant),
                    const SizedBox(height: 12),

                    _infoRow(
                      Icons.calendar_today,
                      "Duration",
                      "${_format(r.startDate)} → ${_format(r.endDate)}",
                    ),
                    const SizedBox(height: 8),
                    _infoRow(Icons.timelapse, "Total Days", "${r.days}"),
                    const SizedBox(height: 8),
                    _infoRow(Icons.notes, "Reason", r.reason),
                    const SizedBox(height: 16),

                    LeaveApproveActions(
                      request: r,
                      onApprove: widget.onApprove,
                      onReject: widget.onReject,
                    ),
                  ],
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: scheme.onSurface, fontSize: 14),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();

    Color start = Colors.orange.shade400;
    Color end = Colors.orange.shade600;

    if (s == "approved") {
      start = Colors.green.shade400;
      end = Colors.green.shade600;
    } else if (s == "rejected") {
      start = Colors.red.shade400;
      end = Colors.red.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _format(String date) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}
