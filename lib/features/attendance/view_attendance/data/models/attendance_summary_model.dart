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

  /// SAFE parser for ANY backend response
  static int _asInt(dynamic v) {
    if (v == null) return 0;

    if (v is int) return v;

    if (v is double) return v.toInt();

    if (v is String) return int.tryParse(v) ?? 0;

    if (v is Map<String, dynamic>) {
      if (v.containsKey('count')) return _asInt(v['count']);
      if (v.containsKey('value')) return _asInt(v['value']);
      if (v.containsKey('total')) return _asInt(v['total']);
    }

    return 0;
  }

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    print("📊 RAW SUMMARY JSON:");
    print(json);

    return AttendanceSummary(
      workingDays: _asInt(json['workingDays']),
      lateDays: _asInt(json['lateDays']),
      totalLeaves: _asInt(json['totalLeaves']),
      absentDays: _asInt(json['absentDays']),
      payableDays: _asInt(json['payableDays']),
      totalMinutes: _asInt(json['totalMinutes']),
      expectedWorkingHours: _asInt(json['expectedWorkingHours']),
    );
  }

  /// Convert minutes → HH:mm
  String get totalWorkingHoursFormatted {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }
}
