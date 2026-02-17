import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/network_providers.dart';
import '../../data/models/attendance_day_data.dart';

//////////////////////////////////////////////////////////////
// PARAMS
//////////////////////////////////////////////////////////////

class AttendanceParams {
  final String userId;
  final DateTime month;

  const AttendanceParams({required this.userId, required this.month});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceParams &&
          userId == other.userId &&
          month.year == other.month.year &&
          month.month == other.month.month;

  @override
  int get hashCode =>
      userId.hashCode ^ month.year.hashCode ^ month.month.hashCode;
}

//////////////////////////////////////////////////////////////
// PROVIDER
//////////////////////////////////////////////////////////////

final employeeAttendanceProvider =
    FutureProvider.family<Map<String, AttendanceDayData>, AttendanceParams>((
      ref,
      params,
    ) async {
      final api = ref.read(apiServiceProvider);

      final firstDay = DateTime(params.month.year, params.month.month, 1);
      final lastDay = DateTime(params.month.year, params.month.month + 1, 0);

      final from = DateFormat('yyyy-MM-dd').format(firstDay);
      final to = DateFormat('yyyy-MM-dd').format(lastDay);

      final response = await api.get(
        'attendance',
        queryParams: {'userId': params.userId, 'from': from, 'to': to},
      );

      final aggregates = response['aggregates'] ?? [];
      final sessions = response['sessions'] ?? [];

      //////////////////////////////////////////////////////////
      // GROUP SESSIONS BY DATE
      //////////////////////////////////////////////////////////

      final Map<String, List> sessionsByDate = {};

      for (final session in sessions) {
        final date = session['date'];
        if (date == null) continue;

        sessionsByDate.putIfAbsent(date, () => []);
        sessionsByDate[date]!.add(session);
      }

      //////////////////////////////////////////////////////////
      // BUILD FINAL MAP
      //////////////////////////////////////////////////////////

      final Map<String, AttendanceDayData> result = {};

      for (final aggregate in aggregates) {
        final date = aggregate['date'];

        final daySessions = sessionsByDate[date] ?? [];

        result[date] = AttendanceDayData.fromJson(
          aggregate: aggregate,
          sessionsJson: daySessions,
        );
      }

      return result;
    });
