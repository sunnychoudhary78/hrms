import 'package:flutter/material.dart';
import '../../data/models/leave_balance_model.dart';

class LeaveTypeDropdown extends StatelessWidget {
  final List<LeaveBalance> leaves;
  final LeaveBalance? selected;
  final ValueChanged<LeaveBalance?> onChanged;

  const LeaveTypeDropdown({
    super.key,
    required this.leaves,
    required this.selected,
    required this.onChanged,
  });

  String formatLeave(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<LeaveBalance>(
      value: selected,

      isExpanded: true, // important

      decoration: const InputDecoration(
        labelText: "Leave Type",
        border: OutlineInputBorder(),
      ),

      items: leaves.map((leave) {
        return DropdownMenuItem<LeaveBalance>(
          value: leave,

          child: Text(
            "${leave.name} (${formatLeave(leave.available)} days)",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: scheme.onSurface),
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}
