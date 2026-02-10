import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/dashboard/data/models/team_dashboard_model.dart';
import 'package:lms/features/dashboard/presentation/providers/team_dashboard_proividers.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Team Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(teamDashboardProvider.notifier).refresh(),
          ),
        ],
      ),

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _searchBar(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    _stat("Total", dashboard.total, Icons.groups, [
                      Colors.blue,
                      Colors.lightBlue,
                    ]),
                    const SizedBox(width: 12),
                    _stat("Present", dashboard.present, Icons.check_circle, [
                      Colors.green,
                      Colors.lightGreen,
                    ]),
                    const SizedBox(width: 12),
                    _stat("Absent", dashboard.absent, Icons.cancel, [
                      Colors.red,
                      Colors.redAccent,
                    ]),
                  ],
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Team Members (${filtered.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _employeeTile(filtered[i]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search by name, ID, or email',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _stat(String title, int value, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _employeeTile(TeamEmployee emp) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showEmployeeDetails(emp),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(child: Text(emp.name[0])),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    emp.employeeId,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _status(emp.isPresent),
          ],
        ),
      ),
    );
  }

  Widget _status(bool present) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: present ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        present ? 'Present' : 'Absent',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showEmployeeDetails(TeamEmployee emp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emp.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _row("Employee ID", emp.employeeId),
            _row("Email", emp.email),
            _row("Contact", emp.contact),
            _row("Manager", emp.managerName),
            const SizedBox(height: 16),
            _status(emp.isPresent),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
