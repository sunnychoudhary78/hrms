class AttendanceDayData {
  final String date;
  final String status;
  final int totalMinutes;
  final List<AttendanceSessionData> sessions;

  AttendanceDayData({
    required this.date,
    required this.status,
    required this.totalMinutes,
    required this.sessions,
  });

  factory AttendanceDayData.fromJson({
    required Map<String, dynamic> aggregate,
    required List sessionsJson,
  }) {
    return AttendanceDayData(
      date: aggregate['date'],
      status: aggregate['status'],
      totalMinutes: aggregate['totalMinutes'] ?? 0,
      sessions: sessionsJson
          .map((e) => AttendanceSessionData.fromJson(e))
          .toList(),
    );
  }

  double get totalHours => totalMinutes / 60;
}

//////////////////////////////////////////////////////////////

class AttendanceSessionData {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int durationMinutes;
  final String source;

  AttendanceSessionData({
    required this.checkIn,
    required this.checkOut,
    required this.durationMinutes,
    required this.source,
  });

  factory AttendanceSessionData.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionData(
      checkIn: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime']).toLocal()
          : null,

      checkOut: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime']).toLocal()
          : null,

      durationMinutes: json['durationMinutes'] ?? 0,
      source: json['source'] ?? '',
    );
  }

  double get hours => durationMinutes / 60;
}
