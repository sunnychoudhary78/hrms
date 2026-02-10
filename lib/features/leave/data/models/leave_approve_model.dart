class ManagerLeaveRequest {
  final String id;
  final String status;
  final String startDate;
  final String endDate;
  final double days;
  final bool isHalfDay;
  final String? halfDayPart;
  final String reason;

  final String leaveType;

  final String employeeName;
  final String employeeCode;
  final String designation;
  final String department;
  final String profilePicture;

  final List<String> revocationRequestedDates;

  ManagerLeaveRequest({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.isHalfDay,
    this.halfDayPart,
    required this.reason,
    required this.leaveType,
    required this.employeeName,
    required this.employeeCode,
    required this.designation,
    required this.department,
    required this.profilePicture,
    required this.revocationRequestedDates,
  });

  factory ManagerLeaveRequest.fromJson(Map<String, dynamic> json) {
    return ManagerLeaveRequest(
      id: json['id'],
      status: json['status'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      days: (json['days'] as num).toDouble(),
      isHalfDay: json['isHalfDay'] ?? false,
      halfDayPart: json['halfDayPart'],
      reason: json['reason'] ?? '',
      leaveType: json['leaveType']['name'],

      employeeName: json['employee']['name'],
      employeeCode: json['employee']['payrollCode'] ?? '',
      designation: json['employee']['designation'] ?? '',
      department: json['employee']['department'] ?? '',
      profilePicture: json['employee']['profilePicture'] ?? '',

      revocationRequestedDates: (json['revocationRequestedDates'] ?? [])
          .map<String>((e) => e.toString())
          .toList(),
    );
  }
}
