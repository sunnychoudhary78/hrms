import 'package:flutter/material.dart';
import 'package:lms/features/leave/data/models/leave_balance_model.dart';
import 'package:lms/features/leave/presentation/widgets/leave_balance_tile.dart';

class LeaveBalanceList extends StatelessWidget {
  final List<LeaveBalance> leaves;

  const LeaveBalanceList({super.key, required this.leaves});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: leaves
          .map((leave) => LeaveBalanceTile(balance: leave))
          .toList(),
    );
  }
}
