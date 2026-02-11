import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/dashboard/data/models/team_dashboard_model.dart';
import 'package:lms/features/dashboard/presentation/providers/team_dashboard_proividers.dart';
import 'package:lms/features/dashboard/presentation/widgets/manager_stat_card.dart';
import 'package:lms/features/dashboard/presentation/widgets/team_member_card.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';

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
    final dashboardAsync = ref.watch(teamDashboardProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF4F6FB),
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
              /// Premium Header
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A55A2), Color(0xFF7895CB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const FlexibleSpaceBar(
                    titlePadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    title: Text(
                      "Team Overview",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),

              /// Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _searchBar(),
                      const SizedBox(height: 24),

                      /// Stats
                      Row(
                        children: [
                          ManagerStatCard(
                            title: "Total",
                            value: dashboard.total,
                            icon: Icons.groups_rounded,
                          ),
                          const SizedBox(width: 12),
                          ManagerStatCard(
                            title: "Present",
                            value: dashboard.present,
                            icon: Icons.check_circle_rounded,
                          ),
                          const SizedBox(width: 12),
                          ManagerStatCard(
                            title: "Absent",
                            value: dashboard.absent,
                            icon: Icons.cancel_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Text(
                        "Team Members (${filtered.length})",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...filtered.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TeamMemberCard(
                            employee: e,
                            onTap: () => _showEmployeeDetails(e),
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

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded),
          hintText: "Search team member...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showEmployeeDetails(TeamEmployee emp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emp.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _row("Employee ID", emp.employeeId),
            _row("Email", emp.email),
            _row("Contact", emp.contact),
            _row("Manager", emp.managerName),
            const SizedBox(height: 20),
            TeamMemberCard.statusBadge(emp.isPresent),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
