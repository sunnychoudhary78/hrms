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
  // FETCH MOBILE CONFIG (NEW)
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchMobileConfig() async {
    debugPrint("➡️ GET ${ApiEndpoints.mobileAttendanceConfig}");

    final res = await api.get(ApiEndpoints.mobileAttendanceConfig);

    debugPrint("✅ MOBILE CONFIG: $res");

    return res;
  }

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
  // NORMAL CHECK-IN (fallback)
  // ─────────────────────────────────────────────

  Future<void> punchIn(Map<String, dynamic> body) async {
    await api.post(ApiEndpoints.checkIn, body);
  }

  // ─────────────────────────────────────────────
  // MULTIPART CHECK-IN (UPDATED: selfie optional)
  // ─────────────────────────────────────────────

  Future<void> punchInMultipart({
    File? file,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("➡️ MULTIPART CHECK-IN START");

    final formData = FormData();

    /// 1️⃣ OPTIONAL: Selfie File
    if (file != null) {
      debugPrint("📷 CHECK-IN SELFIE ATTACHED");

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
    } else {
      debugPrint("📷 CHECK-IN SELFIE NOT REQUIRED");
    }

    /// 2️⃣ REQUIRED: source
    final source = body["source"] ?? "mobile";

    formData.fields.add(MapEntry("source", source.toString()));

    /// 3️⃣ OPTIONAL: location
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

    await api.postMultipart(ApiEndpoints.checkIn, formData);

    debugPrint("✅ CHECK-IN SUCCESS");
  }

  // ─────────────────────────────────────────────
  // NORMAL CHECK-OUT
  // ─────────────────────────────────────────────

  Future<void> punchOut(Map<String, dynamic> body) async {
    await api.post(ApiEndpoints.checkOut, body);
  }

  // ─────────────────────────────────────────────
  // MULTIPART CHECK-OUT (UPDATED: selfie optional)
  // ─────────────────────────────────────────────

  Future<void> punchOutMultipart({
    File? file,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("➡️ MULTIPART CHECK-OUT START");

    final formData = FormData();

    /// 1️⃣ OPTIONAL: Selfie File
    if (file != null) {
      debugPrint("📷 CHECK-OUT SELFIE ATTACHED");

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
    } else {
      debugPrint("📷 CHECK-OUT SELFIE NOT REQUIRED");
    }

    /// 2️⃣ REQUIRED: source
    final source = body["source"] ?? "mobile";

    formData.fields.add(MapEntry("source", source.toString()));

    /// 3️⃣ OPTIONAL: location
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

    await api.postMultipart(ApiEndpoints.checkOut, formData);

    debugPrint("✅ CHECK-OUT SUCCESS");
  }

  // ─────────────────────────────────────────────
  // CORRECTIONS
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
