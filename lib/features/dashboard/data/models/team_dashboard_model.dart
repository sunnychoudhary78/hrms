class TeamDashboard {
  final int total;
  final int present;
  final int absent;
  final List<TeamEmployee> employees;

  TeamDashboard({
    required this.total,
    required this.present,
    required this.absent,
    required this.employees,
  });

  factory TeamDashboard.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];

    return TeamDashboard(
      total: stats['total'] ?? 0,
      present: stats['present'] ?? 0,
      absent: stats['absent'] ?? 0,
      employees: (json['employees'] as List)
          .map((e) => TeamEmployee.fromJson(e))
          .toList(),
    );
  }
}

class TeamEmployee {
  final String name;
  final String email;
  final String contact;
  final String employeeId;
  final bool isPresent;
  final String managerName;

  TeamEmployee({
    required this.name,
    required this.email,
    required this.contact,
    required this.employeeId,
    required this.isPresent,
    required this.managerName,
  });

  factory TeamEmployee.fromJson(Map<String, dynamic> json) {
    return TeamEmployee(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      employeeId: json['employee_id'] ?? '',
      isPresent: json['is_present'] ?? false,
      managerName: json['manager_name'] ?? '',
    );
  }
}
