import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/network_providers.dart';

class AttendanceParams {
  final String userId;
  final DateTime month;

  const AttendanceParams({required this.userId, required this.month});

  // ✅ THIS STOPS INFINITE LOOP
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

final employeeAttendanceProvider =
    FutureProvider.family<Map<String, String>, AttendanceParams>((
      ref,
      params,
    ) async {
      final api = ref.read(apiServiceProvider);

      final firstDay = DateTime(params.month.year, params.month.month, 1);

      final lastDay = DateTime(params.month.year, params.month.month + 1, 0);

      final from = DateFormat('yyyy-MM-dd').format(firstDay);
      final to = DateFormat('yyyy-MM-dd').format(lastDay);

      final response = await api.get(
        'attendance', // remove leading slash
        queryParams: {'userId': params.userId, 'from': from, 'to': to},
      );

      final Map<String, String> result = {};
      final aggregates = response['aggregates'] ?? [];

      for (final item in aggregates) {
        result[item['date']] = item['status'];
      }

      return result;
    });
