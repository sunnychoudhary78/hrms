import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  final Dio dio;

  DioClient({required TokenStorage tokenStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        ),
      ) {
    // 📋 Logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getJwt();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}
