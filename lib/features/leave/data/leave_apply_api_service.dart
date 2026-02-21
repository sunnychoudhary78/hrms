import 'package:flutter/cupertino.dart';

import '../../../core/network/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class LeaveApplyApiService {
  final ApiService api;

  LeaveApplyApiService(this.api);

  // ✅ WITH DOCUMENT (MAIN ONE)
  Future<Map<String, dynamic>> sendLeaveRequestWithDocument({
    required Map<String, dynamic> data,
    File? document,
  }) async {
    debugPrint("🌐 Preparing multipart leave request");
    debugPrint("📦 Raw data: $data");
    debugPrint("📄 Document path: ${document?.path}");

    final formData = FormData.fromMap(data);

    if (document != null) {
      formData.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(
            document.path,
            filename: document.path.split('/').last,
          ),
        ),
      );
    }

    debugPrint("📤 Sending multipart request to leave-requests");

    final response = await api.postMultipart('leave-requests', formData);

    debugPrint("📥 Leave apply response received");
    debugPrint("📦 Response: $response");

    return response;
  }

  // (optional fallback)
  Future<Map<String, dynamic>> sendLeaveRequest(
    Map<String, dynamic> data,
  ) async {
    return await api.post('leave-requests', data);
  }
}
