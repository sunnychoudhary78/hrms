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
    final requestedDates = (json['requestedDates'] as List?) ?? [];

    return ManagerLeaveRequest(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',

      // ✅ Backend no longer sends "days"
      // Calculate from requestedDates
      days: requestedDates.length.toDouble(),

      isHalfDay: json['isHalfDay'] ?? false,
      halfDayPart: json['halfDayPart'],
      reason: json['reason'] ?? '',

      // ✅ Correct key: leave_type
      leaveType: json['leave_type']?['name'] ?? '',

      // ✅ Correct key: user
      employeeName: json['user']?['name'] ?? '',
      employeeCode: '', // Not available in response
      designation: '', // Not available
      department: '', // Not available
      profilePicture: '', // Not available

      revocationRequestedDates:
          (json['revocationRequestedDates'] as List?)
              ?.map<String>((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
