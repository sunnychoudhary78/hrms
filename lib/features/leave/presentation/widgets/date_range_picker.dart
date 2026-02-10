import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime> onFromPick;
  final ValueChanged<DateTime> onToPick;

  const DateRangePicker({
    super.key,
    required this.from,
    required this.to,
    required this.onFromPick,
    required this.onToPick,
  });

  Future<void> _pick(BuildContext context, ValueChanged<DateTime> cb) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) cb(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _box("From", from, () => _pick(context, onFromPick))),
        const SizedBox(width: 12),
        Expanded(child: _box("To", to, () => _pick(context, onToPick))),
      ],
    );
  }

  Widget _box(String label, DateTime? date, VoidCallback onTap) {
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
