import 'package:flutter/material.dart';
import 'package:lms/core/network/api_constants.dart';
import '../../data/models/team_dashboard_model.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamEmployee employee;
  final VoidCallback onTap;

  const TeamMemberCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = employee.attendanceSummary;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===============================
              /// HEADER ROW
              /// ===============================
              Row(
                children: [
                  _buildAvatar(context),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.employeeId,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  statusBadge(employee.isPresent),
                ],
              ),

              /// ===============================
              /// PERFORMANCE SECTION
              /// ===============================
              if (summary != null) ...[
                const SizedBox(height: 18),

                Row(
                  children: [
                    _metric(
                      context,
                      "Attendance",
                      "${employee.attendanceRate.toStringAsFixed(0)}%",
                    ),
                    const SizedBox(width: 16),
                    _metric(context, "Late", "${summary.lateDays}"),
                    const SizedBox(width: 16),
                    _metric(context, "Absent", "${summary.absentDays}"),
                    const Spacer(),
                    _performanceBadge(context),
                  ],
                ),

                const SizedBox(height: 14),

                _workingHoursProgress(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // AVATAR
  // =====================================================

  Widget _buildAvatar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imageName = employee.profilePicture;

    if (imageName != null && imageName.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: scheme.primaryContainer,
        child: ClipOval(
          child: Image.network(
            "${ApiConstants.imageBaseUrl}$imageName",
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackAvatar(context),
          ),
        ),
      );
    }

    return _fallbackAvatar(context);
  }

  Widget _fallbackAvatar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 26,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        employee.name.isNotEmpty ? employee.name[0].toUpperCase() : "?",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  // =====================================================
  // METRIC
  // =====================================================

  Widget _metric(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PERFORMANCE BADGE
  // =====================================================

  Widget _performanceBadge(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final score = employee.attendanceRate;

    String grade;
    Color bg;
    Color text;

    if (score >= 90) {
      grade = "A";
      bg = scheme.tertiaryContainer;
      text = scheme.onTertiaryContainer;
    } else if (score >= 70) {
      grade = "B";
      bg = scheme.primaryContainer;
      text = scheme.onPrimaryContainer;
    } else if (score >= 50) {
      grade = "C";
      bg = scheme.secondaryContainer;
      text = scheme.onSecondaryContainer;
    } else {
      grade = "Critical";
      bg = scheme.errorContainer;
      text = scheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  // =====================================================
  // WORKING HOURS PROGRESS
  // =====================================================

  Widget _workingHoursProgress(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = employee.attendanceSummary!;

    final percent = summary.completionPercentage.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Working Hours Completion",
          style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // STATUS BADGE
  // =====================================================

  static Widget statusBadge(bool present) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;

        final bg = present ? scheme.tertiaryContainer : scheme.errorContainer;
        final text = present
            ? scheme.onTertiaryContainer
            : scheme.onErrorContainer;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            present ? "Present" : "Absent",
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        );
      },
    );
  }
}
