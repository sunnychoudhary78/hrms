import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/dashboard/presentation/providers/team_dashboard_proividers.dart';
import 'package:lms/features/dashboard/presentation/screens/employee_attendence_calender_screen.dart';
import 'package:lms/features/dashboard/presentation/widgets/team_analytics_section.dart';
import 'package:lms/features/dashboard/presentation/widgets/team_member_card.dart';
import 'package:lms/features/dashboard/presentation/widgets/team_overview_card.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/widgets/app_bar.dart';

class TeamDashboardScreen extends ConsumerStatefulWidget {
  const TeamDashboardScreen({super.key});

  @override
  ConsumerState<TeamDashboardScreen> createState() =>
      _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends ConsumerState<TeamDashboardScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dashboardAsync = ref.watch(teamDashboardProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppAppBar(title: "Dashboard"),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e.toString(), textAlign: TextAlign.center)),
        data: (dashboard) {
          final filtered = dashboard.employees.where((e) {
            final q = searchQuery.toLowerCase();
            return e.name.toLowerCase().contains(q) ||
                e.employeeId.toLowerCase().contains(q) ||
                e.email.toLowerCase().contains(q);
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔎 Search
                      _searchBar(scheme),
                      const SizedBox(height: 28),

                      /// 🔥 Premium Team Overview Card
                      TeamOverviewCard(dashboard: dashboard),

                      const SizedBox(height: 36),

                      TeamAnalyticsSection(dashboard: dashboard),

                      const SizedBox(height: 36),

                      /// 👥 Team Section Title
                      Text(
                        "Team Members (${filtered.length})",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 18),

                      /// 👤 Team Members List
                      ...filtered.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TeamMemberCard(
                            employee: e,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EmployeeAttendanceCalendarScreen(
                                        employee: e,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔎 Modern Search
  Widget _searchBar(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
          hintText: "Search team member...",
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
