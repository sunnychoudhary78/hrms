class AttendanceAggregate {
  final DateTime date;
  final String status;

  AttendanceAggregate({required this.date, required this.status});

  factory AttendanceAggregate.fromJson(Map<String, dynamic> json) {
    /// DEBUG LOGS
    print("📊 AttendanceAggregate.fromJson");
    print("date type → ${json['date'].runtimeType}");
    print("date value → ${json['date']}");
    print("status type → ${json['status'].runtimeType}");
    print("status value → ${json['status']}");

    /// SAFE DATE PARSE
    DateTime parsedDate;

    if (json['date'] is String) {
      parsedDate = DateTime.parse(json['date']);
    } else {
      parsedDate = DateTime.now();
      print("⚠️ Invalid date format, using now()");
    }

    /// SAFE STATUS PARSE
    String parsedStatus = 'absent';

    final rawStatus = json['status'];

    if (rawStatus == null) {
      parsedStatus = 'absent';
    } else if (rawStatus is String) {
      parsedStatus = rawStatus;
    } else if (rawStatus is Map) {
      /// try common keys
      if (rawStatus.containsKey('name')) {
        parsedStatus = rawStatus['name'].toString();
      } else if (rawStatus.containsKey('status')) {
        parsedStatus = rawStatus['status'].toString();
      } else if (rawStatus.containsKey('label')) {
        parsedStatus = rawStatus['label'].toString();
      } else {
        parsedStatus = rawStatus.toString();
      }

      print("⚠️ status was Map, converted to → $parsedStatus");
    } else {
      parsedStatus = rawStatus.toString();
    }

    return AttendanceAggregate(date: parsedDate, status: parsedStatus);
  }

  factory AttendanceAggregate.empty(DateTime d) {
    return AttendanceAggregate(date: d, status: 'absent');
  }
}
