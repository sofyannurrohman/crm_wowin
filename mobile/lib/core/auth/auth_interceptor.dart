import 'package:dio/dio.dart';
import 'token_storage.dart';
import '../api/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor(this.tokenStorage, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.getRefreshToken();
      
      // Attempt token retry mechanism
      if (refreshToken != null) {
        try {
          // Send refresh token request directly without interceptors to prevent looping
          final response = await Dio().post(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.refresh}',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['access_token'];
            final newRefreshToken = response.data['data']['refresh_token'];
            
            await tokenStorage.saveTokens(
              access: newAccessToken,
              refresh: newRefreshToken,
            );

            // Retry original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails (e.g., token expired/invalid), purge local 
          await tokenStorage.clearTokens();
          // Routing to login handled externally (e.g. by listening to Riverpod auth state)
        }
      } else {
        await tokenStorage.clearTokens();
      }
    }
    return handler.next(err);
  }
}
