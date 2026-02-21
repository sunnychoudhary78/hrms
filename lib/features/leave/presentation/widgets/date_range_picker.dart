import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime> onFromPick;
  final ValueChanged<DateTime> onToPick;

  /// ✅ NEW: maximum leave days allowed
  final double maxLeaveDays;

  /// ✅ NEW: half day mode
  final bool isHalfDay;

  const DateRangePicker({
    super.key,
    required this.from,
    required this.to,
    required this.onFromPick,
    required this.onToPick,
    required this.maxLeaveDays,
    required this.isHalfDay,
  });

  /// FROM PICKER
  Future<void> _pickFrom(BuildContext context) async {
    debugPrint("📅 Opening FROM date picker");
    debugPrint("📅 Current FROM value: $from");

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      initialDate: from ?? DateTime.now(),
    );

    if (picked != null) {
      debugPrint("✅ FROM date selected: $picked");

      onFromPick(picked);

      /// If half day → auto set TO date
      if (isHalfDay) {
        onToPick(picked);
      }
    } else {
      debugPrint("⚠️ FROM date selection cancelled");
    }
  }

  /// TO PICKER WITH BALANCE LIMIT
  Future<void> _pickTo(BuildContext context) async {
    debugPrint("📅 Opening TO date picker");
    debugPrint("📅 Current FROM value: $from");
    debugPrint("📅 Current TO value: $to");
    debugPrint("📅 Max leave days allowed: $maxLeaveDays");

    if (from == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start date first")),
      );
      return;
    }

    /// Half day → TO must equal FROM
    if (isHalfDay) {
      debugPrint("Half day mode → forcing TO date = FROM date");
      onToPick(from!);
      return;
    }

    /// Calculate maximum allowed end date
    final maxEndDate = from!.add(Duration(days: maxLeaveDays.floor() - 1));

    debugPrint("📅 Max allowed TO date: $maxEndDate");

    final picked = await showDatePicker(
      context: context,
      firstDate: from!,
      lastDate: maxEndDate,
      initialDate: to ?? from!,
    );

    if (picked != null) {
      debugPrint("✅ TO date selected: $picked");

      /// Validate not before FROM
      if (picked.isBefore(from!)) {
        debugPrint("❌ INVALID: TO date before FROM date");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End date cannot be before start date")),
        );
        return;
      }

      /// Validate against balance
      final selectedDays = picked.difference(from!).inDays + 1;

      debugPrint("Selected days: $selectedDays");

      if (selectedDays > maxLeaveDays + 0.001) {
        final formatted = maxLeaveDays % 1 == 0
            ? maxLeaveDays.toInt().toString()
            : maxLeaveDays.toString();

        debugPrint("❌ Exceeds balance");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can only select up to $formatted days")),
        );

        return;
      }

      onToPick(picked);
    } else {
      debugPrint("⚠️ TO date selection cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _box(context, "From", from, () => _pickFrom(context))),
        const SizedBox(width: 12),
        Expanded(child: _box(context, "To", to, () => _pickTo(context))),
      ],
    );
  }

  Widget _box(
    BuildContext context,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date == null ? "Select" : DateFormat('dd MMM yyyy').format(date),
        ),
      ),
    );
  }
}
