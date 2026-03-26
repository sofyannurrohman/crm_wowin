import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import '../auth/auth_interceptor.dart';
import '../auth/token_storage.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final tokenStorage = TokenStorage(const FlutterSecureStorage());

    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage, dio),
      if (kDebugMode) // Only log requests when developing locally
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
    ]);
  }
}

// Global Singleton for easy DI access / manual overriding
final dioClient = DioClient();
