import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/features/auth/data/models/user_model.dart';
import '../../../../core/network/api_service.dart';

class AuthApiService {
  final ApiService api;

  AuthApiService(this.api);

  // ─────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────

  Future<UserModel> login(String email, String password) async {
    final response = await api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(response);
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    return await api.get('/employees/single');
  }

  Future<List<String>> fetchPermissions() async {
    final response = await api.get('/auth/permissions');

    final List list = response['permissions'];
    return list.map((p) => p['name'] as String).toList();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await api.post('/auth/change-password', {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    });
  }

  // ─────────────────────────────────────────────
  // 🔑 FORGOT PASSWORD (SEND OTP)
  // ─────────────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    await api.post('/auth/forgot-password', {"email": email});
  }

  // ─────────────────────────────────────────────
  // 🔑 RESET PASSWORD (VERIFY OTP)
  // ─────────────────────────────────────────────

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await api.post('/auth/reset-password', {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    });
  }

  // 🖼️ UPLOAD PROFILE IMAGE
  // ─────────────────────────────────────────────

  Future<String> uploadProfileImage(File file) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await api.postMultipart('/employee-photo/photo', formData);

    return response['filename'];
  }

  // ─────────────────────────────────────────────
  // 🔔 FCM TOKEN (NEW – REQUIRED FOR PUSH)
  // ─────────────────────────────────────────────

  Future<void> registerFcmToken({
    required String fcmToken,
    required String platform, // "android" | "ios"
  }) async {
    await api.post('/auth/register-fcm-token', {
      "fcmToken": fcmToken,
      "platform": platform,
    });
  }

  Future<void> unregisterFcmToken({required String fcmToken}) async {
    await api.post('/auth/unregister-fcm-token', {"fcmToken": fcmToken});
  }
}
