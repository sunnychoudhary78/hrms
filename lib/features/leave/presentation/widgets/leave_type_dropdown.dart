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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<LeaveBalance>(
      value: selected,
      decoration: const InputDecoration(
        labelText: "Leave Type",
        border: OutlineInputBorder(),
      ),
      items: leaves.map((leave) {
        return DropdownMenuItem(
          value: leave,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(leave.name),
              Text(
                "${leave.available.toStringAsFixed(0)} days",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
