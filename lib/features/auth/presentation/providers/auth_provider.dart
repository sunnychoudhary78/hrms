import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/network/api_constants.dart';
import 'package:lms/core/providers/app_restart_provider.dart';
import 'package:lms/core/providers/network_providers.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/auth_api_service.dart';
import 'auth_state.dart';
import '../../../profile/data/models/user_details_model.dart';
import 'auth_api_providers.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthApiService _authApi;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _authApi = ref.read(authApiServiceProvider);
    _tokenStorage = ref.read(tokenStorageProvider);
    return const AuthState();
  }

  // ─────────────────────────────────────────────
  // 🔁 AUTO LOGIN
  // ─────────────────────────────────────────────

  Future<void> tryAutoLogin() async {
    final jwt = await _tokenStorage.getJwt();
    if (jwt == null || jwt.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true);

      final profileJson = await _authApi.fetchProfile();
      final profile = Userdetails.fromJson(profileJson);
      final permissions = await _authApi.fetchPermissions();

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        permissions: permissions,
        profileUrl: profile.profilePicture != null
            ? ApiConstants.imageBaseUrl + profile.profilePicture!
            : '',
      );

      // 🔔 REGISTER FCM TOKEN (AUTO LOGIN)
      await _registerFcmIfAvailable();
    } catch (_) {
      await _tokenStorage.clear();
      state = const AuthState();
    }
  }

  // ─────────────────────────────────────────────
  // 🔐 LOGIN
  // ─────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final userModel = await _authApi.login(email, password);
      await _tokenStorage.saveJwt(userModel.token);

      final profileJson = await _authApi.fetchProfile();
      final profile = Userdetails.fromJson(profileJson);
      final permissions = await _authApi.fetchPermissions();

      state = state.copyWith(
        isLoading: false,
        authUser: userModel.user,
        profile: profile,
        permissions: permissions,
        profileUrl: profile.profilePicture != null
            ? ApiConstants.imageBaseUrl + profile.profilePicture!
            : '',
      );

      // 🔔 REGISTER FCM TOKEN (LOGIN)
      await _registerFcmIfAvailable();
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // 🔑 CHANGE PASSWORD
  // ─────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ─────────────────────────────────────────────
  // 🚪 LOGOUT
  // ─────────────────────────────────────────────

  Future<void> logout() async {
    final fcmToken = await _tokenStorage.getFcm();

    if (fcmToken != null && fcmToken.isNotEmpty) {
      try {
        await _authApi.unregisterFcmToken(fcmToken: fcmToken);
      } catch (_) {}
    }

    await _tokenStorage.clear();

    state = const AuthState();

    // 🔥 VERY IMPORTANT — RESET ENTIRE APP STATE
    ref.read(appRestartProvider.notifier).restart();
  }

  // ─────────────────────────────────────────────
  // 🔔 HELPERS
  // ─────────────────────────────────────────────

  Future<void> _registerFcmIfAvailable() async {
    final fcmToken = await _tokenStorage.getFcm();

    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    try {
      await _authApi.registerFcmToken(
        fcmToken: fcmToken,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
    } catch (_) {
      // backend failure should NOT break login
    }
  }

  Future<void> registerFcmTokenIfNeeded() async {
    await _registerFcmIfAvailable();
  }
}
