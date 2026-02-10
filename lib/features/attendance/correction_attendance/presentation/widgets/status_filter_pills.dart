import 'package:flutter/material.dart';

class StatusFilterPills extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const StatusFilterPills({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const statuses = ['PENDING', 'APPROVED', 'REJECTED', 'ALL'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((s) {
          final active = s == selected;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(s),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? Colors.indigo : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
