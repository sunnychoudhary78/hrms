import '../../data/models/attendance_request_model.dart';

class AttendanceRequestsState {
  final bool isLoading;
  final String statusFilter;
  final List<AttendanceRequest> requests;

  const AttendanceRequestsState({
    required this.isLoading,
    required this.statusFilter,
    required this.requests,
  });

  factory AttendanceRequestsState.initial() {
    return const AttendanceRequestsState(
      isLoading: false,
      statusFilter: 'PENDING',
      requests: [],
    );
  }

  AttendanceRequestsState copyWith({
    bool? isLoading,
    String? statusFilter,
    List<AttendanceRequest>? requests,
  }) {
    return AttendanceRequestsState(
      isLoading: isLoading ?? this.isLoading,
      statusFilter: statusFilter ?? this.statusFilter,
      requests: requests ?? this.requests,
    );
  }
}
