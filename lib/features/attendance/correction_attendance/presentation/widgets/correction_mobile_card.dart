import 'package:flutter/material.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/dialogs/review_request_dialog.dart';
import '../../data/models/attendance_request_model.dart';
import 'user_cell.dart';

class CorrectionMobileCard extends StatelessWidget {
  final AttendanceRequest item;

  const CorrectionMobileCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserCell(name: item.userName, image: item.userImage),
          const SizedBox(height: 12),

          Text(
            item.reason ?? "—",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showReviewDialog(context: context, req: item);
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Review"),
            ),
          ),
        ],
      ),
    );
  }
}
