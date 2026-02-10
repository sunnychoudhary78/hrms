class AttendanceAggregate {
  final DateTime date;
  final String status;

  AttendanceAggregate({required this.date, required this.status});

  factory AttendanceAggregate.fromJson(Map<String, dynamic> json) {
    return AttendanceAggregate(
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'absent',
    );
  }

  factory AttendanceAggregate.empty(DateTime d) {
    return AttendanceAggregate(date: d, status: 'absent');
  }
}
