class LeaveBalance {
  final String id;
  final String leaveTypeId;
  final double available;
  final double carried;
  final double pendingReserved;
  final String name;

  LeaveBalance({
    required this.id,
    required this.leaveTypeId,
    required this.available,
    required this.carried,
    required this.pendingReserved,
    required this.name,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'],
      leaveTypeId: json['leave_type_id'],
      available: (json['available'] as num).toDouble(),
      carried: (json['carried'] as num).toDouble(),
      pendingReserved: (json['pending_reserved'] as num).toDouble(),
      name: json['leave_type']['name'],
    );
  }
}
