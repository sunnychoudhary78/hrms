import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/attendance/shared/data/attendance_rerpository.dart';
import 'package:lms/features/attendance/shared/data/attendence_api_service.dart';
import '../../../../core/providers/network_providers.dart';

final attendanceApiProvider = Provider<AttendanceApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return AttendanceApiService(api);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final api = ref.read(attendanceApiProvider);
  return AttendanceRepository(api);
});
