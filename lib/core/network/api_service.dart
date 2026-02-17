import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // ───────── POST ─────────
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    debugPrint("🌐 POST ${_dio.options.baseUrl}$endpoint");
    debugPrint("📦 BODY: $data");

    try {
      final response = await _dio.post(endpoint, data: data);
      debugPrint("✅ POST success | status=${response.statusCode}");
      return _handle(response);
    } on DioException catch (e) {
      debugPrint("❌ POST failed | endpoint=$endpoint");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Response: ${e.response?.data}");
      rethrow;
    }
  }

  // ───────── GET ─────────
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    debugPrint("🌐 GET ${_dio.options.baseUrl}$endpoint");
    if (queryParams != null) {
      debugPrint("📦 QUERY: $queryParams");
    }

    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      debugPrint("✅ GET success | status=${response.statusCode}");
      return _handle(response);
    } on DioException catch (e) {
      debugPrint("❌ GET failed | endpoint=$endpoint");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Response: ${e.response?.data}");
      rethrow;
    }
  }

  // ───────── PATCH ─────────
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    debugPrint("🌐 PATCH ${_dio.options.baseUrl}$endpoint");
    debugPrint("📦 BODY: $data");

    try {
      final response = await _dio.patch(endpoint, data: data);
      debugPrint("✅ PATCH success | status=${response.statusCode}");
      return _handle(response);
    } on DioException catch (e) {
      debugPrint("❌ PATCH failed | endpoint=$endpoint");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Response: ${e.response?.data}");
      rethrow;
    }
  }

  // ───────── MULTIPART ─────────
  Future<dynamic> postMultipart(String endpoint, FormData formData) async {
    debugPrint("🌐 POST MULTIPART ${_dio.options.baseUrl}$endpoint");

    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      debugPrint("✅ MULTIPART success | status=${response.statusCode}");
      return _handle(response);
    } on DioException catch (e) {
      debugPrint("❌ MULTIPART failed | endpoint=$endpoint");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Response: ${e.response?.data}");
      rethrow;
    }
  }

  dynamic _handle(Response response) {
    final code = response.statusCode ?? 0;

    if (code >= 200 && code < 300) {
      return response.data;
    }

    debugPrint("❌ Unexpected status code: $code");

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
    );
  }

  Future<dynamic> delete(String endpoint, Map<String, dynamic> data) async {
    debugPrint("🌐 DELETE ${_dio.options.baseUrl}$endpoint");
    debugPrint("📦 BODY: $data");

    try {
      final response = await _dio.delete(endpoint, data: data);

      debugPrint("✅ DELETE success | status=${response.statusCode}");

      return _handle(response);
    } on DioException catch (e) {
      debugPrint("❌ DELETE failed | endpoint=$endpoint");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Response: ${e.response?.data}");
      rethrow;
    }
  }
}
