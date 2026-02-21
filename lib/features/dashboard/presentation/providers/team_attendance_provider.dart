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
// SAFE DATE NORMALIZER
//////////////////////////////////////////////////////////////

String _normalizeDate(dynamic rawDate) {
  try {
    if (rawDate == null) return '';

    // Already correct
    if (rawDate is String) return rawDate;

    // Backend sends object: { date: "2026-02-11", halfDayPart: null }
    if (rawDate is Map<String, dynamic>) {
      if (rawDate.containsKey('date')) {
        return rawDate['date']?.toString() ?? '';
      }

      if (rawDate.containsKey('value')) {
        return rawDate['value']?.toString() ?? '';
      }
    }

    return rawDate.toString();
  } catch (_) {
    return '';
  }
}

//////////////////////////////////////////////////////////////
// PROVIDER
//////////////////////////////////////////////////////////////

final employeeAttendanceProvider =
    FutureProvider.family<Map<String, AttendanceDayData>, AttendanceParams>((
      ref,
      params,
    ) async {
      try {
        final api = ref.read(apiServiceProvider);

        //////////////////////////////////////////////////////////
        // DATE RANGE
        //////////////////////////////////////////////////////////

        final firstDay = DateTime(params.month.year, params.month.month, 1);

        final lastDay = DateTime(params.month.year, params.month.month + 1, 0);

        final from = DateFormat('yyyy-MM-dd').format(firstDay);
        final to = DateFormat('yyyy-MM-dd').format(lastDay);

        //////////////////////////////////////////////////////////
        // API CALL
        //////////////////////////////////////////////////////////

        final response = await api.get(
          'attendance',
          queryParams: {'userId': params.userId, 'from': from, 'to': to},
        );

        final aggregates = (response['aggregates'] as List?) ?? const [];

        final sessions = (response['sessions'] as List?) ?? const [];

        //////////////////////////////////////////////////////////
        // GROUP SESSIONS BY DATE
        //////////////////////////////////////////////////////////

        final Map<String, List> sessionsByDate = {};

        for (final session in sessions) {
          try {
            final date = _normalizeDate(session['date']);

            if (date.isEmpty) continue;

            sessionsByDate.putIfAbsent(date, () => []);

            sessionsByDate[date]!.add(session);
          } catch (_) {
            // Skip bad session safely
          }
        }

        //////////////////////////////////////////////////////////
        // BUILD FINAL RESULT MAP
        //////////////////////////////////////////////////////////

        final Map<String, AttendanceDayData> result = {};

        for (final aggregate in aggregates) {
          try {
            final date = _normalizeDate(aggregate['date']);

            if (date.isEmpty) continue;

            final daySessions = sessionsByDate[date] ?? const [];

            result[date] = AttendanceDayData.fromJson(
              aggregate: {
                ...aggregate,
                'date': date, // normalized safe date
              },
              sessionsJson: daySessions,
            );
          } catch (_) {
            // Skip bad aggregate safely
          }
        }

        return result;
      } catch (_) {
        // Never crash UI
        return {};
      }
    });
