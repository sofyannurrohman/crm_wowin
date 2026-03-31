import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String companyName,
  });
  Future<UserEntity> getMe();
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
        throw ServerException(
            response.data['message'] ?? 'Unknown authentication error');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Email atau password salah');
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String companyName = '',
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (companyName.isNotEmpty) 'company_name': companyName,
        },
      );

      if (response.statusCode != 201) {
        throw ServerException(
            response.data['message'] ?? 'Registrasi gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException('Email sudah terdaftar');
      }
      if (e.response?.statusCode == 400) {
        final msg = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Data registrasi tidak valid';
        throw ServerException(msg.toString());
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      final response = await dio.get(ApiEndpoints.getMe);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return UserEntity.fromJson(response.data['data']);
      } else {
        throw ServerException('Gagal mengambil data profil');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
