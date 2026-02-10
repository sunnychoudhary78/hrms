import 'package:flutter/material.dart';
import 'package:lms/features/attendance/correction_attendance/presentation/dialogs/review_request_dialog.dart';
import '../../data/models/attendance_request_model.dart';
import 'user_cell.dart';

class CorrectionMobileCard extends StatelessWidget {
  final AttendanceRequest item;

  const CorrectionMobileCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
