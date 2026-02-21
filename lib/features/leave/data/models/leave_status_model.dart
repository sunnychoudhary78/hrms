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
    final leaveTypeRaw = json['leave_type'];

    /// SAFE DATE EXTRACTOR FUNCTION
    String extractDate(dynamic e) {
      if (e == null) return '';

      /// case 1: { date: "2025-12-22", halfDayPart: null }
      if (e is Map && e['date'] is String) {
        return e['date'].toString();
      }

      /// case 2: { date: { date: "2025-12-22", halfDayPart: null }, halfDayPart: null }
      if (e is Map && e['date'] is Map && e['date']['date'] != null) {
        return e['date']['date'].toString();
      }

      /// case 3: direct string
      if (e is String) {
        return e;
      }

      return '';
    }

    return LeaveStatus(
      id: json['id']?.toString() ?? '',

      reference:
          json['humanReadableId']?.toString() ??
          json['refNumber']?.toString() ??
          '-',

      /// SAFE leave type parsing
      leaveType: leaveTypeRaw is Map
          ? leaveTypeRaw['name']?.toString()
          : leaveTypeRaw?.toString(),

      status: json['status']?.toString() ?? '',

      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',

      isHalfDay: json['isHalfDay'] == true,

      halfDayPart: json['halfDayPart']?.toString(),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      /// FULLY SAFE approvedDates parsing
      approvedDates: (json['approvedDates'] is List)
          ? (json['approvedDates'] as List)
                .map((e) => extractDate(e))
                .where((e) => e.isNotEmpty)
                .toList()
          : [],

      /// FULLY SAFE requestedDates parsing
      requestedDates: (json['requestedDates'] is List)
          ? (json['requestedDates'] as List)
                .map((e) => extractDate(e))
                .where((e) => e.isNotEmpty)
                .toList()
          : [],
    );
  }
}
