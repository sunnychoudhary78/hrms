class AttendanceSession {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  /// ✅ NEW (from API)
  final String date; // yyyy-MM-dd
  final int? durationMinutes;

  final String source;
  final bool remoteRequested;
  final String? remoteReason;

  AttendanceSession({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.date,
    required this.durationMinutes,
    required this.source,
    required this.remoteRequested,
    this.remoteReason,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id']?.toString() ?? '',
      checkInTime: DateTime.parse(json['checkInTime']),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,

      // ✅ ADDED
      date: json['date'],
      durationMinutes: json['durationMinutes'],

      source: json['source'] ?? '',
      remoteRequested: json['remoteRequested'] ?? false,
      remoteReason: json['remoteReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),

      // ✅ ADDED
      'date': date,
      'durationMinutes': durationMinutes,

      'source': source,
      'remoteRequested': remoteRequested,
      'remoteReason': remoteReason,
    };
  }
}
