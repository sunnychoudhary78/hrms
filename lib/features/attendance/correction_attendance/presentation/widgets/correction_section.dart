import 'package:flutter/material.dart';
import '../../data/models/attendance_request_model.dart';
import 'correction_mobile_card.dart';
import 'correction_table.dart';

class CorrectionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;
  final List<AttendanceRequest> requests;

  const CorrectionSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    final items = requests.where((e) => e.type == type).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 800
              ? Column(
                  children: items
                      .map((e) => CorrectionMobileCard(item: e))
                      .toList(),
                )
              : CorrectionTable(items: items);
        },
      ),
    );
  }
}
