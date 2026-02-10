import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/presentation/providers/auth_provider.dart';

class MarkAttendanceHeader extends ConsumerWidget {
  final String dayName;

  const MarkAttendanceHeader({super.key, required this.dayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final profile = authState.profile;
    final profileUrl = authState.profileUrl;

    final now = DateTime.now();

    final name = profile?.associatesName ?? "--";
    final empId = profile?.payrollCode ?? "--";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF473EEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: profileUrl.isNotEmpty
                ? NetworkImage(profileUrl)
                : const AssetImage('assets/images/profile.jpg')
                      as ImageProvider,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome,", style: TextStyle(color: Colors.white70)),

                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  "Employee ID: $empId",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${now.day}/${now.month}/${now.year}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(dayName, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
