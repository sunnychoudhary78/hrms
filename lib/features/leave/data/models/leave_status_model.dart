class LeaveStatus {
  final String id;

  /// Human-friendly reference like LR-000097
  final String reference;

  /// Leave type name (Casual Leave, Sick Leave, etc.)
  final String? leaveType;

  final String status;

  final String startDate;
  final String endDate;

  final bool isHalfDay;
  final String? halfDayPart;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<String> approvedDates;
  final List<String> requestedDates;

  const LeaveStatus({
    required this.id,
    required this.reference,
    this.leaveType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isHalfDay,
    this.halfDayPart,
    this.createdAt,
    this.updatedAt,
    required this.approvedDates,
    required this.requestedDates,
  });

  factory LeaveStatus.fromJson(Map<String, dynamic> json) {
    return LeaveStatus(
      id: json['id'] as String,

      /// Prefer humanReadableId, fallback to refNumber
      reference:
          json['humanReadableId'] as String? ??
          json['refNumber']?.toString() ??
          '-',

      /// Correct key: leave_type (snake_case)
      leaveType: json['leave_type']?['name'] as String?,

      status: json['status'] as String? ?? '',

      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,

      isHalfDay: json['isHalfDay'] as bool? ?? false,
      halfDayPart: json['halfDayPart'] as String?,

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,

      approvedDates:
          (json['approvedDates'] as List?)
              ?.map((e) => e['date'] as String)
              .toList() ??
          [],

      requestedDates:
          (json['requestedDates'] as List?)
              ?.map((e) => e['date'] as String)
              .toList() ??
          [],
    );
  }
}
