import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return AuthModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Unknown authentication error');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Email atau password salah');
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
