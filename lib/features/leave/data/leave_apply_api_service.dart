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

    return await api.postMultipart(
      'leave-requests', // ✅ SAME AS OLD APP
      formData,
    );
  }

  // (optional fallback)
  Future<Map<String, dynamic>> sendLeaveRequest(
    Map<String, dynamic> data,
  ) async {
    return await api.post('leave-requests', data);
  }
}
