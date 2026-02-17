import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_service.dart';

class AttendanceApiService {
  final ApiService api;

  AttendanceApiService(this.api);

  // ─────────────────────────────────────────────
  // FETCH ATTENDANCE
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchAttendance({int? month, int? year}) async {
    debugPrint("➡️ GET ${ApiEndpoints.attendance}");

    final res = await api.get(
      ApiEndpoints.attendance,
      queryParams: {
        if (month != null) "month": month,
        if (year != null) "year": year,
      },
    );

    return res;
  }

  // ─────────────────────────────────────────────
  // FETCH SUMMARY
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchSummary(String month) async {
    final res = await api.get(
      ApiEndpoints.attendanceSummary,
      queryParams: {"month": month},
    );

    return res;
  }

  // ─────────────────────────────────────────────
  // NORMAL CHECK-IN (REMOTE ONLY)
  // ─────────────────────────────────────────────

  Future<void> punchIn(Map<String, dynamic> body) async {
    await api.post(ApiEndpoints.checkIn, body);
  }

  // ─────────────────────────────────────────────
  // ✅ MULTIPART SELFIE CHECK-IN (FINAL CORRECT VERSION)
  // ─────────────────────────────────────────────

  Future<void> punchInMultipart({
    required File file,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("➡️ MULTIPART CHECK-IN START");

    final formData = FormData();

    /// 1️⃣ REQUIRED: Selfie File
    formData.files.add(
      MapEntry(
        "checkInSelfie",
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      ),
    );

    /// 2️⃣ REQUIRED: source
    final source = body["source"] ?? "mobile";

    formData.fields.add(MapEntry("source", source.toString()));

    /// 3️⃣ OPTIONAL: location (JSON string)
    if (body["location"] != null) {
      final loc = body["location"];

      final locationJson = jsonEncode({
        "lat": loc["lat"],
        "lng": loc["lng"],
        if (loc["accuracy"] != null) "accuracy": loc["accuracy"],
      });

      debugPrint("📍 LOCATION SENT: $locationJson");

      formData.fields.add(MapEntry("location", locationJson));
    }

    /// 4️⃣ OPTIONAL: remoteRequested
    if (body["remoteRequested"] != null) {
      formData.fields.add(
        MapEntry("remoteRequested", body["remoteRequested"].toString()),
      );
    }

    /// 5️⃣ OPTIONAL: remoteReason
    if (body["remoteReason"] != null) {
      formData.fields.add(
        MapEntry("remoteReason", body["remoteReason"].toString()),
      );
    }

    /// SEND REQUEST
    await api.postMultipart(ApiEndpoints.checkIn, formData);

    debugPrint("✅ CHECK-IN SUCCESS");
  }

  // ─────────────────────────────────────────────
  // CHECK OUT
  // ─────────────────────────────────────────────

  Future<void> punchOut(Map<String, dynamic> body) async {
    await api.post(ApiEndpoints.checkOut, body);
  }

  // ─────────────────────────────────────────────
  // ✅ MULTIPART SELFIE CHECK-OUT
  // ─────────────────────────────────────────────

  Future<void> punchOutMultipart({
    required File file,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("➡️ MULTIPART CHECK-OUT START");

    final formData = FormData();

    /// 1️⃣ REQUIRED: Selfie File
    formData.files.add(
      MapEntry(
        "checkOutSelfie",
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      ),
    );

    /// 2️⃣ REQUIRED: source
    final source = body["source"] ?? "mobile";

    formData.fields.add(MapEntry("source", source.toString()));

    /// 3️⃣ OPTIONAL: location (ONLY for mobile)
    if (body["location"] != null) {
      final loc = body["location"];

      final locationJson = jsonEncode({
        "lat": loc["lat"],
        "lng": loc["lng"],
        if (loc["accuracy"] != null) "accuracy": loc["accuracy"],
      });

      debugPrint("📍 CHECKOUT LOCATION SENT: $locationJson");

      formData.fields.add(MapEntry("location", locationJson));
    }

    /// 4️⃣ OPTIONAL: remoteRequested
    if (body["remoteRequested"] != null) {
      formData.fields.add(
        MapEntry("remoteRequested", body["remoteRequested"].toString()),
      );
    }

    /// 5️⃣ OPTIONAL: remoteReason
    if (body["remoteReason"] != null) {
      formData.fields.add(
        MapEntry("remoteReason", body["remoteReason"].toString()),
      );
    }

    /// SEND REQUEST
    await api.postMultipart(ApiEndpoints.checkOut, formData);

    debugPrint("✅ CHECK-OUT SUCCESS");
  }

  // ─────────────────────────────────────────────
  // CORRECTION REQUEST
  // ─────────────────────────────────────────────

  Future<void> requestCorrection(Map<String, dynamic> body) async {
    await api.post(ApiEndpoints.attendanceCorrections, body);
  }

  Future<List<dynamic>> fetchAttendanceCorrectionsManaged({
    required String status,
  }) async {
    final res = await api.get(
      ApiEndpoints.attendanceCorrectionsManaged,
      queryParams: {"status": status},
    );

    return res;
  }

  Future<void> updateCorrectionStatus({
    required String id,
    required Map<String, dynamic> body,
  }) async {
    await api.patch("${ApiEndpoints.attendanceCorrections}/$id", body);
  }
}
