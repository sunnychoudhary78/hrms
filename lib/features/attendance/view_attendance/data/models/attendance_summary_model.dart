class AttendanceSummary {
  final int workingDays;
  final int lateDays;
  final int totalLeaves;
  final int absentDays;
  final int payableDays;
  final int totalMinutes;
  final int expectedWorkingHours;

  AttendanceSummary({
    required this.workingDays,
    required this.lateDays,
    required this.totalLeaves,
    required this.absentDays,
    required this.payableDays,
    required this.totalMinutes,
    required this.expectedWorkingHours,
  });

  /// 🔥 Convert minutes → HH:mm
  String get totalWorkingHoursFormatted {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return AttendanceSummary(
      workingDays: asInt(json['workingDays']),
      lateDays: asInt(json['lateDays']),
      totalLeaves: asInt(json['totalLeaves']),
      absentDays: asInt(json['absentDays']),
      payableDays: asInt(json['payableDays']),
      totalMinutes: asInt(json['totalMinutes']),
      expectedWorkingHours: asInt(json['expectedWorkingHours']),
    );
  }
}
