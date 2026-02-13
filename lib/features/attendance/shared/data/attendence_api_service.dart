import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';

class AttendanceApiService {
  final ApiService api;

  AttendanceApiService(this.api);

  Future<Map<String, dynamic>> fetchAttendance({int? month, int? year}) async {
    debugPrint(
      "➡️ GET ${ApiEndpoints.attendance} | params: month=$month, year=$year",
    );

    final res = await api.get(
      ApiEndpoints.attendance,
      queryParams: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );

    debugPrint("⬅️ Attendance response received");

    return res;
  }

  Future<Map<String, dynamic>> fetchSummary(String month) async {
    debugPrint(
      "➡️ GET ${ApiEndpoints.attendanceSummary} | params: month=$month",
    );

    final res = await api.get(
      ApiEndpoints.attendanceSummary,
      queryParams: {'month': month},
    );

    debugPrint("⬅️ Attendance summary response received");

    return res;
  }

  Future<void> punchIn(Map<String, dynamic> body) async {
    debugPrint("➡️ POST ${ApiEndpoints.checkIn}");
    debugPrint("➡️ BODY: $body");

    await api.post(ApiEndpoints.checkIn, body);

    debugPrint("⬅️ Punch In API success");
  }

  Future<void> punchOut([Map<String, dynamic>? body]) async {
    debugPrint("➡️ POST ${ApiEndpoints.checkOut}");
    debugPrint("➡️ BODY: ${body ?? 'NO BODY'}");

    if (body == null || body.isEmpty) {
      await api.post(ApiEndpoints.checkOut, {});
    } else {
      await api.post(ApiEndpoints.checkOut, body);
    }

    debugPrint("⬅️ Punch Out API success");
  }

  Future<void> requestCorrection(Map<String, dynamic> body) async {
    debugPrint("➡️ POST ${ApiEndpoints.attendanceCorrections}");
    debugPrint("➡️ BODY: $body");

    await api.post(ApiEndpoints.attendanceCorrections, body);

    debugPrint("⬅️ Attendance correction request sent");
  }

  Future<List<dynamic>> fetchAttendanceCorrectionsManaged({
    required String status,
  }) async {
    debugPrint(
      "➡️ GET ${ApiEndpoints.attendanceCorrectionsManaged} | status=$status",
    );

    final res = await api.get(
      ApiEndpoints.attendanceCorrectionsManaged,
      queryParams: {'status': status},
    );

    debugPrint("⬅️ Attendance corrections response received");

    return res;
  }

  Future<void> updateCorrectionStatus({
    required String id,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("➡️ PATCH ${ApiEndpoints.attendanceCorrections}/$id");
    debugPrint("➡️ BODY: $body");

    await api.patch('${ApiEndpoints.attendanceCorrections}/$id', body);

    debugPrint("⬅️ Correction status updated");
  }

  // ─────────────────────────────────────────────
  // SELFIE UPLOAD
  // ─────────────────────────────────────────────

  // ─────────────────────────────────────────────
  // SELFIE UPLOAD
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> uploadSelfie(File file) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      "selfie": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final res = await api.postMultipart(
      "/attendance/upload-selfie", // ⚠️ adjust if needed
      formData,
    );

    return Map<String, dynamic>.from(res);
  }
}
